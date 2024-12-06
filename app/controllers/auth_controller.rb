class AuthController < ApplicationController

  @auth_token = AuthToken.all
  @auth_channels = AuthChannels.all

  def redirect

    begin
      code = params[:code]
      url = "https://slack.com/api/oauth.v2.access"
      data = {
        code: code,
        client_id: Setting.plugin_redmine_slack['slack_client_id'],
        client_secret: Setting.plugin_redmine_slack['slack_client_secret']
      }
      response = HTTParty.post(url, body: data)

      access_token = response['access_token']

      AuthToken.find_or_initialize_by(token: access_token).save
      Rails.logger.info("Reflesh slack token success")

    rescue StandardError => e
      Rails.logger.error("Reflesh slack token error: #{e}")
    end

    begin
      url = "https://slack.com/api/conversations.list"
      data = {
        token: access_token,
        exclude_archived: true
      }
      response = HTTParty.get(url, query: data)
      Rails.logger.info("Get slack channel list success")

      AuthChannels.delete_all
      response['channels'].each do |channel|
        if channel.has_key?('is_member') && channel['is_member']
          AuthChannels.new(name: channel['name'], key: channel['id']).save
        end
      end
      Rails.logger.info("Save slack channel list success")

    rescue StandardError => e
      Rails.logger.error("Get slack channel list error: #{e}")
    end

    redirect_to '/settings/plugin/redmine_slack'

  end
end
