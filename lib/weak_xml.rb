require "weak_xml/version"

class WeakXml
  require_relative "./weak_xml/fragment"

  def self.find(tag, xml, options = {})
    if matched_string = xml[regex_factory(tag, options)]
      Fragment.new(tag, matched_string)
    end
  end

  def self.find_all(tag, xml, options = {})
    xml.scan(regex_factory(tag, options)).map! do |match|
      Fragment.new(tag, match)
    end
  end

  def self.regex_factory(tag, options = {})
    enable_multiline = !options[:disable_multiline]

    regexp_base =
    if tag.start_with?("<") && tag.end_with?(">")
      "#{tag}.*?<\/#{tag[1..-2]}>"
    else
      "<#{tag}[>\s].*?<\/#{tag}>"
    end

    Regexp.new(regexp_base, (enable_multiline ? Regexp::MULTILINE : 0))
  end

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
