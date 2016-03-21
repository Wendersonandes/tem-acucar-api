module Endpoints
  class Flags < Base
    namespace "/flags" do
      before do
        authenticate!
      end

      post do
        flag = Flag.new(body_params)
        flag.user = current_user
        flag.save
        status 201
        encode serialize(flag)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Flag.new(structure).serialize(data)
      end
    end
  end
end
