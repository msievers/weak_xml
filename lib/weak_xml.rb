require "weak_xml/version"

class WeakXml
  require_relative "./weak_xml/fragment"

  #
  # class methods
  #
  def self.find(tag, xml, options = {})
    match_data = xml.match(regex_factory(tag, options))
    Fragment.new(tag, *match_data.captures.rotate!) if match_data
  end

  def self.find_all(tag, xml, options = {})
    xml.scan(regex_factory(tag, options)).map! do |_captures|
      Fragment.new(tag, *_captures.rotate!)
    end
  end

  def self.regex_factory(tag, options = {})
    enable_multiline = !options[:disable_multiline]

    regexp_base =
    if tag.start_with?("<") && tag.end_with?(">")
      "<#{tag[1..-2]}>(.*?)<\/#{tag[1..-2]}>"
    else
      "<#{tag}(\\s+.*?)?>(.*?)<\/#{tag}>"
    end

    Regexp.new(regexp_base, (enable_multiline ? Regexp::MULTILINE : 0))
  end

  #
  # instance methods
  #
  def initialize(xml, options = {})
    @options = options
    @xml = xml
  end

  def find(tag, options = nil)
    self.class.find(tag, @xml, (options || @options))
  end

  def find_all(tag, options = nil)
    self.class.find_all(tag, @xml, (options || @options))
  end
end
