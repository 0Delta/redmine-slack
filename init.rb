require 'redmine'

require File.expand_path('../lib/redmine_slack/listener', __FILE__)

Redmine::Plugin.register :redmine_slack do
	name 'Redmine Slack'
	author '0Delta'
	url 'https://github.com/0Delta/redmine-slack'
	author_url 'https://github.com/0Delta'
	description 'Slack chat integration'
	version '0.12'

	requires_redmine :version_or_higher => '0.8.0'

	settings \
		:default => {
			'callback_url' => 'http://slack.com/callback/',
			'channel' => nil,
			'display_watchers' => 'no'
		},
		:partial => 'settings/slack_settings'
end

if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
	Rails.application.config.after_initialize do
		unless Issue.included_modules.include? RedmineSlack::IssuePatch
			Issue.send(:include, RedmineSlack::IssuePatch)
		end
	end
else
	((Rails.version > "5")? ActiveSupport::Reloader : ActionDispatch::Callbacks).to_prepare do
		require_dependency 'issue'
		unless Issue.included_modules.include? RedmineSlack::IssuePatch
			Issue.send(:include, RedmineSlack::IssuePatch)
		end
	end
end
