Sequel.migration do
  change do
    create_table(:messages) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      foreign_key  :demand_id, :demands, null: false, type: 'uuid'
      foreign_key  :user_id, :users, null: false, type: 'uuid'
      String       :text, text: true, null: false
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false
    end
  end
end
