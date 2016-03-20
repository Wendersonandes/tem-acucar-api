module Endpoints
  class Users < Base
    namespace "/users" do
      before do
        authenticate! unless request.post?
      end

      get do
        encode serialize(current_user.neighbors)
      end

      post do
        user = User.new(body_params)
        begin
          user.save
          status 201
          sign_in!(user)
          encode serialize(user, :current_user)
        rescue
          status 422
          errors(user.errors.full_messages)
        end
      end

      get "/:id" do |id|
        user = User.first(id: id)
        raise Pliny::Errors::NotFound unless user
        encode serialize(user)
      end

      put "/:id" do |id|
        user = User.first(id: id)
        raise Pliny::Errors::NotFound unless user
        begin
          user.update(body_params)
          encode serialize(user, :current_user)
        rescue
          status 422
          errors(user.errors.full_messages)
        end
      end

      private

      def serialize(data, structure = :default)
        Serializers::User.new(structure).serialize(data)
      end
    end
  end
end
