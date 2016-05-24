Sequel.migration do
  change do
    alter_table(:users) do
      add_column :email_notifications, TrueClass, null: false, default: true
      add_column :app_notifications, TrueClass, null: false, default: true
    end
  end
end
