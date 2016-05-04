class Review < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :transaction
  many_to_one :user
  many_to_one :reviewer, class: :User, key: :reviewer_id

  def after_create
    super
    Notification.create({
      user: self.user,
      triggering_user: self.reviewer,
      review: self,
      subject: "#{self.reviewer.first_name} escreveu uma avaliação para você",
      text: "<b>#{self.reviewer.first_name}</b> escreveu uma avaliação para você no pedido <b>#{self.transaction.demand.name}</b>.",
    })
  end
end
