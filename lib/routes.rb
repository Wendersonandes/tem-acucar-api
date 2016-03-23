Routes = Rack::Builder.new do
  use Rollbar::Middleware::Sinatra
  use Pliny::Middleware::CORS
  use Pliny::Middleware::RequestID
  use Pliny::Middleware::Instruments
  use Pliny::Middleware::RescueErrors, raise: Config.raise_errors?
  use Pliny::Middleware::RequestStore, store: Pliny::RequestStore
  use Rack::Timeout if Config.timeout > 0
  use Pliny::Middleware::Versioning,
      default: Config.versioning_default,
      app_name: Config.versioning_app_name if Config.versioning?
  use Rack::Deflater
  use Rack::MethodOverride
  use Rack::SSL if Config.force_ssl?
  use Committee::Middleware::RequestValidation, schema: JSON.parse(File.read("#{Config.root}/schema/schema.json"))
  use Committee::Middleware::ResponseValidation, schema: JSON.parse(File.read("#{Config.root}/schema/schema.json"))

  use Pliny::Router do
    # mount all endpoints here
    mount Endpoints::Health
    mount Endpoints::Schema
    mount Endpoints::Versions
    mount Endpoints::Authentications
    mount Endpoints::Password
    mount Endpoints::Users
    mount Endpoints::Me
    mount Endpoints::Demands
    mount Endpoints::Refusals
    mount Endpoints::Flags
    mount Endpoints::Transactions
    mount Endpoints::Messages
  end

  # root app; but will also handle some defaults like 404
  run Endpoints::Root
end
