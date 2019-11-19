class AddArticleNews < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
    def up
      change_table :app_notifications do |t|
        t.references :news, index: true
        t.references :article, index: true
      end
    end

    def down
    end
end
