class Review < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :transaction
  many_to_one :user
  many_to_one :reviewer, class: :User, key: :reviewer_id
end
