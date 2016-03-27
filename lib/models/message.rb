class Message < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :transaction
  many_to_one :user

  def validate
    super
    return unless self.transaction && self.user
    errors.add(:user, 'must be participating of the transaction') unless [self.transaction.user, self.transaction.demand.user].include?(self.user)
  end

  def after_create
    super
    self.transaction.update last_message_text: self.text
  end

end
