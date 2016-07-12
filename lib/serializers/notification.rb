class Serializers::Notification < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      triggering_user: (arg.triggering_user && Serializers::User.new(:default).serialize(arg.triggering_user)),
      demand: (arg.demand && Serializers::Demand.new(:default).serialize(Demand.where(id: arg.demand.id).near([arg.user.latitude, arg.user.longitude], 41000, units: :km).first)),
      transaction: (arg.transaction && Serializers::Transaction.new(:default).serialize(arg.transaction)),
      message: (arg.message && Serializers::Message.new(:default).serialize(arg.message)),
      review: (arg.review && Serializers::Review.new(:default).serialize(arg.review)),
      subject: arg.subject,
      text: arg.text,
      read: arg.read,
      admin: arg.admin,
      created_at: arg.created_at.try(:iso8601),
    }
  end
end
