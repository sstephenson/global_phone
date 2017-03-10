require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class ContextTest < TestCase
    test "requires db_path to be set" do
      context = TestContext.new
      assert_raises(NoDatabaseError) { context.db }
    end

    test "parsing international number" do
      assert_parses "+1-312-555-1212",
        :country_code => "1", :national_string => "3125551212"
    end

    test "parsing national number in default territory" do
      assert_parses "(312) 555-1212",
        :country_code => "1", :national_string => "3125551212"
    end

    test "parsing national number for given territory" do
      assert_parses "(0) 20-7031-3000", :with_territory => :gb,
        :country_code => "44", :national_string => "2070313000"
    end

    test "parsing national number for given territory with leading country code" do
      assert_parses "3914172422", :with_territory => :it,
                    :country_code => "39", :national_string => "3914172422"
    end

    test "parsing international number with prefix" do
      assert_parses "00 1 3125551212", :with_territory => :gb,
        :country_code => "1", :national_string => "3125551212"
    end

    test "parsing international number with country code prefix but no plus" do
      assert_parses "(504) 2221-6592", :with_territory => :hn,
        :country_code => "504", :national_string => "22216592"
    end

    test "changing the default territory" do
      assert_does_not_parse "(0) 20-7031-3000"

      context.default_territory_name = :gb

      assert_parses "(0) 20-7031-3000",
        :country_code => "44", :national_string => "2070313000"
    end

    test "validating an international number" do
      assert context.validate("+1-312-555-1212")
      assert context.validate("+442070313000")
      assert !context.validate("+12345")
    end

    test "validating a national number" do
      assert context.validate("312-555-1212")
      assert !context.validate("(0) 20-7031-3000")
      assert context.validate("(0) 20-7031-3000", :gb)
    end

    test "normalizing an international number" do
      assert_equal "+13125551212", context.normalize("+1 312-555-1212")
      assert_equal "+442070313000", context.normalize("+44 (0) 20-7031-3000")
      assert_equal "+442070313000", context.normalize("+442070313000")
      assert_nil context.normalize("+12345")
    end

    test "normalizing a national number" do
      assert_equal "+13125551212", context.normalize("(312) 555-1212")
      assert_nil context.normalize("(0) 20-7031-3000")
      assert_equal "+442070313000", context.normalize("(0) 20-7031-3000", :gb)
    end

    test "validateing an invalid number returns nil" do
      assert !context.validate("+0651816068")
      assert_nil context.validate("+0651816068")
    end

    def assert_parses(string, assertions)
      territory_name = assertions.delete(:with_territory) || context.default_territory_name
      number = context.parse(string, territory_name)
      assert_kind_of Number, number
      assert_equal({ :country_code => number.country_code, :national_string => number.national_string }, assertions)
    end

    def assert_does_not_parse(string, options = {})
      territory_name = options.delete(:with_territory) || context.default_territory_name
      number = context.parse(string, territory_name)
      assert_nil number, "expected #{string} not to parse for territory #{territory_name}"
    end
  end
end
