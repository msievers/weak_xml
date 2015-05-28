class Fragment
  # Compiling regular expressions is expensive, specially if one uses variable
  # parts. So, in order to achive the best performance, these should be compiled
  # upfront without any "runtime dependencies".
  ATTRIBUTES_REGEXP = Regexp.compile(/\A<\w+\s+([^>]+)/m)
  CONTENT_REGEXP = Regexp.compile(/.*?>(.*?)<[^>]+>\Z/m)

  def initialize(tag, xml)
    @tag = tag
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
    if match_data = @xml.match(CONTENT_REGEXP)
      match_data.captures.first.tap(&:strip!)
    end
  end
end
