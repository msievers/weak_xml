describe WeakXml do
  let(:xml) do
    #read_asset("alma_user_fees.xml")
    <<-xml.strip_heredoc
      <fees>
        <fee attr1="value1">content1</fee>
        <fee>content2</fee>
      </fees>
    xml
  end

  describe ".find" do
    it "foo" do
      w = WeakXml.find("fee", xml)
      ww = w.attr("attr1")
      binding.pry
    end
  end
end
