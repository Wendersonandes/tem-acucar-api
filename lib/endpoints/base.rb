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

    after do
      if current_user
        client = request.env['HTTP_CLIENT'] || SecureRandom.urlsafe_base64(nil, false)
        access_token = SecureRandom.urlsafe_base64(nil, false)
        token = current_user.add_token(token: access_token)
        headers["Token-Type"] = "Bearer"
        headers["Client"] = client
        headers["Access-Token"] = access_token
        headers["Uid"] = current_user.id
        headers["Expiry"] = token.expiry
      end
    end

    private

    def authenticate!
      raise Pliny::Errors::Unauthorized unless current_user
    end

    def current_user
      return @current_user if @current_user
      token_type = request.env['HTTP_TOKEN_TYPE']
      return unless token_type == 'Bearer'
      client = request.env['HTTP_CLIENT']
      return unless client
      uid = request.env['HTTP_UID']
      return unless uid && uid.match(/^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/)
      access_token = request.env['HTTP_ACCESS_TOKEN']
      return unless access_token
      user = User[uid]
      return unless user
      token = Token.valid.where(user: user, client: client).reverse(:created_at).first
      return unless token && token.token == access_token
      @current_user = user
    end

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
