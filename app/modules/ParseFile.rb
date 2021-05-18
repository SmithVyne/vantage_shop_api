class ParseFile
    attr_reader :response
    
    def initialize(tsv_str)
        @errors = []
        shopData = parseAsFile(tsv_str)
        @response = {shopData: shopData, errors: @errors}
    end


    private

    def getItemFromRow(row, header, columnName)
        return row[header.find_index{|column| column == columnName}]
    end    

    def getPriceFromSales(rows, header)
        begin
            return getItemFromRow(rows, header, 'Sales').to_f
        rescue => exception
            return 0
        end
    end
    
    def getProductUrlFromLineItem(rows, header)
        begin
            baseUrl = 'https://www.foo.com'
            category = getItemFromRow(rows, header, 'Category')
            subCategory = getItemFromRow(rows, header, 'Sub-Category')
            productId = getItemFromRow(rows, header, 'Product ID')

            return [baseUrl, category, subCategory, productId].join('/')
        rescue
            return ""
        end
    end

    def getLineItem(row, header)
        return {
            product_url: getProductUrlFromLineItem(row, header),
            revenue: getPriceFromSales(row, header)
        }
    end

    def getDateFromString(dateString)
        date = dateString.split('/')
        year = date[2].to_i % 2000 + 2000 

        Time.utc(year, date[0], date[1]).strftime '%Y-%m-%d %H:%M:%S'
    end

    def getISOOrderDateIfAfter(row, header, dateString)
        begin
            orderDate = getDateFromString(getItemFromRow(row, header, 'Order Date'))
            dString = getDateFromString(dateString)
            
            if orderDate && (orderDate > dString)
                return orderDate
            end
            return nil
        rescue => e
            @errors << e
            return nil
        end
    end

    def convertToOrder(row, header, rowOrderId, line_item)
        order = {
            order_id: rowOrderId, 
            order_date:  getISOOrderDateIfAfter(row, header, '7/31/2016'), 
            line_items: [line_item]
        }

        order
    end

    def createOrMergeOrders(rows, header)
        shopData = {}
        
        rows.each_with_index do |row, index|
            begin
                customerName = getItemFromRow(row, header, 'Customer Name')
                rowOrderId = getItemFromRow(row, header, 'Order ID')

                    raise "Customer Name does not exist" unless customerName[0]
                    raise "Row Order ID does not exist" unless rowOrderId[0]
                
                line_item = getLineItem(row, header)
                order = convertToOrder(row, header, rowOrderId, line_item)

                if shopData[customerName]
                    orderIndex = shopData[customerName][:orders].find_index{|order| order[:order_id] == rowOrderId}
                    if orderIndex
                        shopData[customerName][:orders][orderIndex][:line_items] << line_item
                    else
                        shopData[customerName][:orders] << order
                    end
                else
                    shopData[customerName] = {
                        orders: [order]
                    }
                end
            rescue => err
                index = getItemFromRow(row, header, 'Row ID').empty? ? index + 1 : getItemFromRow(row, header, 'Row ID')
                @errors << "Error parsing row #{index} :>>  #{err}"
            end
        end

        shopData
    end

    def getOrderData(lines, header)
        rows = lines[1..]
            .map{|row| row.split('\t')}
            .select{|row| getISOOrderDateIfAfter(row, header, '7/31/2016')}

        shopData = createOrMergeOrders(rows, header)
            
        shopData
    end

    def parseAsFile(tsv_str)
        begin
            esc_tsv = tsv_str.chomp.dump[1...-1]
            lines = esc_tsv.split('\n')
            header = lines[0].split('\t')
            raise "Invalid TSV file" unless header.count == 21
            shopData = getOrderData(lines, header)
            
            shopData
        rescue => err
            @errors << "Error parsing tsv file: #{err}"
            {}
        end
    end
end