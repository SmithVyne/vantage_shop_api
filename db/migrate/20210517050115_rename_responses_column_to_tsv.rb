class RenameResponsesColumnToTsv < ActiveRecord::Migration[6.1]
  def change
    rename_column :responses, :response, :tsv
  end
end
