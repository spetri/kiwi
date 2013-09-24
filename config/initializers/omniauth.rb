Rails.application.config.middleware.use OmniAuth::Builder do
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development? 
  provider :twitter, "912tZV4jxlwOlwNuISVGpA", "ShyES9pxFEkziVPbQwcisjQTFunH2kyP956YXE"
  provider :facebook, "170557669803798", "adc0f4dbb83cd185ae05d532d2d8c431", :scope => 'email'
end
