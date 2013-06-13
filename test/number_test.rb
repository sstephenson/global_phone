require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class NumberTest < TestCase
    test "valid number" do
      number = context.parse("(312) 555-1212")
      assert number.valid?
    end

    test "type" do
      number = context.parse("(312) 555-1212")
      assert_equal :fixed_line_or_mobile, number.type
    end

    test "fixed_line?" do
      number = context.parse("+8602152821021")
      assert number.fixed_line?

      number = context.parse("+8615800681509")
      assert !number.fixed_line?
    end

    test "mobile?" do
      number = context.parse("+8602152821021")
      assert !number.mobile?

      number = context.parse("+8615800681509")
      assert number.mobile?
    end

    test "country_code" do
      number = context.parse("(312) 555-1212")
      assert_equal "1", number.country_code

      number = context.parse("+44 (0) 20-7031-3000")
      assert_equal "44", number.country_code
    end

    test "region" do
      number = context.parse("(312) 555-1212")
      assert_equal db.region(1), number.region

      number = context.parse("+44 (0) 20-7031-3000")
      assert_equal db.region(44), number.region
    end

    test "territory" do
      number = context.parse("(312) 555-1212")
      assert_equal db.territory(:us), number.territory

      number = context.parse("+44 (0) 20-7031-3000")
      assert_equal db.territory(:gb), number.territory
    end

    test "national_string" do
      number = context.parse("(312) 555-1212")
      assert_equal "3125551212", number.national_string
    end

    test "national_format" do
      number = context.parse("312-555-1212")
      assert_equal "(312) 555-1212", number.national_format
    end

    test "international_string" do
      number = context.parse("(312) 555-1212")
      assert_equal "+13125551212", number.international_string
      assert_equal number.international_string, number.to_s
    end

    test "international_format" do
      number = context.parse("(312) 555-1212")
      assert_equal "+1 312-555-1212", number.international_format
    end
  end
end
