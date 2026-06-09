class UnreadIssuesController < ApplicationController
  before_action :require_login

  def index
    issue_ids = params[:ids].to_s.split(',').map(&:to_i).compact.uniq
    if issue_ids.present?
      unread_ids = compute_unread_ids(issue_ids)
      render json: { unread_ids: unread_ids }
    else
      render json: { unread_ids: [] }
    end
  end

  private

  def compute_unread_ids(issue_ids)
    issues = Issue.where(id: issue_ids).select(:id, :updated_on)
    marks = IssueReadMark.where(user_id: User.current.id, issue_id: issue_ids).pluck(:issue_id, :last_viewed_at)
    marks_hash = marks.to_h

    issues.each_with_object([]) do |issue, arr|
      last_viewed = marks_hash[issue.id]
      arr << issue.id if last_viewed.nil? || issue.updated_on.to_i > last_viewed.to_i
    end
  end
end
