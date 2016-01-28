module Endpoints
  class Password < Base
    namespace "/password" do
      post do
        user = User[email: body_params[:email]]
        raise Pliny::Errors::NotFound unless user
        raise Pliny::Errors::UnprocessableEntity unless user.send_reset_password_token
        status 201
        encode Hash.new
      end

      patch do
        encode Hash.new
      end
    end
  end
end
