class IssueReadMark < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue

  validates :user_id, :issue_id, :last_viewed_at, presence: true
  validates :issue_id, uniqueness: { scope: :user_id }
end
