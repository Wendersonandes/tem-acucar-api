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
      text: "Seu pedido <b>#{self.name}</b> foi denunciado como impróprio e não ficará disponível até ser aprovado por nossos moderadores.",
    })
    User.where(admin: true).all.each do |user|
      Notification.create({
        user: user,
        demand: self,
        text: "O pedido <b>#{self.name}</b> foi denunciado como impróprio.",
        admin: true,
      })
    end
  end

  def notify_reactivate
    Notification.create({
      user: self.user,
      demand: self,
      text: "Seu pedido <b>#{self.name}</b> foi verificado pelos nossos moderadores e está disponível novamente! :D",
    })
  end

end
