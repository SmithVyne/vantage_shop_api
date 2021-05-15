class Response < ApplicationRecord

    def self.getItemFromRow(row, header, columnName)
        return row[header.find_index{|column| column == columnName}]
    end

    def self.orderDateToISODate(orderDate)
        begin
            return Date.new(orderDate)
        rescue => exception
            return ""
        end
    end
    
    def self.getProductUrlFromLineItem(rows, header)
        begin
            baseUrl = 'https://www.foo.com';
            category = self.getItemFromRow(fields, header, 'Category');
            subCategory = self.getItemFromRow(fields, header, 'Sub-Category');
            productId = self.getItemFromRow(fields, header, 'Product ID');

            return [baseUrl, category, subCategory, productId].join('/');
        rescue
            return ""
        end
    end

    def self.getPriceFromSales(rows, header)
        begin
            return self.getItemFromRow(fields, header, 'Sales').to_f
        rescue => exception
            return exception
        end
    end
    
    def self.getISOOrderDateIfAfter(row, header, dateString)
        begin
            orderDate = self.getItemFromRow(row, header, 'Order Date')
            
            if orderDate && (Date.new(orderDate) > Date.new(dateString))
                return self.orderDateToISODate(orderDate)
            end
        rescue
            return nil
        end
    end

    def self.getLineItem(row, header)
        return {
            product_url: self.getProductUrlFromLineItem(rows, header),
            revenue: self.getPriceFromSales(rows, header)
        };
    end

    def self.convertToOrder(row, header, rowOrderId, line_item)
        order = {
            order_id: rowOrderId, 
            order_date:  self.getISOOrderDateIfAfter(row, header, '7/31/2016'), 
            line_items: [line_item]
        }

        order
    end

    def self.createOrMergeOrders(lines, header)
        shopData = {}
        
        lines.each do |row|
            customerName = self.getItemFromRow(row, header, 'Customer Name')

            rowOrderId = self.getItemFromRow(row, header, 'Order ID')
            
            line_item = self.getLineItem(row, header)
            order = self.convertToOrder(row, header, rowOrderId, line_item)

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

    def self.getOrderData(lines, header)
        lines = lines[1..]
            .map{|row| row.split('\t')}
            .select{|row| self.getISOOrderDateIfAfter(row, header, '7/31/2016')}

        shopData = self.createOrMergeOrders(lines, header)
            
        shopData
    end

    def self.parseAsFile(tsv_str)
        errors = []
        lines = tsv_str.split('\n')
        header = lines[0].split('\t')
        shopData = self.getOrderData(lines, header)
        
        shopData
    end
end
