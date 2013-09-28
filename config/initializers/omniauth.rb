Rails.application.config.middleware.use OmniAuth::Builder do
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development? 
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET'] 
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'] , :scope => 'email'
end
