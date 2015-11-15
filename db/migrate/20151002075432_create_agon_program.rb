class CreateAgonProgram < ActiveRecord::Migration
  def up
    create_table 'agon_programs', force: true, unsigned: true do |t|
      t.column 'title',       :string,  null: false, limit: 250, charset: 'utf8mb4'
      t.column 'personality', :string,  null: false, limit: 250, charset: 'utf8mb4'
      t.column 'episode_id',  :string,  null: false, limit: 250, charset: 'ascii'
      t.column 'page_url',    :string,  null: false, limit: 767, charset: 'ascii'
      t.column 'state',       :string,  null: false, limit: 100, charset: 'ascii'
      t.column 'retry_count', :integer, null: false, unsigned: true
      t.timestamps null: false

      t.index 'episode_id', unique: true,  name: 'episode_id'
      t.index 'page_url',   unique: false, name: 'page_url' 
    end
  end

  def down
    drop_table 'agon_programs'
  end
end
