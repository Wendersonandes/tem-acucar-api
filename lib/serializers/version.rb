class Serializers::Version < Serializers::Base
  structure(:default) do |arg|
    {
      number: arg.number,
      expiry: arg.expiry.try(:iso8601),
    }
  end
end
