require 'redmine'
require_relative 'lib/redmine_unread_issues_indicator/hooks'
require_relative 'lib/redmine_unread_issues_indicator/patches/issues_controller_patch'
require_relative 'config/routes'

Redmine::Plugin.register :redmine_unread_issues_indicator do
  name 'Unread Issues Indicator'
  author 'NorthBridgeKholmsk'
  description 'Displays a green dot before issue subject if there are unread changes for the current user'
  version '1.0.0'
  url 'https://github.com/NorthBridgeKholmsk/UnreadIssuesIndicator'
  requires_redmine version_or_higher: '6.1.0'
end

Rails.application.config.after_initialize do
  IssuesController.send(:include, RedmineUnreadIssuesIndicator::Patches::IssuesControllerPatch)
end
