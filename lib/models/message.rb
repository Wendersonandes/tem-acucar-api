class Message < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :transaction
  many_to_one :user
end
