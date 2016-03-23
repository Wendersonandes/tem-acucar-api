class Message < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :transaction
  many_to_one :user

  def after_create
    super
    self.transaction.update last_message_text: self.text
  end

end
