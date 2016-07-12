class Demand < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence
  plugin :validation_class_methods
  plugin :geocoder
  reverse_geocoded_by :latitude, :longitude

  many_to_one :user
  one_to_many :transactions

  state_machine initial: :notifying do
    state :notifying
    state :active
    state :flagged
    state :canceled
    state :completed

    after_transition :on => :flag, :do => :notify_flag
    after_transition :on => :complete, :do => :notify_complete
    after_transition :flagged => :active, :do => :notify_reactivate

    event :activate do
      transition :notifying => :active
    end

    event :flag do
      transition [:notifying, :active] => :flagged
    end

    event :cancel do
      transition [:flagged, :notifying, :active] => :canceled
    end

    event :complete do
      transition [:notifying, :active] => :completed
    end

    event :reactivate do
      transition [:flagged, :completed, :canceled] => :active
    end
  end

  def after_create
    super
    Workers::DemandNotifier.perform_async(self.id)
  end

  private

  def notify_flag
    Notification.create({
      user: self.user,
      demand: self,
      subject: "Seu pedido foi marcado como impróprio",
      text: "Seu pedido <b>#{self.name}</b> foi marcado como impróprio e está em pausa enquanto é analisado pelos nossos moderadores.",
    })
    User.where(admin: true).all.each do |user|
      Notification.create({
        user: user,
        demand: self,
        subject: "Pedido denunciado como impróprio",
        text: "O pedido <b>#{self.name}</b> foi denunciado como impróprio.",
        admin: true,
      })
    end
  end

  def notify_complete
    self.transactions.each do |transaction|
      Notification.create({
        triggering_user: self.user,
        user: transaction.user,
        demand: self,
        subject: "#{self.user.first_name} já conseguiu um(a) #{self.name}",
        text: "<b>#{self.user.first_name}</b> já conseguiu um(a) <b>#{self.name}</b>.",
      })
    end
  end

  def notify_reactivate
    Notification.create({
      user: self.user,
      demand: self,
      subject: "Seu pedido está disponível novamente",
      text: "Seu pedido <b>#{self.name}</b> foi verificado pelos nossos moderadores e está disponível novamente! :D",
    })
  end

end
