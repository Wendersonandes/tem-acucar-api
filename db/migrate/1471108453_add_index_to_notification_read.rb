Sequel.migration do
  change do
    alter_table(:notifications) do
      add_index :read
    end
  end
end
