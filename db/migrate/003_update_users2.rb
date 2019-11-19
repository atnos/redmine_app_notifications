class UpdateUsers2 < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
    def self.up
        change_table :users do |t|
            t.column :app_notification_desktop, :boolean, :default => false
        end
    end

    def self.down
        change_table :users do |t|
            t.remove :app_notification_desktop
        end
    end
end
