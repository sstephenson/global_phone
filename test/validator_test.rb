require File.expand_path('../test_helper', __FILE__)

class User < SuperModel::Base
  include ActiveModel::Validations::Callbacks
end

class GlobalPhoneValidatorTest < GlobalPhone::TestCase
  COUNTRY_CODE               = 'AU'

  INVALID_PHONE_NUMBER       = '(06) 9876 0010'
  LOCAL_PHONE_NUMBER         = '9876 0010'
  NATIONAL_PHONE_NUMBER      = '(03) 9876 0010'
  INTERNATIONAL_PHONE_NUMBER = '+61 3 9876 0010'

  ATTRIBUTE              = :work_mobile
  COUNTRY_CODE_ATTRIBUTE = :work_country_code
  WORK_MOBILE            = '0432 101 234'

  DEFAULT_MESSAGE =
    "is not a valid phone number in region -  (Try using international format '+61 3 9876 0010')"
  DEFAULT_MESSAGE_WITH_COUNTRY_CODE =
    "is not a valid phone number in region - #{COUNTRY_CODE} (Try using international format '+61 3 9876 0010')"

  def setup
    @validator = nil
    GlobalPhone.db_path = fixture_path('record_data.json')
  end

  def validator
    @validator ||= GlobalPhoneValidator.new({attributes: [ATTRIBUTE]}.merge(@validator_options))
  end

  def model
    @model ||= User.new.tap { |u|
      u.stubs(ATTRIBUTE).returns(WORK_MOBILE)
      u.stubs(COUNTRY_CODE_ATTRIBUTE).returns(@work_country_code)
    }
  end

  def using_country_code
    @work_country_code = 'AU'
    @validator_options = { using: COUNTRY_CODE_ATTRIBUTE }
  end


  def subject(work_country_code, validator_options, phone_number)
    @work_country_code = work_country_code
    @validator_options = validator_options
    validator.validate_each(model, ATTRIBUTE, phone_number)
  end


  test "when using country_code and an invalid phone number" do
    subject('AU', { using: COUNTRY_CODE_ATTRIBUTE }, INVALID_PHONE_NUMBER)
    assert_equal model.errors, {ATTRIBUTE=>[DEFAULT_MESSAGE_WITH_COUNTRY_CODE]}
  end

  test "when using country_code and a local phone number" do
    subject('AU', { using: COUNTRY_CODE_ATTRIBUTE }, LOCAL_PHONE_NUMBER)
    assert_equal model.errors, {ATTRIBUTE=>[DEFAULT_MESSAGE_WITH_COUNTRY_CODE]}
  end

  test "when using country_code and a national phone number" do
    subject('AU', { using: COUNTRY_CODE_ATTRIBUTE }, NATIONAL_PHONE_NUMBER)
    assert_equal model.errors, {}
  end

  test "when using country_code and an international phone number" do
    subject('AU', { using: COUNTRY_CODE_ATTRIBUTE }, INTERNATIONAL_PHONE_NUMBER)
    assert_equal model.errors, {}
  end

  test "when not using country_code and an invalid phone number" do
    subject(nil, { }, INVALID_PHONE_NUMBER)
    assert_equal model.errors, {ATTRIBUTE=>[DEFAULT_MESSAGE]}
  end

  test "when not using country_code and a local phone number" do
    subject(nil, { }, LOCAL_PHONE_NUMBER)
    assert_equal model.errors, {ATTRIBUTE=>[DEFAULT_MESSAGE]}
  end

  test "when not using country_code and a national phone number" do
    subject(nil, { }, NATIONAL_PHONE_NUMBER)
    assert_equal model.errors, {ATTRIBUTE=>[DEFAULT_MESSAGE]}
  end

  test "when not using country_code and an international phone number" do
    subject(nil, { }, INTERNATIONAL_PHONE_NUMBER)
    assert_equal model.errors, {}
  end

  test "README example 1" do
    class Person < SuperModel::Base
      validates :home_phone, :global_phone => true
    end

    assert_equal true, Person.new(home_phone: INTERNATIONAL_PHONE_NUMBER).valid?
  end

  test "README example 2" do
    class User < SuperModel::Base
      validates :work_phone, :global_phone => { :using => :work_country_code }

      def work_country_code
        'AU'
      end
    end

    assert_equal true, User.new(work_phone: NATIONAL_PHONE_NUMBER).valid?
  end
end
