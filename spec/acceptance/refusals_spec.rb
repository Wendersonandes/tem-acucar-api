require "spec_helper"

RSpec.describe Endpoints::Refusals do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./schema/schema.json"
  end

  before do
    @user = User.create(
      email: 'foo@bar.com',
      first_name: 'Foo',
      last_name: 'Bar',
      encrypted_password: 'foobar',
      latitude: 30,
      longitude: 51,
    )
    @token = @user.add_token({client: 'foo', token: 'bar'})
    @demand = Demand.create(
      user: @user,
      name: 'Foo',
      description: 'Bar',
      latitude: 30,
      longitude: 50,
      radius: 1,
    )
  end

  before :each do
    header "Token-Type", "Bearer"
    header "Client", 'foo'
    header "Access-Token", 'bar'
    header "Uid", @user.id
    header "Expiry", @token.expiry
  end

  describe 'POST /refusals' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/refusals', MultiJson.encode({
        demand_id: @demand.id,
      })
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end
end
