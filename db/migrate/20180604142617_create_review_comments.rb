class CreateReviewComments < ActiveRecord::Migration[5.2]
  def change
    create_table :review_comments do |t|
      t.text :body
      t.integer :state, default: 0, null: false
      t.integer :user_id, index: true
      t.integer :review_request_id, index: true

      t.timestamps
    end
  end
end
