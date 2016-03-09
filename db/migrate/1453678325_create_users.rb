Sequel.migration do
  change do
    create_table(:users) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      Integer      :old_id
      String       :email, null: false
      String       :secondary_email
      String       :facebook_uid
      String       :encrypted_password, null: false
      String       :encrypted_password_token
      Time         :password_token_sent_at
      String       :first_name, null: false
      String       :last_name, null: false
      Float        :latitude
      Float        :longitude
      Float        :delta, null: false, default: 0.02
      String       :address_name
      String       :address_thoroughfare
      String       :address_sub_thoroughfare
      String       :address_sub_locality
      String       :address_locality
      String       :address_sub_administrative_area
      String       :address_administrative_area
      String       :address_country
      String       :address_postal_code
      String       :address_complement
      TrueClass    :accepted_terms, null: false, default: false
      TrueClass    :reviewed_email, null: false, default: false
      TrueClass    :reviewed_location, null: false, default: false
      TrueClass    :admin, null: false, default: false
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false

      index :email, unique: true
      index :old_id, unique: true
      index :facebook_uid, unique: true     
    end
  end
end
