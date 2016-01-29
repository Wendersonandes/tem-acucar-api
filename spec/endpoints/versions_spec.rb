require "spec_helper"

RSpec.describe Endpoints::Versions do
  include Rack::Test::Methods

  describe "GET /versions" do
    it "succeeds" do
      get "/versions"
      assert_equal 200, last_response.status
    end
  end
end
