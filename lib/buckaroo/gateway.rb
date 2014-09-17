# encoding: utf-8

require 'net/https'
require 'digest/sha2'
require 'addressable/uri'
require 'base64'
require 'openssl'
require 'buckaroo/urls'


module Buckaroo
  class Gateway
    LANGUAGE = 'nl'
    CURRENCY = 'EUR'

    class << self
      # Holds the environment in which the run (default is test)
      attr_accessor :environment

      # Holds the global iDEAL merchant id. Make sure to use a string with
      # leading zeroes if needed.
      attr_accessor :website_key

      # Holds the secret that should be used for the website key.
      attr_accessor :secret

      # Holds the users locale
      attr_accessor :locale
    end

    # Environment defaults to test
    self.environment = :test

    # Returns whether we're in test mode or not.
    def self.test?
      if self.environment.nil?
        self.environment = :test
      end
      self.environment == :test
    end

    # Returns the endpoint for the request.
    #
    # Automatically uses test or live URLs based on the configuration.
    def request_url(operation)
      if self.class.test?
        url = URLS[:test_url]
      else
        url = URLS[:live_url]
      end
      return url if operation.nil?
      url + '?op=' + operation
    end

    # TODO: Add comment here
    def setup_purchase(money, options)
      config_complete!
      requires!(options, :order_id, :return_url, :description, :method)

      req = build_transaction_request(money, options)
      post_data request_url('transactionrequest'), req, TransactionResponse
    end

    # Sends a status request for the specified +transaction_id+ and
    # returns an StatusResponse.
    #
    # It is _your_ responsibility as the merchant to check if the payment has
    # been made until you receive a response with a finished status like:
    # `Success', `Cancelled', `Expired', everything else equals `Open'.
    #
    # === Example
    #
    #   capture_response = gateway.capture(@purchase.transaction_id)
    #   if capture_response.success?
    #     @purchase.update_attributes!(:paid => true)
    #     flash[:notice] = "Congratulations, you are now the proud owner of a Dutch windmill!"
    #   end
    #
    # See the Gateway class description for a more elaborate example.
    def capture(transaction_id)
      config_complete!

      a = build_status_request(transaction_id)
      post_data request_url('transactionstatus'), a, StatusResponse
    end

    private

    def ssl_post(url, params)
      log('URL', url)
      log('Request', params)
      response = Net::HTTP.post_form(URI.parse(url), params)
      log('Response', response.body)
      response
    end

    def post_data(gateway_url, data, response_klass)
      response_klass.new(ssl_post(gateway_url, data))
    end

    def requires!(options, *keys)
      missing = keys - options.keys
      unless missing.empty?
        raise ArgumentError, "Missing required options: #{missing.map { |m| m.to_s }.join(', ')}"
      end
    end

    def build_status_request(transaction_id)
      data = {
          brq_websitekey: self.class.website_key,
          brq_transaction: transaction_id,
          brq_test: self.class.test?
      }

      sign!(data)
    end

    def build_transaction_request(amount, options)
      data = {
          brq_payment_method: options[:method],
          brq_websitekey: self.class.website_key,
          brq_culture: self.class.locale,
          brq_currency: CURRENCY,
          brq_amount: amount,
          brq_invoicenumber: options[:order_id],
          brq_ordernumber: options[:order_id],
          brq_description: options[:description],
          brq_return: options[:return_url],
          brq_returncancel: '',
          brq_returnerror: '',
          brq_returnreject: '',
          brq_continue_on_incomplete: 'RedirectToHTML',
          brq_test: self.class.test?
      }
      extra = 'brq_service_'+options[:method]+'_action'
      data[extra] = 'Pay'

      sign!(data)
    end

    def sign!(input)
      sorted_data = input.sort_by { |key, _| key.to_s }

      to_hash = ''
      sorted_data.each { |key, value| to_hash << key.to_s+'='+value.to_s }
      to_hash << self.class.secret
      input['brq_signature'] = Digest::SHA512.hexdigest(to_hash)
      input
    end

    def config_complete!
      if self.class.website_key.to_s.empty? || self.class.secret.to_s.empty? || self.class.locale.to_s.empty?
        raise ArgumentError, "Required config is not done"
      end
    end

    def log(thing, contents)
      $stderr.write("\n#{thing}:\n\n#{contents}\n") if $DEBUG
    end
  end
end