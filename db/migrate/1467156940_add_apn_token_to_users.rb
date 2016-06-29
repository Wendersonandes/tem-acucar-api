Sequel.migration do
  change do
    alter_table(:users) do
      add_column :apn_token, String
    end
  end
end
