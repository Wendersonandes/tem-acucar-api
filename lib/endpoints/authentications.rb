module Endpoints
  class Authentications < Base
    namespace "/authentications" do
      before do
        authenticate! unless request.post?
      end

      post do
        begin
          user = User[email: body_params[:email]]
          if user.password == body_params[:password]
            status 201
            sign_in!(user)
            encode serialize(user, :current_user)
          else
            raise Pliny::Errors::Unauthorized
          end
        rescue
          raise Pliny::Errors::Unauthorized
        end
      end

      delete do
        sign_out!
        encode serialize(current_user, :current_user)
      end

      private

      def serialize(data, structure = :default)
        Serializers::User.new(structure).serialize(data)
      end
    end
  end
end
