module Workers
  # The base class for all workers. Use sparingly.
  class Base
    include Sidekiq::Worker
  end
end
