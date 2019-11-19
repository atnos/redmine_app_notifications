class UpdateInAppNotifi < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
    def self.up
        change_column_default :users, :app_notification, true
        
        User.find_each do |user|
            user.app_notification = true
            user.save!
        end
    end

    def self.down
    end
end
