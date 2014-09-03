# encoding: utf-8
require 'coveralls'

Coveralls.wear!

require 'buckaroo'
require 'mocha'

module Buckaroo

  class RequestGeneration

    describe Buckaroo do

      VALID_OPTIONS = {
          order_id: 1,
          return_url: 'http://www.inventid.nl',
          description: 'test',
          method: 'bancontactmrcash'
      }

      before(:each) do
        Buckaroo::Gateway.website_key = nil
        Buckaroo::Gateway.environment = nil
        Buckaroo::Gateway.locale = nil
        Buckaroo::Gateway.secret = nil

      end

      describe '#test?' do
        it 'should return true by default since we are using the test environment' do
          expect(Buckaroo::Gateway.test?).to be true
        end

        it 'should return false it we override to the live environment' do
          Buckaroo::Gateway.environment = :live
          expect(Buckaroo::Gateway.test?).to be false
        end
      end

      describe 'request_url' do
        it 'should return the test url in the setup test environment' do
          Buckaroo::Gateway.environment = :test
          gateway = Buckaroo::Gateway.new
          expect(gateway.request_url(nil)).to eq(URLS[:test_url])
        end

        it 'should return the test url in the setup test environment' do
          Buckaroo::Gateway.environment = :live
          gateway = Buckaroo::Gateway.new
          expect(gateway.request_url(nil)).to eq(URLS[:live_url])
        end
      end

      describe 'setup_purchase' do
        it 'should throw an error about missing parameters' do
          Buckaroo::Gateway.environment = :test
          gateway = Buckaroo::Gateway.new
          Buckaroo::Gateway.website_key = 'test'
          Buckaroo::Gateway.secret = 'test'
          Buckaroo::Gateway.locale = 'test'
          expect { gateway.setup_purchase('10.00', {return_url: 'http://example.com', description: 'test', method: 'paypal'}) }.to raise_error(ArgumentError)
          expect { gateway.setup_purchase('10.00', {order_id: 4, description: 'test', method: 'paypal'}) }.to raise_error(ArgumentError)
          expect { gateway.setup_purchase('10.00', {return_url: 'http://example.com', order_id: 'test', method: 'paypal'}) }.to raise_error(ArgumentError)
          expect { gateway.setup_purchase('10.00', {return_url: 'http://example.com', description: 'test', method: 'paypal'}) }.to raise_error(ArgumentError)
        end

        it 'should fail because of missing config' do
          Buckaroo::Gateway.environment = :test
          gateway = Buckaroo::Gateway.new
          expect { gateway.setup_purchase('10.00', VALID_OPTIONS) }.to raise_error(ArgumentError)
          Buckaroo::Gateway.website_key = ENV['website_key']
          expect { gateway.setup_purchase('10.00', VALID_OPTIONS) }.to raise_error(ArgumentError)
          Buckaroo::Gateway.secret = ENV['secret']
          expect { gateway.setup_purchase('10.00', VALID_OPTIONS) }.to raise_error(ArgumentError)
          Buckaroo::Gateway.locale = ENV['locale']
          Buckaroo::Gateway.locale = nil
          expect { gateway.setup_purchase('10.00', VALID_OPTIONS) }.to raise_error(ArgumentError)
        end

      end

      describe 'capture' do
        it 'should fail because of missing config' do
          Buckaroo::Gateway.environment = :test
          gateway = Buckaroo::Gateway.new
          expect { gateway.capture('1234') }.to raise_error(ArgumentError)
          Buckaroo::Gateway.website_key = ENV['website_key']
          expect { gateway.capture('1234') }.to raise_error(ArgumentError)
          Buckaroo::Gateway.secret = ENV['secret']
          expect { gateway.capture('1234') }.to raise_error(ArgumentError)
          Buckaroo::Gateway.locale = ENV['locale']
          Buckaroo::Gateway.locale = nil
          expect { gateway.capture('1234') }.to raise_error(ArgumentError)
        end
      end
    end
  end
end

