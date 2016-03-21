class Refusal < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :demand
  many_to_one :user

end
