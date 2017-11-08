class CreateNiconicoVideoPrograms < ActiveRecord::Migration
  def up
    create_table 'niconico_video_programs', force: true, unsigned: true do |t|
      t.column 'video_id', :string, null: false, limit: 250, charset: 'ascii'
      t.column 'title',    :string, null: false, limit: 250, charset: 'utf8mb4'
      t.column 'state',    :string, null: false, limit: 100, charset: 'ascii'
      t.column 'retry_count', :integer, null: false
      t.timestamps null: false

      t.index 'video_id', unique: true
    end
  end

  def down
    drop_table 'niconico_video_programs'
  end
end
