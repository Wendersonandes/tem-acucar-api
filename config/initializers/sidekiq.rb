Sidekiq.configure_server do |config|
  config.redis = { db: 1 }

  config.server_middleware do |chain|
    chain.add Pliny::Sidekiq::Middleware::Server::RequestId
    chain.add Pliny::Sidekiq::Middleware::Server::Log, metric_prefix: 'my-app'
  end

  config.client_middleware do |chain|
    chain.add Pliny::Sidekiq::Middleware::Client::RequestId
    chain.add Pliny::Sidekiq::Middleware::Client::Log
  end
end

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }

  config.client_middleware do |chain|
    chain.add Pliny::Sidekiq::Middleware::Client::RequestId
    chain.add Pliny::Sidekiq::Middleware::Client::Log
  end
end
