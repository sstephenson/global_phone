require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class SmokeTest < TestCase
    test "parsing example numbers" do
      example_numbers.each do |(string, territory_name)|
        assert_parses string, territory_name
      end
    end

    def assert_parses(string, territory_name)
      number = context.parse(string, territory_name)
      assert_kind_of Number, number, "expected #{string} to parse for territory #{territory_name}"
      assert number.valid?, "expected #{string} to be valid for territory #{territory_name}"
      assert_not_nil number.national_string
      assert_not_nil number.national_format
      assert_not_nil number.international_string
      assert_not_nil number.international_format
    end
  end
end
