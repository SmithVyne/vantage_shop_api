class Response < ApplicationRecord

    def self.getISOOrderDateIfAfter(row, header, dateString)
        
    end


    def self.getOrderData(lines, header)
        shopData = {hi: lines}

        lines = lines[1..]
            .map{|row| row.split('\t')}
            .select{|row| self.getISOOrderDateIfAfter(row, header, '7/31/2016')}

        shopData
    end

    def self.parseAsFile(tsv_str)
        # res = {response: {hi: tsv_str}}
        lines = tsv_str.split('\n')
        header = lines[0].split('\t')
        shopData = self.getOrderData(lines, header)
        
        return shopData
    end
end
