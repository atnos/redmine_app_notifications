class UpdateUsers < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
    def self.up
        change_table :users do |t|
            t.column :app_notification, :boolean, :default => false
        end
    end

    def self.down
        change_table :users do |t|
            t.remove :app_notification
        end
    end
end
