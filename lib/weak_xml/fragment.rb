class Fragment
  def attr(key = nil)
    if @attr.nil?
      @attr = {}

      @given_attributes.split(" ").each do |_key_value_pair|
        _key, _value =_key_value_pair.split("=")
        #_key.strip!
        #_value.strip!
        #_value.gsub!("\"", "")

        @attr[_key] = _value
      end
    end

    key.nil? ? @attr : @attr[key]
  end

  def content
    @content ||= @given_content.tap(&:strip!)
  end

  def initialize(tag, content, attributes = nil)
    @given_attributes = attributes
    @given_content = content
  end
end
