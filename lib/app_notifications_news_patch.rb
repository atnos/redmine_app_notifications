module AppNotificationsNewsPatch
    extend ActiveSupport::Concern

    included do
      after_create :create_app_notifications_after_create_news
    end

    def create_app_notifications_after_create_news
      to_users = notified_users
      cc_users = notified_watchers - to_users
      @users = to_users + cc_users

      @users.each do |user|
        if user.app_notification && user.id != author.id
          notification = AppNotification.create({
            :news_id => id,
            :author_id => author.id,
            :recipient_id => user.id,
          })
          notification.deliver
        end
      end
    end
  end

News.send(:include, AppNotificationsNewsPatch)
