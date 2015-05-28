require "active_support"
require "active_support/core_ext"
require "nokogiri"
require "ox"
require "oga"
require "pry"
require "weak_xml"
require_relative "../weak_xml"

class Benchmark::WeakXml::WeakXmlVersusOthers
  DISABLE_ALL_EXCEPT_NOKOGIRI = false

  def call
    puts "Find 'z303-id' and get content\n\n"

    Benchmark.ips do |x|
      x.config(time: 2, warmup: 1)

      x.report("Nokogiri") do
        Nokogiri::XML(ALEPH_BOR_INFO_XML).xpath(".//z303-id").text
      end

      unless DISABLE_ALL_EXCEPT_NOKOGIRI
        x.report("Oga") do
          Oga.parse_xml(ALEPH_BOR_INFO_XML).xpath(".//z303-id").text
        end

        x.report("Ox") do
          Ox.parse(ALEPH_BOR_INFO_XML).locate("*/z303-id").first.text
        end
      end

      x.report("WeakXml") do
        WeakXml.find("z303-id", ALEPH_BOR_INFO_XML).content
      end

      x.report("WeakXml (+hint)") do
        WeakXml.find("<z303-id>", ALEPH_BOR_INFO_XML).content
      end

      x.report("WeakXml (-ML)") do
        WeakXml.find("z303-id", ALEPH_BOR_INFO_XML, disable_multiline: true).content
      end

      x.report("WeakXml (+hint, -ML)") do
        WeakXml.find("<z303-id>", ALEPH_BOR_INFO_XML, disable_multiline: true).content
      end

      x.report("Plain regex") do
        ALEPH_BOR_INFO_XML.match(Regexp.new("<z303-id>(.*?)<\/z303-id>")).captures.first
      end

      x.compare!
    end

    puts "Find 'fees' and get attr total_record_count\n\n"

    Benchmark.ips do |x|
      x.config(time: 2, warmup: 1)

      x.report("Nokogiri") do
        Nokogiri::XML(ALMA_FEES_XML).xpath(".//fees").attr("total_record_count").value
      end

      unless DISABLE_ALL_EXCEPT_NOKOGIRI
        x.report("Oga") do
          Oga.parse_xml(ALEPH_BOR_INFO_XML).xpath(".//z303-id").text
        end

        x.report("Ox") do
          Ox.parse(ALEPH_BOR_INFO_XML).locate("*/z303-id").first.text
        end
      end

      x.report("WeakXml") do
        WeakXml.find("fees", ALMA_FEES_XML).attr("total_record_count")
      end

      x.report("WeakXml (+hint)") do
        WeakXml.find("<z303-id>", ALEPH_BOR_INFO_XML).content
      end

      x.report("WeakXml (-ML)") do
        WeakXml.find("z303-id", ALEPH_BOR_INFO_XML, disable_multiline: true).content
      end

      x.report("WeakXml (+hint, -ML)") do
        WeakXml.find("<z303-id>", ALEPH_BOR_INFO_XML, disable_multiline: true)#.content
      end
      
      x.compare!
    end

    puts "\nFind all 'fee' and extract attribute 'link'\n\n"

    Benchmark.ips do |x|
      x.config(time: 2, warmup: 1)
      
      x.report("Nokogiri") do
        Nokogiri::XML(ALMA_FEES_XML).xpath(".//fee").map { |_fee| _fee.attr("link") }
      end

      unless DISABLE_ALL_EXCEPT_NOKOGIRI
        x.report("Oga") do
          Oga.parse_xml(ALMA_FEES_XML).xpath(".//fee").map { |_fee| _fee.attr("link").value }
        end

        x.report("Ox") do
          Ox.parse(ALMA_FEES_XML).locate("*/fee").map { |_fee| _fee.attributes[:link] }
        end
      end

      x.report("WeakXml") do
        WeakXml.find_all("fee", ALMA_FEES_XML).map { |_fee| _fee.attr("link") }
      end

      x.report("WeakXml (-ML)") do
        WeakXml.find_all("fee", ALMA_FEES_XML, disable_multiline: true).map { |_fee| _fee.attr("link") }
      end

      x.compare!
    end

    puts "\n Real life example with a hand full finds on a document\n\n"

    Benchmark.ips do |x|
      x.config(time: 2, warmup: 1)

      x.report("Nokogiri") do
        doc = Nokogiri::XML(ALEPH_BOR_INFO_XML)

        doc.xpath(".//balance").try(:first).try(:to_f)
        doc.xpath(".//current-fine").map(&:content).map(&:to_f)
        doc.xpath(".//sign")
        doc.xpath(".//z303-id").first.content
        doc.xpath(".//z303-name").first.content
        doc.xpath(".//z304-email-address").first.content
        doc.xpath(".//z305-expiry-date").first.content
      end

      x.report("WeakXml") do
        doc = WeakXml.new(ALEPH_BOR_INFO_XML)
        doc.find("<balance>").try(:content).try(:to_f)
        doc.find_all("<current-fine>").map! { |e| e.content.to_f }
        doc.find("<sign>").try(:content)
        doc.find("<z303-id>").content
        doc.find("<z303-name>").content
        doc.find("<z304-email-address>").content
        doc.find("<z305-expiry-date>").content
      end

      x.compare!
    end
  end

  ALEPH_BOR_INFO_XML = <<-EOXML.strip_heredoc
    <?xml version = "1.0" encoding = "UTF-8"?>
    <bor-info>
    <z303>
    <z303-id>PB12345</z303-id>
    <z303-proxy-for-id></z303-proxy-for-id>
    <z303-primary-id></z303-primary-id>
    <z303-name-key>mustermann max                       PB12345</z303-name-key>
    <z303-user-type></z303-user-type>
    <z303-user-library>PAD12</z303-user-library>
    <z303-open-date>01/02/1923</z303-open-date>
    <z303-update-date>01/02/1923</z303-update-date>
    <z303-con-lng>GER</z303-con-lng>
    <z303-alpha>L</z303-alpha>
    <z303-name>Mustermann, Max</z303-name>
    <z303-title></z303-title>
    <z303-delinq-1>00</z303-delinq-1>
    <z303-delinq-n-1></z303-delinq-n-1>
    <z303-delinq-1-update-date>19230201</z303-delinq-1-update-date>
    <z303-delinq-1-cat-name>OL_ABC</z303-delinq-1-cat-name>
    <z303-delinq-2>00</z303-delinq-2>
    <z303-delinq-n-2></z303-delinq-n-2>
    <z303-delinq-2-update-date>00000000</z303-delinq-2-update-date>
    <z303-delinq-2-cat-name></z303-delinq-2-cat-name>
    <z303-delinq-3>00</z303-delinq-3>
    <z303-delinq-n-3></z303-delinq-n-3>
    <z303-delinq-3-update-date>00000000</z303-delinq-3-update-date>
    <z303-delinq-3-cat-name></z303-delinq-3-cat-name>
    <z303-budget></z303-budget>
    <z303-profile-id></z303-profile-id>
    <z303-ill-library>AB</z303-ill-library>
    <z303-home-library>AB</z303-home-library>
    <z303-field-1></z303-field-1>
    <z303-field-2></z303-field-2>
    <z303-field-3></z303-field-3>
    <z303-note-1></z303-note-1>
    <z303-note-2></z303-note-2>
    <z303-salutation></z303-salutation>
    <z303-ill-total-limit>9999</z303-ill-total-limit>
    <z303-ill-active-limit>9999</z303-ill-active-limit>
    <z303-dispatch-library></z303-dispatch-library>
    <z303-birth-date>01/02/1923</z303-birth-date>
    <z303-export-consent>Y</z303-export-consent>
    <z303-proxy-id-type>00</z303-proxy-id-type>
    <z303-send-all-letters>Y</z303-send-all-letters>
    <z303-plain-html></z303-plain-html>
    <z303-want-sms>N</z303-want-sms>
    <z303-plif-modification></z303-plif-modification>
    <z303-title-req-limit>0000</z303-title-req-limit>
    <z303-gender></z303-gender>
    <z303-birthplace></z303-birthplace>
    <z303-upd-time-stamp>123456789012345</z303-upd-time-stamp>
    <z303-last-name></z303-last-name>
    <z303-first-name></z303-first-name>
    </z303>
    <z304>
    <z304-id>PB12345</z304-id>
    <z304-sequence>01</z304-sequence>
    <z304-address-0>Herr Max Mustermann</z304-address-0>
    <z304-address-1>Musterplatz 1</z304-address-1>
    <z304-zip></z304-zip>
    <z304-email-address>max@mustermann.org</z304-email-address>
    <z304-telephone>12345678</z304-telephone>
    <z304-date-from>19230201</z304-date-from>
    <z304-date-to>00000000</z304-date-to>
    <z304-address-type>02</z304-address-type>
    <z304-telephone-2></z304-telephone-2>
    <z304-telephone-3></z304-telephone-3>
    <z304-telephone-4></z304-telephone-4>
    <z304-sms-number></z304-sms-number>
    <z304-update-date>19240201</z304-update-date>
    <z304-cat-name>OL_ABC</z304-cat-name>
    <z304-upd-time-stamp>192402011418275</z304-upd-time-stamp>
    </z304>
    <z305>
    <z305-id>PB12345</z305-id>
    <z305-sub-library>PAD12</z305-sub-library>
    <z305-open-date>01/02/1923</z305-open-date>
    <z305-update-date>01/02/1923</z305-update-date>
    <z305-bor-type></z305-bor-type>
    <z305-bor-status>FOO - BAR</z305-bor-status>
    <z305-registration-date>00000000</z305-registration-date>
    <z305-expiry-date>01/02/2020</z305-expiry-date>
    <z305-note></z305-note>
    <z305-loan-permission>Y</z305-loan-permission>
    <z305-photo-permission>Y</z305-photo-permission>
    <z305-over-permission>Y</z305-over-permission>
    <z305-multi-hold>Y</z305-multi-hold>
    <z305-loan-check>Y</z305-loan-check>
    <z305-hold-permission>Y</z305-hold-permission>
    <z305-renew-permission>Y</z305-renew-permission>
    <z305-rr-permission>Y</z305-rr-permission>
    <z305-ignore-late-return>N</z305-ignore-late-return>
    <z305-last-activity-date></z305-last-activity-date>
    <z305-photo-charge>F</z305-photo-charge>
    <z305-no-loan>0001</z305-no-loan>
    <z305-no-hold>0000</z305-no-hold>
    <z305-no-photo>0000</z305-no-photo>
    <z305-no-cash>0000</z305-no-cash>
    <z305-cash-limit>25.00</z305-cash-limit>
    <z305-credit-debit></z305-credit-debit>
    <z305-sum>0.00</z305-sum>
    <z305-delinq-1>00</z305-delinq-1>
    <z305-delinq-n-1></z305-delinq-n-1>
    <z305-delinq-1-update-date>00000000</z305-delinq-1-update-date>
    <z305-delinq-1-cat-name></z305-delinq-1-cat-name>
    <z305-delinq-2>00</z305-delinq-2>
    <z305-delinq-n-2></z305-delinq-n-2>
    <z305-delinq-2-update-date>00000000</z305-delinq-2-update-date>
    <z305-delinq-2-cat-name></z305-delinq-2-cat-name>
    <z305-delinq-3>00</z305-delinq-3>
    <z305-delinq-n-3></z305-delinq-n-3>
    <z305-delinq-3-update-date>00000000</z305-delinq-3-update-date>
    <z305-delinq-3-cat-name></z305-delinq-3-cat-name>
    <z305-field-1></z305-field-1>
    <z305-field-2></z305-field-2>
    <z305-field-3></z305-field-3>
    <z305-hold-on-shelf>Y</z305-hold-on-shelf>
    <z305-end-block-date></z305-end-block-date>
    <z305-booking-permission>N</z305-booking-permission>
    <z305-booking-ignore-hours>N</z305-booking-ignore-hours>
    <z305-rush-cat-request>N</z305-rush-cat-request>
    <z305-upd-time-stamp>192301021200000</z305-upd-time-stamp>
    </z305>
    <item-l>
    <z13>
    <z13-doc-number>123456</z13-doc-number>
    <z13-year>1950</z13-year>
    <z13-open-date>01/02/2003</z13-open-date>
    <z13-update-date>01/02/2003</z13-update-date>
    <z13-call-no-key></z13-call-no-key>
    <z13-call-no-code>AB01</z13-call-no-code>
    <z13-call-no>ABC1234+1</z13-call-no>
    <z13-author-code>123a1</z13-author-code>
    <z13-author>Mustermann, Max 1923- (DE-123)123456789</z13-author>
    <z13-title-code>123-1</z13-title-code>
    <z13-title>Some title</z13-title>
    <z13-imprint-code>123-1</z13-imprint-code>
    <z13-imprint>Musterstadt [u.a.]</z13-imprint>
    <z13-isbn-issn-code>123a1</z13-isbn-issn-code>
    <z13-isbn-issn>0-123-12345-1</z13-isbn-issn>
    <z13-upd-time-stamp>192301021200000</z13-upd-time-stamp>
    </z13>
    <current-fine>       20.00</current-fine>
    <due-date>01/02/2000</due-date>
    <due-hour>23:59</due-hour>
    </item-l>
    <session-id>00000000000000000000000000000000000000000000000000</session-id>
    </bor-info>
  EOXML

  ALMA_FEES_XML = <<-EOXML.strip_heredoc
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?><fees total_record_count="4" total_sum="415.0" currency="USD">
      <fee link="/almaws/v1/users/johns/fees/950645520000121">
        <id>950645520000121</id>
        <type desc="Overdue fine">OVERDUEFINE</type>
        <status desc="Active">ACTIVE</status>
        <balance>400.0</balance>
        <original_amount>400.0</original_amount>
        <creation_time>2014-10-21T08:17:12.450Z</creation_time>
        <comment>Date generated: 10/21/2014, Due: 06/23/2014, Fine Policy: Overdue Fine for All Hours, Action: Renewed</comment>
        <title>History</title>
      </fee>
      <fee link="/almaws/v1/users/johns/fees/950645580000121">
        <id>950645580000121</id>
        <type desc="Renew fee">RENEWFEE</type>
        <status desc="Active">ACTIVE</status>
        <balance>10.0</balance>
        <original_amount>10.0</original_amount>
        <creation_time>2014-10-21T08:17:12.709Z</creation_time>
        <title>History</title>
      </fee>
      <fee link="/almaws/v1/users/johns/fees/711924990000121">
        <id>711924990000121</id>
        <type desc="Overdue fine">OVERDUEFINE</type>
        <status desc="Active">ACTIVE</status>
        <balance>55.0</balance>
        <original_amount>77.0</original_amount>
        <creation_time>2014-07-15T08:40:32.630Z</creation_time>
        <comment>Date generated: 15/07/2014, Due: 23/06/2014, Fine Policy: Overdue Fine for All Hours, Action: Lost with overdue charge</comment>
        <title>History</title>
        <transactions>
          <transaction>
            <type desc="Payment">PAYMENT</type>
            <amount>22.0</amount>
            <created_by>Ex Libris</created_by>
            <transaction_time>2014-10-20T13:26:54.144Z</transaction_time>
          </transaction>
        </transactions>
      </fee>
      <fee link="/almaws/v1/users/johns/fees/950644660000121">
        <id>950644660000121</id>
        <type desc="Credit">CREDIT</type>
        <status desc="Active">ACTIVE</status>
        <balance>-50.0</balance>
        <original_amount>-50.0</original_amount>
        <creation_time>2014-10-21T07:45:03.188Z</creation_time>
        <title>History</title>
      </fee>
    </fees>
  EOXML
end
