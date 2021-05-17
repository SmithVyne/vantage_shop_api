class AddUuidToResponses < ActiveRecord::Migration[6.1]
  def change
    add_column :responses, :uuid, :string
  end
end
