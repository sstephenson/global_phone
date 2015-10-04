require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class NumberTest < TestCase
    test "valid number" do
      number = context.parse("(312) 555-1212")
      assert number.valid?
    end

    test "valid number with multiple territories" do
      number = context.parse("+7 717 270 2999")
      assert_equal db.territory(:kz), number.territory
    end

    test "invalid number" do
      number = context.parse("555-1212")
      assert !number.valid?
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

    test "partial matches do not validate" do
      # Guatemala has eight digit phone numbers, but the number 5555
      # 1234 123 still got through the matcher.
      # 
      # The regex is /^[2-7]\d{7}|1[89]\d{9}$/, but with =~ matching a
      # partial match is still possible.
      # 
      # I think this might actually be a broken regex, but changing
      # the code seems better than mucking about with all the regex's
      # from google.
      number = context.parse("5555 1234 123", :gt)
      assert !number || !number.valid?
    end

    test "national format with or in regex still works with correct number" do
      number = context.parse("5555 2134", :gt)
      assert number.valid?
    end


  end
end
