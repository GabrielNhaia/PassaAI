class AddNotificationsAndPreferencesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email_notifications, :boolean, default: false
    add_column :users, :sms_notifications, :boolean, default: false
    add_column :users, :dark_mode, :boolean, default: false
    add_column :users, :language, :string, default: 'pt-BR'
  end
end
