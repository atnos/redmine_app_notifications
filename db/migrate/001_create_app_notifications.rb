class CreateAppNotifications <  Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :app_notifications do |t|
      t.datetime :created_on
      t.boolean :viewed, default: false
      t.references :journal
      t.references :issue
      t.references :author
      t.references :recipient
    end
    add_index :app_notifications, :journal_id
    add_index :app_notifications, :issue_id
    add_index :app_notifications, :author_id
    add_index :app_notifications, :recipient_id
  end
end
