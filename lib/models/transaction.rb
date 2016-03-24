class Transaction < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :demand
  many_to_one :user
  one_to_many :messages

  def validate
    super
    return unless self.demand && self.user
    errors.add(:demand, 'cannot be of the same user as transaction') if self.demand.user == self.user
  end

  def after_save
    super
    self.demand.update updated_at: DateTime.now
  end

end
