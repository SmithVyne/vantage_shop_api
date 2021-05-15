class CreateResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :responses do |t|

      t.text :response
      t.timestamps
    end
  end
end
