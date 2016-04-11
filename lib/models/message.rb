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
    transaction = self.transaction
    demand = transaction.demand
    user = (self.user == transaction.user ? demand.user : transaction.user)
    triggering_user = self.user
    initial_message = Message.where(transaction: transaction, user: user).count == 0
    if initial_message
      text = "<b>#{triggering_user.first_name}</b> respondeu ao seu pedido <b>#{demand.name}</b>."
    else
      text = "<b>#{triggering_user.first_name}</b> respondeu sua mensagem no pedido <b>#{demand.name}</b>."
    end
    Notification.create({
      user: user,
      triggering_user: triggering_user,
      transaction: self.transaction,
      message: self,
      text: text,
    })
  end

end
