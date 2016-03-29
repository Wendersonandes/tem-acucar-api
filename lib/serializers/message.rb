class Serializers::Message < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      user_id: arg.user_id,
      text: arg.text,
      created_at: arg.created_at.try(:iso8601),
    }
  end
end
