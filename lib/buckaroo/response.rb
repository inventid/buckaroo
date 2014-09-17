# encoding: utf-8

require 'addressable/uri'
require 'digest/sha2'

module Buckaroo

  class Response
    attr_accessor :status_code

    def initialize(response, options = {})
      body = response.body
      @response = Hash[Addressable::URI.form_unencode(body)]
      @status_code = @response['BRQ_STATUSCODE'].to_i
      @success = !error_occurred?
      @test = @response['BRQ_TEST'].downcase == 'true' ? true : false
    end

    # Returns whether we're running in test mode
    def test?
      @test
    end

    # Returns whether the request was a success
    def success?
      @success
    end

    def verified?
      input = @response.dup
      given_hash = input['BRQ_SIGNATURE']
      input.delete('BRQ_SIGNATURE')
      # This might actually need some explanation why we are converting do lowercase here
      # Buckaroo specifies to sort these parameters, although the exact matter of sorting
      # is quite ambigious. So after quite a while of debugging, I discovered that by
      # sorting they do not use the ASCII based sorting Ruby uses. In fact, the sorting
      # is specified to place symbols first (which ASCII does, except for the underscore (_)
      # which is located between the capitals and lowercase letters (jeej ASCII!).
      # So in this case, by converting everything to lowercase before comparing, we ensure
      # that all symbols are in the table before the letters.
      #
      # Actual case where it went wrong: keys BRQ_TRANSACTIONS and BRQ_TRANSACTION_CANCELABLE
      # Ruby would sort these in this exact order, whereas Buckaroo would reverse them. And
      # since for hashing the reversal generates a totally different sequence, that would
      # break message validation.
      #
      # TLDR; Leave it with a downcase
      sorted_data = input.sort_by { |key, _| key.to_s.downcase }

      to_hash = ''
      sorted_data.each { |key, value| to_hash << key.to_s+'='+value.to_s }
      to_hash << Buckaroo::Gateway.secret

      Digest::SHA512.hexdigest(to_hash) == given_hash
    end

    private

    def error_occurred?
      !verified? || @status_code == 491 || @status_code == 492
    end

  end

  class TransactionResponse < Response
    def redirect_url
      @response['BRQ_REDIRECTURL']
    end

    def transaction_id
      @response['BRQ_TRANSACTIONS']
    end

    def order_id
      @response['BRQ_ORDERNUMBER']
    end

  end

  class StatusResponse < Response
    def status
      case @status_code
        when 190 then
          'success'
        when 490..690 then
          'failure'
        when 790..793 then
          'open'
        when 890..891 then
          'cancelled'
        else
          raise(Exception)
      end
    end

  end
end
