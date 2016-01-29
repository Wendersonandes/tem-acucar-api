class Serializers::Version < Serializers::Base
  structure(:default) do |arg|
    {
      id:         arg.id,
      number:     arg.number,
      platform:   arg.platform,
      expiry:     arg.expiry.try(:iso8601),
      created_at: arg.created_at.try(:iso8601),
      updated_at: arg.updated_at.try(:iso8601),
    }
  end
end
