class Serializers::Refusal < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
    }
  end
end
