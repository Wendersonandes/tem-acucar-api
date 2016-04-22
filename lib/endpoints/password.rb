module Endpoints
  class Password < Base
    namespace "/password" do
      post do
        user = User[email: body_params[:email]]
        raise Pliny::Errors::NotFound unless user
        user.send_password_token
        status 201
        encode Hash.new
      end

      put do
        user = User[email: body_params[:email]]
        raise Pliny::Errors::NotFound unless user
        raise Pliny::Errors::Unauthorized unless user.password_token == body_params[:token].upcase
        begin
          user.password = body_params[:password]
          user.save
        rescue
          raise Pliny::Errors::UnprocessableEntity
        end
        sign_in!(user)
        encode serialize(user, :current_user)
      end

      private

      def serialize(data, structure = :default)
        Serializers::User.new(structure).serialize(data)
      end
    end
  end
end
