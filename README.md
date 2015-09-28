# GlobalPhone

GlobalPhone parses, validates, and formats local and international phone numbers according to the [E.164 standard](http://en.wikipedia.org/wiki/E.164).

**Store and display phone numbers in your app.** Accept phone number input in national or international format. Convert phone numbers to international strings (`+13125551212`) for storage and retrieval. Present numbers in national format (`(312) 555-1212`) in your UI.

**Designed with the future in mind.** GlobalPhone uses format specifications from Google's open-source [libphonenumber](https://github.com/googlei18n/libphonenumber) database. No need to upgrade the library when a new phone format is introduced—just generate a new copy of the database and check it into your app.

**Pure Ruby. No dependencies.** GlobalPhone is designed for Ruby 1.9.3 and up. (Works in 1.8.7, too—just bring your own `json` gem.)

## Installation

1. Add the `global_phone` gem to your app. For example, using Bundler:

        $ echo "gem 'global_phone'" >> Gemfile
        $ bundle install

2. Use `global_phone_dbgen` to convert Google's libphonenumber `PhoneNumberMetaData.xml` file into a JSON database for GlobalPhone.

        $ gem install global_phone_dbgen
        $ global_phone_dbgen > db/global_phone.json

3. Tell GlobalPhone where to find the database. For example, in a Rails app, create an initializer in `config/initializers/global_phone.rb`:

    ```ruby
    require 'global_phone'
    GlobalPhone.db_path = Rails.root.join('db/global_phone.json')
    ```

## Examples

Parse an international number string into a `GlobalPhone::Number` object:

```ruby
number = GlobalPhone.parse('+1-312-555-1212')
# => #<GlobalPhone::Number territory=#<GlobalPhone::Territory country_code=1 name=US> national_string="3125551212">
```

Query the country code and likely territory name of the number:

```ruby
number.country_code
# => "1"

number.territory.name
# => "US"
```

Present the number in national and international formats:

```ruby
number.national_format
# => "(312) 555-1212"

number.international_format
# => "+1 312-555-1212"
```

Is the number valid? (Note: this is not definitive. For example, the number here is "valid" by format, but there are no US numbers that start with 555. The `valid?` method may return false positives, but *should not* return false negatives unless the database is out of date.)

```ruby
number.valid?
# => true
```

Get the number's normalized E.164 international string:

```ruby
number.international_string
# => "+13125551212"
```

Parse a number in national format for a given territory:

```ruby
number = GlobalPhone.parse("(0) 20-7031-3000", :gb)
# => #<GlobalPhone::Number territory=#<GlobalPhone::Territory country_code=44 name=GB> national_string="2070313000">
```

Parse an international number using a territory's international dialing prefix:

```ruby
number = GlobalPhone.parse("00 1 3125551212", :gb)
# => #<GlobalPhone::Number territory=#<GlobalPhone::Territory country_code=1 name=US> national_string="3125551212">
```

Set the default territory to Great Britain (territory names are [ISO 3166-1 Alpha-2](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) codes):

```ruby
GlobalPhone.default_territory_name = :gb
# => :gb

GlobalPhone.parse("(0) 20-7031-3000")
# => #<GlobalPhone::Number territory=#<GlobalPhone::Territory country_code=44 name=GB> national_string="2070313000">
```

Shortcuts for validating a phone number:

```ruby
GlobalPhone.validate("+1 312-555-1212")
# => true

GlobalPhone.validate("+442070313000")
# => true

GlobalPhone.validate("(0) 20-7031-3000")
# => false

GlobalPhone.validate("(0) 20-7031-3000", :gb)
# => true
```

Shortcuts for normalizing a phone number in E.164 format:

```ruby
GlobalPhone.normalize("(312) 555-1212")
# => "+13125551212"

GlobalPhone.normalize("+442070313000")
# => "+442070313000"

GlobalPhone.normalize("(0) 20-7031-3000")
# => nil

GlobalPhone.normalize("(0) 20-7031-3000", :gb)
# => "+442070313000"
```

## Caveats

GlobalPhone currently does not parse emergency numbers or SMS short code numbers.

Validation is not definitive and may return false positives, but *should not* return false negatives unless the database is out of date.

Territory heuristics are imprecise. Parsing a number will usually result in the territory being set to the primary territory of the region. For example, Canadian numbers will be parsed with a territory of `US`. (In most cases this does not matter, but if your application needs to perform geolocation using phone numbers, GlobalPhone may not be a good fit.)

## Development

The GlobalPhone source code is [hosted on GitHub](https://github.com/sstephenson/global_phone). You can check out a copy of the latest code using Git:

    $ git clone https://github.com/sstephenson/global_phone.git

If you've found a bug or have a question, please open an issue on the [issue tracker](https://github.com/sstephenson/global_phone/issues). Or, clone the GlobalPhone repository, write a failing test case, fix the bug, and submit a pull request.

GlobalPhone is heavily inspired by Andreas Gal's [PhoneNumber.js](https://github.com/andreasgal/PhoneNumber.js) library.

### Version History

**1.0.1** (May 29, 2013)

* GlobalPhone::Number#to_s returns the E.164 international string.
* Ensure GlobalPhone::Number always returns strings for #national_format, #international_format, and #international_string, regardless of validity.
* Relax format restrictions to more loosely match available national number patterns.

**1.0.0** (May 28, 2013)

* Initial public release.

### License

Copyright &copy; 2013 Sam Stephenson

Released under the MIT license. See [`LICENSE`](LICENSE) for details.
