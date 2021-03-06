if Rails.env.production?

  Sidekiq.configure_client do |config|
    config.redis = { size: 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { size: 10 }
  end
end
