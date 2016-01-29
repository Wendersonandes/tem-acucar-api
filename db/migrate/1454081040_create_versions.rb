Sequel.migration do
  change do
    create_table(:versions) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      String       :number, null: false
      String       :platform, null: false
      timestamptz  :expiry, null: false
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false

      index [:number, :platform], unique: true     
    end
  end
end
