web: bundle exec puma --config config/puma.rb config.ru
worker: bundle exec sidekiq -r ./lib/application.rb -c 5 -e production
