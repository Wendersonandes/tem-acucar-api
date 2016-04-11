class Demand < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence
  plugin :validation_class_methods
  plugin :geocoder
  reverse_geocoded_by :latitude, :longitude

  many_to_one :user
  one_to_many :transactions

  state_machine initial: :sending do
    state :sending
    state :active
    state :flagged
    state :canceled
    state :completed

    after_transition :on => :flag, :do => :notify_flag
    after_transition :flagged => :active, :do => :notify_reactivate

    event :activate do
      transition :sending => :active
    end

    event :flag do
      transition [:sending, :active] => :flagged
    end

    event :cancel do
      transition [:flagged, :sending, :active] => :canceled
    end

    event :complete do
      transition [:sending, :active] => :completed
    end

    event :reactivate do
      transition [:flagged, :completed, :canceled] => :active
    end
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
