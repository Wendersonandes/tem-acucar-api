module Endpoints
  class Users < Base
    namespace "/users" do
      before do
        authenticate! unless request.post?
      end

      get do
        encode serialize(current_user.neighbors, :map)
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

      put "/facebook" do
        begin
          url = "https://graph.facebook.com/v2.5/me?fields=id%2Cbio%2Cemail%2Cfirst_name%2Cgender%2Clast_name%2Cname&access_token=#{body_params[:facebook_token]}"
          facebook = JSON.parse(RestClient.get(url, :content_type => :json, :accept => :json))
          begin
            User.where(facebook_uid: facebook['id']).update(facebook_uid: nil)
            current_user.update(facebook_uid: facebook['id'])
            encode serialize(current_user, :current_user)
          rescue
            status 422
            errors(user.errors.full_messages)
          end
        rescue
          raise Pliny::Errors::Unauthorized
        end
      end

      put "/:id" do |id|
        user = User.first(id: id)
        raise Pliny::Errors::NotFound unless user
        raise Pliny::Errors::Forbidden unless user == current_user
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
