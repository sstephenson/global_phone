require File.expand_path('../test_helper', __FILE__)
require 'pry'
require 'stringio'

module GlobalPhone
  class ParsingTest < TestCase
    test "valid territory" do
      number = context.parse("+351 91 335 00 00", "PT")
      assert_not_nil number
      assert_kind_of Territory, number.territory
    end

    test "unknown territory" do
      stdout = StringIO.new
      $stdout = stdout
      number = context.parse("+93 1289312", "PN")
      $stdout = STDOUT

      assert_nil number
      assert_match 'unknown territory', stdout.string
    end
  end
end