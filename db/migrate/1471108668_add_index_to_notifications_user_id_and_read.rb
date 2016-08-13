Sequel.migration do
  change do
    alter_table(:notifications) do
      add_index [:user_id, :read]
    end
  end
end
