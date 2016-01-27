class Serializers::Error < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      message: arg.message,
    }
  end
end
