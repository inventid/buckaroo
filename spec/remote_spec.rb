# encoding: utf-8
require 'coveralls'

Coveralls.wear!

require 'buckaroo'
require 'mocha'

def set_vars_from_env
  Buckaroo::Gateway.environment = :test
  Buckaroo::Gateway.website_key = ENV['website_key']
  Buckaroo::Gateway.secret = ENV['secret']
  Buckaroo::Gateway.locale = ENV['locale']
end

VALID_OPTIONS = {
    order_id: 1,
    return_url: 'http://www.inventid.nl',
    description: 'test',
    method: 'bancontactmrcash'
}

module Buckaroo

  class InvalidParameters

    describe Buckaroo do

      before(:each) do
        Buckaroo::Gateway.website_key = nil
        Buckaroo::Gateway.environment = nil
        Buckaroo::Gateway.locale = nil
        Buckaroo::Gateway.secret = nil

      end

      it 'should fail on negative numbers' do
        set_vars_from_env
        gateway = Buckaroo::Gateway.new
        response = gateway.setup_purchase('-1', VALID_OPTIONS)
        expect(response.verified?).to be true
        expect(response.success?).to be false
      end
    end
  end

  class CaptureTransaction

    describe 'Buckaroo' do


      it 'should create an valid request if remainder is ok' do
        set_vars_from_env
        gateway = Buckaroo::Gateway.new
        response = gateway.setup_purchase('1.00', VALID_OPTIONS)
        expect(response.verified?).to be true
        expect(response.success?).to be true
        expect(response.order_id).to eq(VALID_OPTIONS[:order_id].to_s)
        expect(response).to be_a TransactionResponse
      end

      describe 'capture' do
        it 'should create an valid status request if remainder is ok' do
          set_vars_from_env
          #Buckaroo::Gateway.environment = :live
          gateway = Buckaroo::Gateway.new
          response = gateway.setup_purchase('1.00', VALID_OPTIONS)
          expect(response.verified?).to be true
          expect(response.success?).to be true
          expect(response.order_id).to eq(VALID_OPTIONS[:order_id].to_s)
          expect(response.redirect_url).to match(/buckaroo/)
          expect(response).to be_a TransactionResponse

          transaction_id = response.transaction_id
          result = gateway.capture(transaction_id)
          expect(result.verified?).to be true
          expect(result.status).to eq('open')
          expect(result).to be_a StatusResponse
        end

        it 'should return failure if a payment was failed' do
          set_vars_from_env
          gateway = Buckaroo::Gateway.new
          transaction_id = 'F7B5BD0D19B24A6DB2A9BAE45919B5DB'
          result = gateway.capture(transaction_id)
          expect(result.status).to eq('failure')
          expect(result.verified?).to be true
          expect(result.test?).to be true
          expect(result).to be_a StatusResponse
        end

        it 'should return cancelled if the customer cancelled' do
          set_vars_from_env
          gateway = Buckaroo::Gateway.new
          transaction_id = 'EC99E0BD08CB4D06B17C6670F4FFDDAA'
          result = gateway.capture(transaction_id)
          expect(result.status).to eq('cancelled')
          expect(result.verified?).to be true
          expect(result.test?).to be true
          expect(result).to be_a StatusResponse
        end

        it 'should return success if the payment was OK' do
          set_vars_from_env
          gateway = Buckaroo::Gateway.new

          PAYPAL_OPTIONS = VALID_OPTIONS.dup
          PAYPAL_OPTIONS[:method] = 'paypal'
          response = gateway.setup_purchase('1.00', PAYPAL_OPTIONS)

          expect(response).to be_a TransactionResponse

          #transaction_id = 'EC99E0BD08CB4D06B17C6670F4FFDDAA'
          #result = gateway.capture(transaction_id)
          #expect(result.status).to eq('cancelled')
          #expect(result.verified?).to be true
          #expect(result.test?).to be true
        end
      end
    end
  end
end