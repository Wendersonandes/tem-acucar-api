class Serializers::Transaction < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      demand: Serializers::Demand.new(:default).serialize(arg.demand),
      user: Serializers::User.new(:default).serialize(arg.user),
      last_message_text: arg.last_message_text,
    }
  end
end
