Rails.application.config.middleware.use OmniAuth::Builder do
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development? 
  provider :twitter, CONFIG['twitter_key'], CONFIG['twitter_secret']
  provider :facebook, CONFIG['facebook_key'], CONFIG['facebook_secret'] , :scope => 'email'
end
