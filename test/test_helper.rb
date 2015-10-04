require 'test/unit'
require 'mocha/setup'
require 'supermodel'
require 'global_phone'
require_relative '../lib/global_phone/validator'
require 'json'

module GlobalPhone
  class TestContext
    include Context
  end

  class TestCase < ::Test::Unit::TestCase
    undef_method :default_test if method_defined?(:default_test)

    def self.test(name, &block)
      define_method(:"test #{name.inspect}", &block)
    end

    def context
      @context ||= TestContext.new.tap do |context|
        context.db_path = fixture_path('record_data.json')
      end
    end

    def db
      context.db
    end

    def fixture_path(filename)
      File.expand_path("../fixtures/#{filename}", __FILE__)
    end

    def json_fixture(name)
      JSON.parse(File.read(fixture_path("#{name}.json")))
    end

    def example_numbers
      @example_numbers ||= json_fixture(:example_numbers)
    end

    def record_data
      @record_data ||= json_fixture(:record_data)
    end
  end
end
