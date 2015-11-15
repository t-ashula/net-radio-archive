class CreateHibikiProgramV2 < ActiveRecord::Migration
  def up
    create_table 'hibiki_program_v2s', force: true, unsigned: true do |t|
      t.column 'access_id',    :string,  null: false, limit: 100, charset: 'ascii'
      t.column 'episode_id',   :integer, null: false, unsigned: true
      t.column 'title',        :string,  null: false, limit: 250, charset: 'utf8mb4'
      t.column 'episode_name', :string,  null: false, limit: 250, charset: 'utf8mb4'
      t.column 'cast',         :string,  null: false, limit: 250, charset: 'utf8mb4'
      t.column 'state',        :string,  null: false, limit: 100, charset: 'ascii'
      t.column 'retry_count',  :integer, null: false, unsigned: true
      t.timestamps null: false

      t.index ['access_id', 'episode_id'], unique: true
    end
  end
  def down
    drop_table 'hibiki_program_v2s'
  end
end
