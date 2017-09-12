class CreateMicroposts < ActiveRecord::Migration[5.0]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true

      t.timestamps
    end
    # user_idに関連したマイクロポストを作成時刻の逆順で取得用
    add_index :microposts, [:user_id, :created_at]
  end
end
