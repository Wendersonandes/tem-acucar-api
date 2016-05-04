class Version < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence
end
