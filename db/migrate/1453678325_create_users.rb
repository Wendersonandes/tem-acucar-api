Sequel.migration do
  change do
    create_table(:users) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      Integer      :old_id
      String       :email
      String       :facebook_uid
      String       :encrypted_password
      String       :reset_password_token
      Time         :reset_password_sent_at
      Integer      :sign_in_count, null: false, default: 0
      Time         :current_sign_in_at
      Time         :last_sign_in_at
      String       :current_sign_in_ip
      String       :last_sign_in_ip
      String       :first_name
      String       :last_name
      Float        :latitude
      Float        :longitude
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
      TrueClass    :admin, null: false, default: false
      # TODO tokens
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at, default: Sequel.function(:now), null: false

      index :old_id, unique: true
      index :email, unique: true
      index :facebook_uid, unique: true     
      index :reset_password_token, unique: true
    end
  end
end
