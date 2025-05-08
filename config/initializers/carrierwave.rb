unless Rails.env.development? || Rails.env.test?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV["AWS_KEY"],
      aws_secret_access_key: ENV["AWS_SECRET_KEY"],
      region: "ap-northeast-1"
    }

    config.fog_directory  = "ekipuratto-photo"
    config.cache_storage = :fog
    config.fog_provider = "fog/aws"
    config.fog_public = false
  end
end
