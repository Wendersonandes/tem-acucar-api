Sequel.migration do
  change do
    create_table(:reviews) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      Integer      :old_id
      foreign_key  :transaction_id, :transactions, null: false, type: 'uuid'
      foreign_key  :user_id, :users, null: false, type: 'uuid'
      foreign_key  :reviewer_id, :users, null: false, type: 'uuid'
      Integer      :rating, null: false
      String       :text, text: true, null: false
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false
    end
  end
end
