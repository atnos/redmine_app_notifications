module AppNotificationsJournalsPatch
  extend ActiveSupport::Concern

  included do
    after_create :create_app_notifications_after_create_journal
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

  def create_app_notifications_after_create_journal

    if notify? && (Setting.plugin_redmine_app_notifications.include?('issue_updated') ||
        (Setting.plugin_redmine_app_notifications.include?('user_mentioned')) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_note_added') && journalized.notes.present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_status_updated') && journalized.status.present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_assigned_to_updated') && journalized.detail_for_attribute('assigned_to_id').present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_priority_updated') && journalized.new_value_for('priority_id').present?)
      )
      issue = journalized.reload
      to_users = notified_users
      cc_users = notified_watchers - to_users
      issue = journalized
      @author = user
      @issue = issue

      mentioned_users = get_mentioned_users(@issue.notes)
      @users = to_users + cc_users + mentioned_users

      @users.each do |user|
        if user.app_notification && user.id != @author.id
          notification = AppNotification.create({
            :journal_id => id,
            :issue_id => @issue.id,
            :author_id => @author.id,
            :recipient_id => user.id,
          })
          notification.deliver
        end
      end
    end
  end
end

Journal.send(:include, AppNotificationsJournalsPatch)
