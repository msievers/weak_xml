require "weak_xml/version"

class WeakXml
  # Compiling regular expressions is expensive, specially if one uses variable
  # parts. So, in order to achive the best performance, these should be compiled
  # upfront without any "runtime dependencies".
  ATTRIBUTES_REGEXP = Regexp.compile(/\A<[^>\s]+\s+([^>]+)/m)
  CONTENT_REGEXP = Regexp.compile(/.*?>(.*?)<[^>]+>\Z/m)

  def self.find(tag, xml, options = {})
    if matched_string = xml[regex_factory(tag, options)]
      self.new(matched_string, tag: tag)
    end
  end

  def self.find_all(tag, xml, options = {})
    xml.scan(regex_factory(tag, options)).map! do |matched_string|
      self.new(matched_string, tag: tag)
    end
  end

  private

  def self.regex_factory(tag, options = {})
    options[:multiline] = options[:multiline].nil? ? true : !!options[:multiline]

    regexp_base =
    if tag.start_with?("<") && tag.end_with?(">")
      "#{tag}.*?<\/#{tag[1..-2]}>"
    else
      "<#{tag}[>\s].*?<\/#{tag}>"
    end

    Regexp.new(regexp_base, (options[:multiline] ? Regexp::MULTILINE : 0))
  end

  public

  def initialize(xml, options = {})
    @options = options
    @tag = options.delete(:tag)
    @xml = xml
  end

  def attr(key)
    if match_data = @xml.match(ATTRIBUTES_REGEXP)
      if value_match_data = match_data.captures.first.match(/#{key}="(.+?)"/)
        value_match_data.captures.first
      end
    end
  end

  def content
    @content ||=
    if match_data = @xml.match(CONTENT_REGEXP)
      match_data.captures.first.tap(&:strip!)
    end
  end

  def find(tag, options = nil)
    self.class.find(tag, @xml, (options || @options))
  end

  def find_all(tag, options = nil)
    self.class.find_all(tag, @xml, (options || @options))
  end

  def to_s
    @xml
  end
end
