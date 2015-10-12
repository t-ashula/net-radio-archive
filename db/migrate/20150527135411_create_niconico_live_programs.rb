class CreateNiconicoLivePrograms < ActiveRecord::Migration
  def up
    create_table 'niconico_live_programs', force: true, unsigned: true do |t|
      t.column 'title',       :string,  null: false, limit: 250, charset: 'utf8mb4'
      t.column 'state',       :string,  null: false, limit: 100, charset: 'ascii'
      t.column 'retry_count', :integer, null: false, unsigned: true
      t.timestamps null: false
    end

    change_column 'niconico_live_programs', 'id', :integer, limit: 8, unsigned: true, auto_increment: false
  end
  
  def down
    drop_table 'niconico_live_programs'
  end
end
