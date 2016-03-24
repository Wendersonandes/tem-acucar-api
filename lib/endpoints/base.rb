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

    # Delay to simulate slow connections
    # before do
    #   sleep 3
    # end

    after do
      # Only set auth headers in successful responses
      return unless status >= 200 && status < 300
      # Set auth headers only if there is a current user
      set_auth_headers(current_user) if current_user && !@signed_out
    end

    private

    def authenticate!
      raise Pliny::Errors::Unauthorized unless current_user
    end

    def sign_in!(user, provider = 'email')
      Authentication.create({
        user: user,
        provider: provider,
        ip: request.ip,
      })
      set_auth_headers(user)
    end

    def sign_out!
      Token.valid.where(user: current_user, client: request.env['HTTP_CLIENT']).delete
      @signed_out = true
    end

    def set_auth_headers(user)
      client = request.env['HTTP_CLIENT'] || SecureRandom.urlsafe_base64(nil, false)
      access_token = SecureRandom.urlsafe_base64(nil, false)
      token = user.add_token(client: client, token: access_token)
      headers["Token-Type"] = "Bearer"
      headers["Client"] = client
      headers["Access-Token"] = access_token
      headers["Uid"] = user.id
      headers["Expiry"] = token.expiry
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
      current_user = nil
      Token.valid.where(user: user, client: client).reverse(:created_at).limit(20).each do |token|
        current_user = user if token.token == access_token
      end
      return unless current_user
      @current_user = current_user
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
