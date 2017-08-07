require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class NumberTest < TestCase
    test "number without national prefix" do
      number = context.parse('82012345678', 'BY')
      assert number.valid?
      assert_equal '82012345678', number.national_string
    end

    test "number with national prefix" do
      number = context.parse('882012345678', 'BY')
      assert number.valid?
      assert_equal '82012345678', number.national_string
    end
  end
end
