module Endpoints
  # The base class for all Sinatra-based endpoints. Use sparingly.
  class Base < Sinatra::Base
    register Sinatra::Namespace

    helpers Pliny::Helpers::Encode
    helpers Pliny::Helpers::Params

    set :dump_errors, false
    set :raise_errors, true
    set :root, Config.root
    set :show_exceptions, false

    configure :development do
      register Sinatra::Reloader
      also_reload "#{Config.root}/lib/**/*.rb"
    end

    error Sinatra::NotFound do
      raise Pliny::Errors::NotFound
    end

    private

    def error(id, message)
      error = Error.new(id, message)
      encode Serializers::Error.new(:default).serialize(error)
    end

    def errors(messages)
      id = messages.join('_and_').gsub(' ', '_')
      message = messages.join(', ')
      error(id, message)
    end
  end
end
