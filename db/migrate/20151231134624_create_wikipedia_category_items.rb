class CreateWikipediaCategoryItems < ActiveRecord::Migration
  def up
    # 検索用キーワードとして抽出するため
    # あまり長いワードは取得できても意味がないためvarcharの長さ制限は短めに
    create_table 'wikipedia_category_items', force: true, unsigned: true do |t|
      t.column 'category', :string, null: false, limit: 100, charset: 'utf8mb4'
      t.column 'title',    :string, null: false, limit: 100, charset: 'utf8mb4'
      t.timestamps null: false

      t.index ['category', 'title'], unique: true
    end
  end

  def down
    drop_table 'wikipedia_category_items'
  end
end
