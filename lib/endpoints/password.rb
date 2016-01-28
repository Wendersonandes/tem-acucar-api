module Endpoints
  class Password < Base
    namespace "/password" do
      post do
        status 201
        encode Hash.new
      end

      patch do
        encode Hash.new
      end
    end
  end
end
