Sequel.migration do
  change do
    create_table(:notifications) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      foreign_key  :user_id, :users, null: false, type: 'uuid'
      foreign_key  :triggering_user_id, :users, type: 'uuid'
      foreign_key  :demand_id, :demands, type: 'uuid'
      foreign_key  :transaction_id, :transactions, type: 'uuid'
      foreign_key  :message_id, :messages, type: 'uuid'
      String       :text, text: true, null: false
      TrueClass    :read, null: false, default: false
      TrueClass    :admin, null: false, default: false
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false
    end
  end
end
