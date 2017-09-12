class CreateRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # 同じユーザを2回以上フォローを防ぐため。
    # アプリ側でも防ぐが、curl等で直接挿入された時にも対策できるように
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
