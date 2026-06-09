module RedmineUnreadIssuesIndicator
  module Patches
    module IssuesControllerPatch
      extend ActiveSupport::Concern

      included do
        after_action :mark_issue_as_read, only: [:show]
      end

      private

      def mark_issue_as_read
        return unless User.current.logged? && @issue.present?

        mark = IssueReadMark.find_or_initialize_by(
          user_id: User.current.id,
          issue_id: @issue.id
        )
        mark.last_viewed_at = Time.current
        mark.save!
      rescue => e
        Rails.logger.error "IssueReadMark update failed: #{e.message}"
      end
    end
  end
end
