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

    event :activate do
      transition :sending => :active
    end

    event :flag do
      transition [:sending, :active] => :flagged
    end

    event :cancel do
      transition [:sending, :active] => :canceled
    end

    event :reactivate do
      transition [:flagged, :canceled] => :active
    end

    event :complete do
      transition [:sending, :active] => :completed
    end
  end

  def users_with_messages
    User
      .where("id IN (SELECT DISTINCT user_id FROM messages WHERE demand_id = '#{self.id}')")
      .near([self.latitude, self.longitude], 100000, units: :km, order: false)
      .order(:distance, Sequel.desc(:updated_at))
  end

end
