class Serializers::Review < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      transaction: Serializers::Transaction.new(:default).serialize(arg.transaction),
      user: Serializers::User.new(:default).serialize(arg.user),
      reviewer: Serializers::User.new(:default).serialize(arg.reviewer),
      rating: arg.rating,
      text: arg.text,
      created_at: arg.created_at.try(:iso8601),
    }
  end
end
