module Endpoints
  class Users < Base
    namespace "/users" do
      before do
        authenticate! unless request.post?
      end

      get do
        encode serialize(User.all)
      end

      post do
        user = User.new(body_params)
        begin
          user.save
          status 201
          sign_in!(user)
          encode serialize(user)
        rescue
          status 422
          errors(user.errors.full_messages)
        end
      end

      get "/:id" do |id|
        user = User.first(id: id) || halt(404)
        encode serialize(user)
      end

      patch "/:id" do |id|
        user = User.first(id: id) || halt(404)
        # warning: not safe
        #user.update(body_params)
        encode serialize(user)
      end

      private

      def serialize(data, structure = :default)
        Serializers::User.new(structure).serialize(data)
      end

    end
  end
end
