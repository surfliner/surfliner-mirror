# This initializer is responsible for loading all consumer public keys into Rails.application.config.signature_keys
#
#  Each key is loaded as an instance of the `OpenSSL::PKey::RSA` class for signature verifaction
#
# The `CONSUMER_KEYS_FILE` is expected to be a YAML file of the form:
#  <consumer-name>: path/to/public-key
#
#  Example:
#  ---
#  tidewater: /keys/tidewater/ssh-publickey
#  shoreline /keys/shoreline/ssh-publickey
#
#  Usage:
#  > Rails.application.config.signature_keys[:tidewater].public_key

if ENV["CONSUMER_KEYS_FILE"].present?
  Rails.logger.info "Loading signature keys from : #{ENV["CONSUMER_KEYS_FILE"]}"

  begin
    Rails.application.config.signature_keys = YAML.safe_load_file(ENV["CONSUMER_KEYS_FILE"], symbolize_names: true)
      .transform_values! { |v| OpenSSL::PKey::RSA.new(File.read(v)) }
  rescue e
    Rails.logger.error "Error occurred trying to load signature keys from: #{ENV["CONSUMER_KEYS_FILE"]}"
    Rails.logger.error e
  end

  Rails.logger.debug "Signature keys loaded from: #{ENV["CONSUMER_KEYS_FILE"]}"
end
