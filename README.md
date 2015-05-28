# WeakXml

[![Build Status](https://travis-ci.org/msievers/weak_xml.svg)](https://travis-ci.org/msievers/weak_xml)
[![Test Coverage](https://codeclimate.com/github/msievers/weak_xml/badges/coverage.svg)](https://codeclimate.com/github/msievers/weak_xml/coverage)
[![Code Climate](https://codeclimate.com/github/msievers/weak_xml/badges/gpa.svg)](https://codeclimate.com/github/msievers/weak_xml)
[![Dependency Status](https://gemnasium.com/msievers/weak_xml.svg)](https://gemnasium.com/msievers/weak_xml)

`WeakXml` is a non-parsing xml library which only works for certain well structured xml files.

## Usage

```ruby
require "weak_xml"

xml = <<-EOXML
<xml>
  <foo>
    <bar attr1="value1">content1</bar>
    <bar attr1="value2" attr2="value3">content2</bar>
    <bar attr2="value4>content3</bar>
  </foo>
  <foo>
    <muff>content4</muff>
  </foo>
</xml>
EOXML

# .find gets the first node with the given tag or nil
some_node = WeakXml.find("bar", xml) # => #<WeakXml::Fragment ...
WeakXml.find("nope", xml) # => nil

# you can get the content
some_node.content # => "content1"

# or some (existing) attribute
some_node.attr("attr1") # => "value1"
some_node.attr("nope_attr") # => nil

# in contrast to .find, find_all gets you all nodes which match the given tag
some_nodes = WeakXml.find_all("bar", xml)
WeakXml.find_all("nope", xml) # => []

# elements of find_all behave like the ones from find
some_nodes.map(&:content) # => ["content1", "content2", "content3"]

# xml/options can be stored within an instance of WeakXml
doc = WeakXml.new(xml, disable_multiline: false)
doc.find("bar").content # => "content1"
```

## Why not mighty ?

`WeakXml`is called weak because it probably does not work with your special fancy xml. It not even tries. Internally, regular expressions are used and those only work with certain well formed xml. No edge cases, no standard compliance, nothing.

## Why anybody might like it anyway ?

There are no dependencies. It's fast (factor 10 and up compared to Nokigiri for certain scenarios). According to the 80/20 rule, many xml documents should work without problems.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/msievers/weak_xml/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
