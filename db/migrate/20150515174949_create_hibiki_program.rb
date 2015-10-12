class CreateHibikiProgram < ActiveRecord::Migration
  def up
    create_table 'hibiki_programs', force: true, unsigned: true do |t|
      t.column 'title',       :string,   null: false, limit: 250, charset: 'utf8mb4'
      t.column 'comment',     :string,   null: false, limit: 150, charset: 'utf8mb4'
      t.column 'rtmp_url',    :string,   null: false, limit: 767, charset: 'ascii'
      t.column 'state',       :string,   null: false, limit: 100, charset: 'ascii'
      t.column 'retry_count', :integer,  null: false, unsigned: true
      t.timestamps null: false
      
      t.index 'rtmp_url', unique: true, name: 'rtmp_url'
    end
  end
  
  def down
    drop_table 'hibiki_programs'
  end
end
