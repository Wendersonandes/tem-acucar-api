module Endpoints
  class Reviews < Base
    namespace "/reviews" do
      before do
        authenticate!
      end

      get do
        user = User[params['user_id']]
        raise Pliny::Errors::Forbidden unless user
        limit = params['limit'] || 10
        offset = params['offset'] || 0
        reviews = user.reviews_dataset.reverse(:created_at)
        encode serialize(reviews.limit(limit).offset(offset).all)
      end

      post do
        review = Review.new(body_params)
        review.reviewer = current_user
        if current_user == review.transaction.user
          review.user = review.transaction.demand.user
        else
          review.user = review.transaction.user
        end
        review.save
        status 201
        encode serialize(review)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Review.new(structure).serialize(data)
      end
    end
  end
end
