Sequel.migration do
  change do
    create_table(:tokens) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      foreign_key  :user_id, :users, null: false, type: 'uuid'
      String       :encrypted_token, null: false
      String       :client, null: false
      timestamptz  :expiry, null: false
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false

      index :expiry
      index [:user_id, :client]
    end
  end
end
