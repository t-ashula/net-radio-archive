class CreateOnsenProgram < ActiveRecord::Migration
  def up
    create_table 'onsen_programs', force: true, unsigned: true do |t|
      t.column 'title',       :string,   null: false, limit: 250, charset: 'utf8mb4'
      t.column 'number',      :string,   null: false, limit: 100, charset: 'utf8mb4'
      t.column 'date',        :datetime, null: false
      t.column 'file_url',    :string,   null: false, limit: 767, charset: 'ascii'
      t.column 'personality', :string,   null: false, limit: 250, charset: 'utf8mb4'
      t.column 'state',       :string,   null: false, limit: 100, charset: 'ascii'
      t.timestamps null: false
      
      t.index 'file_url', unique: true, name: 'file_url'
    end
  end
  
  def down
    drop_table 'onsen_programs'
  end
end
