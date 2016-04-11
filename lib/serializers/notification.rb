class Serializers::Notification < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      triggering_user: (arg.triggering_user && Serializers::User.new(:default).serialize(arg.triggering_user)),
      demand: (arg.demand && Serializers::Demand.new(:default).serialize(arg.demand)),
      transaction: (arg.transaction && Serializers::Transaction.new(:default).serialize(arg.transaction)),
      message: (arg.message && Serializers::Message.new(:default).serialize(arg.message)),
      text: arg.text,
      read: arg.read,
      admin: arg.admin,
      created_at: arg.created_at.try(:iso8601),
    }
  end
end
