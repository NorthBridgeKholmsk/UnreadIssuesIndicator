class CreateIssueReadMarks < ActiveRecord::Migration[7.0]
  def change
    create_table :issue_read_marks do |t|
      t.integer :user_id,    null: false
      t.integer :issue_id,   null: false
      t.datetime :last_viewed_at, null: false
    end

    add_index :issue_read_marks, :user_id
    add_index :issue_read_marks, :issue_id
    add_index :issue_read_marks, [:user_id, :issue_id], unique: true
  end
end
