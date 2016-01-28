module Endpoints
  class Authentications < Base
    namespace "/authentications" do
      before do
        authenticate! unless request.post?
      end

      post do
        if body_params[:facebook_token]
          facebook_sign_in
        else
          email_sign_in
        end
      end

      delete do
        sign_out!
        encode serialize(current_user, :current_user)
      end

      private

      def email_sign_in
        begin
          user = User[email: body_params[:email]]
          if user.password == body_params[:password]
            sign_in_and_respond(user)
          else
            raise Pliny::Errors::Unauthorized
          end
        rescue
          raise Pliny::Errors::Unauthorized
        end
      end

      def facebook_sign_in
        begin
          url = "https://graph.facebook.com/v2.5/me?fields=id%2Cbio%2Cemail%2Cfirst_name%2Cgender%2Clast_name%2Cname&access_token=#{body_params[:facebook_token]}"
          facebook = RestClient.get url, :content_type => :json, :accept => :json
          user = User.from_facebook(JSON.parse(facebook))
          raise Pliny::Errors::Unauthorized unless user
          sign_in_and_respond(user)
        rescue
          raise Pliny::Errors::Unauthorized
        end
      end

      def sign_in_and_respond(user)
        status 201
        sign_in!(user)
        encode serialize(user, :current_user)
      end

      def serialize(data, structure = :default)
        Serializers::User.new(structure).serialize(data)
      end
    end
  end
end
