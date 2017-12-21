require 'json'
require 'nokogiri'

module GlobalPhone
  class DatabaseGenerator
    VERSION = '1.0.0'

    def self.load_file(filename)
      load(File.read(filename))
    end

    def self.load(xml)
      new(Nokogiri.XML(xml))
    end

    attr_reader :doc

    def initialize(doc)
      @doc = doc
    end

    def test_cases
      @test_cases ||= territory_nodes.map do |node|
        example_numbers_for_territory_node(node)
      end.flatten(1)
    end

    def record_data
      @record_data ||= territory_nodes_by_region.map do |country_code, territory_nodes|
        truncate(compile_region(territory_nodes, country_code))
      end
    end

    def inspect
      "#<#{self.class.name} (#{doc.search("*").size} elements)>"
    end

    protected

      def territory_nodes
        doc.search("territory")
      end

      def territory_nodes_by_region
        territory_nodes.group_by { |node| node["countryCode"] }
      end

      def territory_name(node)
        node["id"]
      end

      def example_numbers_for_territory_node(node)
        name = territory_name(node)
        return [] if name == "001"
        node.search(example_numbers_selector).map { |node| [node.text, name] }
      end

      def example_numbers_selector
        "./*[" + phone_number_types.map do |type|
          "self::#{type}"
        end.join(" or ") + "]/exampleNumber"
      end

      def compile_region(territory_nodes, country_code)
        territories, main_territory_node = compile_territories(territory_nodes)
        formats = compile_formats(territory_nodes)

        [
          country_code,
          formats,
          territories,
          main_territory_node["internationalPrefix"],
          main_territory_node["nationalPrefix"],
          squish(main_territory_node["nationalPrefixForParsing"]),
          squish(main_territory_node["nationalPrefixTransformRule"])
        ]
      end

      def compile_territories(territory_nodes)
        territories = []
        main_territory_node = territory_nodes.first

        territory_nodes.each do |node|
          territory = truncate(compile_territory(node))
          if node["mainCountryForCode"]
            main_territory_node = node
            territories.unshift(territory)
          else
            territories.push(territory)
          end
        end

        [territories, main_territory_node]
      end

    def possible_lengths_for_territory_node(node)
      name = territory_name(node)
      return [] if name == '001'
      node.search(possible_lengths_selector).flat_map { |child_node| parse_possible_lengths(child_node.text) }.uniq.sort
    end

    def possible_lengths_selector
      './*[' + phone_number_types.map do |type|
        "self::#{type}"
      end.join(' or ') + "]/possibleLengths/@*[name()='national' or name()='localOnly']"
    end

    def parse_possible_lengths(lengths)
      lengths.split(',').flat_map do |length_set|
        if length_set =~ /^\[(\d+)-(\d+)\]$/
          (Regexp.last_match(1).to_i..Regexp.last_match(2).to_i).to_a
        else
          length_set.to_i
        end
      end
    end

    def phone_number_types
      %w(fixedLine mobile pager personalNumber premiumRate sharedCost tollFree uan voicemail voip)
    end

    def compile_territory(node)
      [
        territory_name(node),
        pattern(node, "generalDesc nationalNumberPattern"),
        squish(node["nationalPrefixFormattingRule"]),
        possible_lengths_for_territory_node(node),
        pattern(node, 'fixedLine nationalNumberPattern'),
        pattern(node, 'mobile nationalNumberPattern'),
        pattern(node, 'pager nationalNumberPattern'),
        pattern(node, 'tollFree nationalNumberPattern'),
        pattern(node, 'premiumRate nationalNumberPattern'),
        pattern(node, 'sharedCost nationalNumberPattern'),
        pattern(node, 'personalNumber nationalNumberPattern'),
        pattern(node, 'voip nationalNumberPattern'),
        pattern(node, 'uan nationalNumberPattern'),
        pattern(node, 'voicemail nationalNumberPattern')
      ]
    end

      def compile_formats(territory_nodes)
        format_nodes_for(territory_nodes).map do |node|
          truncate(compile_format(node))
        end
      end

      def compile_format(node)
        [
          node["pattern"],
          text_or_nil(node, "format"),
          pattern(node, "leadingDigits"),
          node["nationalPrefixFormattingRule"],
          text_or_nil(node, "intlFormat")
        ]
      end

      def format_nodes_for(territory_nodes)
        territory_nodes.map do |node|
          node.search("availableFormats numberFormat").to_a
        end.flatten
      end

      def truncate(array)
        array.dup.tap do |result|
          result.pop while result.any? && result.last.nil?
        end
      end

      def squish(string)
        string.gsub(/\s+/, "") if string
      end

      def pattern(node, selector)
        squish(text_or_nil(node, selector))
      end

      def text_or_nil(node, selector)
        nodes = node.search(selector)
        nodes.empty? ? nil : nodes.text
      end
  end
end
