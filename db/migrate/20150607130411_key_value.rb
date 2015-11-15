class KeyValue < ActiveRecord::Migration
  def up
    adapter = connection.adapter_name.downcase
    create_table 'key_value', force: true, id: false do |t|
      if adapter == 'sqlite'
        t.column 'key', 'varchar(256) PRIMARY KEY NOT NULL'
      else
        t.column 'key', :string, null: false, limit: 256, charset: 'ascii'
      end
      t.column 'value', :string, null: false, limit: 250, charset: 'utf8mb4'
      t.timestamps null: false

    end

    if adapter == 'sqlite'
      # nothing
    elsif adapter == 'mysql2'
      execute 'ALTER TABLE key_value ADD PRIMARY KEY (`key`);'
    else 
      execute 'ALTER TABLE key_value ADD PRIMARY KEY ("key");'
    end
  end
  
  def down
    drop_table 'key_value'
  end
end
