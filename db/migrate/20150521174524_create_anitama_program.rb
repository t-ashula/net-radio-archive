class CreateAnitamaProgram < ActiveRecord::Migration
  def up
    # book_id がUNIQUEになることに確信を持てないのでこういう設計に
    create_table 'anitama_programs', force: true, unsigned: true do |t|
      t.column 'book_id',     :string,   null: false, limit: 250, charset: 'ascii'
      t.column 'title',       :string,   null: false, limit: 250, charset: 'utf8mb4'
      t.column 'update_time', :datetime, null: false
      t.column 'state',       :string,   null: false, limit: 100, charset: 'ascii'
      t.column 'retry_count', :integer,  null: false, unsigned: true
      t.timestamps null: false

      t.index ['book_id', 'update_time'], unique: true, name: 'book_id'
    end
  end

  def down
    drop_table 'anitama_programs'
  end
end
