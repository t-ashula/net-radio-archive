class CreateAgonpPrograms < ActiveRecord::Migration
  def up
    create_table 'agonp_programs', force: true, unsigned: true do |t|
      t.column 'title',       :string, null: false, limit: 250, charset: 'utf8mb4'
      t.column 'personality', :string, null: false, limit: 250, charset: 'utf8mb4'
      t.column 'episode_id',  :string, null: false, limit: 250
      t.column 'price',       :string, null: false, limit: 100, charset: 'utf8mb4'
      t.column 'state',       :string, null: false, limit: 100
      t.column 'retry_count', :integer, null: false
      t.timestamps null: false

      t.index 'episode_id', unique: true
    end
  end

  def down
    drop_table 'agonp_programs'
  end
end
