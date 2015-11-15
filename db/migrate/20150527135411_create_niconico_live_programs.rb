class CreateNiconicoLivePrograms < ActiveRecord::Migration
  def up
    adapter = connection.adapter_name.downcase
    create_table 'niconico_live_programs', force: true, id: false do |t|
      if adapter == 'sqlite'
        t.column 'id', 'BIGINT PRIMARY KEY NOT NULL'
      else
        t.column 'id', :integer, null: false, limit: 8, unsigned: true
      end
      t.column 'title',       :string,  null: false, limit: 250, charset: 'utf8mb4'
      t.column 'state',       :string,  null: false, limit: 100, charset: 'ascii'
      t.column 'retry_count', :integer, null: false, unsigned: true
      t.timestamps null: false
    end

    if adapter == 'sqlite'
      # nothing
    else
      execute 'ALTER TABLE niconico_live_programs ADD PRIMARY KEY (id);'
    end
  end
  
  def down
    drop_table 'niconico_live_programs'
  end
end
