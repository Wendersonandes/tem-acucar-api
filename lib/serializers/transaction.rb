class Serializers::Transaction < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      demand: Serializers::Demand.new(:default).serialize(arg.demand),
      user: Serializers::User.new(:default).serialize(arg.user),
      last_message_text: arg.last_message_text,
      created_at: arg.created_at.try(:iso8601),
      updated_at: arg.updated_at.try(:iso8601),
    }
  end
end
