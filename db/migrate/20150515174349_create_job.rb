class CreateJob < ActiveRecord::Migration
  def up
    create_table 'jobs', force: true, unsigned: true do |t|
      t.column 'ch',    :string,   null: false, limit: 100, charset: 'ascii'
      t.column 'start', :datetime, null: false
      t.column 'end',   :datetime, null: false
      t.column 'title', :string,   null: false, limit: 250, charset: 'utf8mb4'
      t.column 'state', :string,   null: false, limit: 100, charset: 'ascii'
      t.timestamps null: false

      t.index ['ch', 'start', 'state'], name: 'start_index'
      t.index ['ch', 'end',   'state'], name: 'end_index'
    end
  end

  def down
    drop_table 'jobs'
  end
end
