class Transaction < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :demand
  many_to_one :user
  one_to_many :messages
  one_to_many :reviews

  def validate
    super
    return unless self.demand && self.user
    errors.add(:demand, 'cannot be of the same user as transaction') if self.demand.user == self.user
  end

  def after_save
    super
    self.demand.update updated_at: DateTime.now
  end

  def can_review_ids
    users = []
    users << self.user.id if can_review(self.user)
    users << self.demand.user.id if can_review(self.demand.user)
    users
  end

  private

  def can_review(user)
    self.reviews_dataset.where(reviewer: user).count == 0 && self.messages.size > 0
  end

end
