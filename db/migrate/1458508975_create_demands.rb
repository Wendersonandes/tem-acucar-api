Sequel.migration do
  change do
    create_table(:demands) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      Integer      :old_id
      foreign_key  :user_id, :users, null: false, type: 'uuid'
      String       :state, null: false
      String       :name, null: false
      String       :description, text: true, null: false
      Float        :latitude, null: false
      Float        :longitude, null: false
      Float        :radius, null: false
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false

      index :old_id, unique: true
      index :state
    end
  end
end
