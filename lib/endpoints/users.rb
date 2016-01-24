module Endpoints
  class Users < Base
    namespace "/users" do
      get do
        encode serialize(User.all)
      end

      post do
        # warning: not safe
        user = User.new(body_params)
        user.save
        status 201
        encode serialize(user)
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

      delete "/:id" do |id|
        user = User.first(id: id) || halt(404)
        user.destroy
        encode serialize(user)
      end

      private

      def serialize(data, structure = :default)
        Serializers::User.new(structure).serialize(data)
      end
    end
  end
end
