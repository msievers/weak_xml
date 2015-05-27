describe WeakXml do
  let(:xml) do
    read_asset("alma_user_fees.xml")
  end

  describe ".find" do
    it "foo" do
      w = WeakXml.find("fees", xml)
      binding.pry
    end
  end
end
