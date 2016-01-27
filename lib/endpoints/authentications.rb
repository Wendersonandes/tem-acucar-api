module Endpoints
  class Authentications < Base
    namespace "/authentications" do
      post do
        begin
          user = User[email: body_params[:email]]
          if user.password == body_params[:password]
            status 201
            sign_in!(user)
            encode serialize(user)
          else
            raise Pliny::Errors::Unauthorized
          end
        rescue
          raise Pliny::Errors::Unauthorized
        end
      end

      delete do
        authenticate!
        user = current_user
        sign_out!
        encode serialize(user)
      end

      private

      def serialize(data, structure = :default)
        Serializers::User.new(structure).serialize(data)
      end
    end
  end
end
