class ParseFile
    attr_accessor :data
    
    def initialize(tsv_str)
        @data = parseAsFile(tsv_str)
    end


    private

    def getItemFromRow(row, header, columnName)
        return row[header.find_index{|column| column == columnName}]
    end

    def orderDateToISODate(orderDate)
        begin
            return Date.new(orderDate)
        rescue => exception
            return ""
        end
    end
    
    def getProductUrlFromLineItem(rows, header)
        begin
            baseUrl = 'https://www.foo.com';
            category = getItemFromRow(fields, header, 'Category');
            subCategory = getItemFromRow(fields, header, 'Sub-Category');
            productId = getItemFromRow(fields, header, 'Product ID');

            return [baseUrl, category, subCategory, productId].join('/');
        rescue
            return ""
        end
    end

    def getPriceFromSales(rows, header)
        begin
            return getItemFromRow(fields, header, 'Sales').to_f
        rescue => exception
            return exception
        end
    end
    
    def getISOOrderDateIfAfter(row, header, dateString)
        begin
            orderDate = getItemFromRow(row, header, 'Order Date')
            
            if orderDate && (Date.new(orderDate) > Date.new(dateString))
                return orderDateToISODate(orderDate)
            end
        rescue
            return nil
        end
    end

    def getLineItem(row, header)
        return {
            product_url: getProductUrlFromLineItem(rows, header),
            revenue: getPriceFromSales(rows, header)
        };
    end

    def convertToOrder(row, header, rowOrderId, line_item)
        order = {
            order_id: rowOrderId, 
            order_date:  getISOOrderDateIfAfter(row, header, '7/31/2016'), 
            line_items: [line_item]
        }

        order
    end

    def createOrMergeOrders(lines, header)
        shopData = {}
        
        lines.each do |row|
            customerName = getItemFromRow(row, header, 'Customer Name')

            rowOrderId = getItemFromRow(row, header, 'Order ID')
            
            line_item = getLineItem(row, header)
            order = convertToOrder(row, header, rowOrderId, line_item)

            if shopData[customerName]
                orderIndex = shopData[customerName]["orders"].find_index{|order| order.order_id == rowOrderId}

                if orderIndex
                    shopData[customerName]["orders"][orderIndex]["line_items"] << line_item
                else
                    shopData[customerName]["orders"] << order
                end
            else
                shopData[customerName] = {
                    orders: [order]
                }
            end
        end

        shopData
    end

    def getOrderData(lines, header)
        lines = lines[1..]
            .map{|row| row.split('\t')}
            .select{|row| getISOOrderDateIfAfter(row, header, '7/31/2016')}

        shopData = createOrMergeOrders(lines, header)
            
        shopData
    end

    def parseAsFile(tsv_str)
        errors = []
        lines = tsv_str.split('\n')
        header = lines[0].split('\t')
        shopData = getOrderData(lines, header)
        
        shopData
    end
end