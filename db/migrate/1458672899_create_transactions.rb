Sequel.migration do
  change do
    create_table(:transactions) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      Integer      :old_id
      foreign_key  :demand_id, :demands, null: false, type: 'uuid'
      foreign_key  :user_id, :users, null: false, type: 'uuid'
      String       :last_message_text, text: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false

      index :old_id, unique: true
    end
  end
end
