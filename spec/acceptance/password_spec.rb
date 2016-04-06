require "spec_helper"

RSpec.describe Endpoints::Password do
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
      password: 'foobarfoo',
    )
    @user.password_token = 'foobar'
    @user.save

    # Stubs Sendgrid API
    module ::SendGrid
      class FakeResponse
        def code
          200
        end
      end
      class TemplateMailer
        def mail(config)
          FakeResponse.new
        end
      end
    end
  end

  describe 'POST /password' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/password', MultiJson.encode({
        email: 'foo@bar.com',
      })
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end

  describe 'PUT /password' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      put '/password', MultiJson.encode({
        email: 'foo@bar.com',
        password: 'foobarfoo',
        token: 'foobar',
      })
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
