module Endpoints
  class Versions < Base
    namespace "/versions" do
      get do
        encode serialize(Version.all)
      end

      get "/:id" do |id|
        version = Version.first(id: id) || halt(404)
        encode serialize(version)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Version.new(structure).serialize(data)
      end
    end
  end
end
