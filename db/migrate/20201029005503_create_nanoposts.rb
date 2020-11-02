class CreateNanoposts < ActiveRecord::Migration[6.0]
  def change
    create_table :nanoposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :micropost, null: false, foreign_key: true

      t.timestamps
    end
    add_index :nanoposts, [:micropost_id, :created_at]
  end
end
