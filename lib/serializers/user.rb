class Serializers::User < Serializers::Base
  structure(:default) do |arg|
    {
      created_at: arg.created_at.try(:iso8601),
      id: arg.id,
      first_name: arg.first_name,
      updated_at: arg.updated_at.try(:iso8601),
    }
  end
end
