require "spec_helper"

RSpec.describe Endpoints::Versions do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./schema/schema.json"
  end

  before do
    @version = Version.create({
      number: '1.0.0',
      platform: 'ios',
      expiry: DateTime.now + 14
    })
  end

  describe 'GET /versions' do
    it 'returns correct status code and conforms to schema' do
      get '/versions'
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'GET /versions/:id' do
    it 'returns correct status code and conforms to schema' do
      get "/versions/#{@version.id}"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
