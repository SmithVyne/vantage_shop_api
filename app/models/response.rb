class Response < ApplicationRecord
    validates :tsv, presence:true
    validates :uuid, presence:true, uniqueness:true
end
