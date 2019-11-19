module AppNotificationsIssuesPatch
  extend ActiveSupport::Concern

  included do
    after_create :create_app_notifications_after_create_issue
  end

  MENTIONS_RE = /href="\/users\/([\d]+)">@/

  def get_mentioned_users(text)
    if text
      user_ids = []
      text.gsub!(MENTIONS_RE) do
        user_id = $1
        if user_id
          user_ids.push(user_id)
        end
      end
      users = User.where(:id => user_ids)
    else
      users = []
    end
  end

  def create_app_notifications_after_create_issue
    if Setting.plugin_redmine_app_notifications.include?('issue_added') || (Setting.plugin_redmine_app_notifications.include?('user_mentioned'))
      to_users = notified_users
      cc_users = notified_watchers - to_users

      mentioned_users = get_mentioned_users(description)
      @users = to_users + cc_users + mentioned_users

      @users.each do |user|
        if user.app_notification && user.id != author.id
          notification = AppNotification.create({
            :issue_id => id,
            :author_id => author.id,
            :recipient_id => user.id,
          })
          notification.deliver
        end
      end
    end
  end
end

Issue.send(:include, AppNotificationsIssuesPatch)
