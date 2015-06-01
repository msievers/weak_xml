describe WeakXml do
  let(:xml) do
    read_asset("alma_user_fees.xml")
  end

  describe ".find" do
    context "if there is at least one node with that tag" do
      it "returns the first node which matches the given tag" do
        expect(WeakXml.find("fee", xml).content).not_to be(nil)
      end
    end

    context "if the given tag is enclosed in <...>" do
      it "searches only for tags without attributes" do
        expect(WeakXml.find("<fee>", xml)).to be_nil
        expect(WeakXml.find("<id>", xml)).not_to be_nil
      end
    end
  end

  describe ".find_all" do
    context "if there is at least one node with that tag" do
      it "returns all nodes which match the given tag" do
        expect(WeakXml.find_all("fee", xml)).not_to be_empty
      end
    end
  end

  describe ".new" do
    it "creates an instance which holds options and the xml" do
      expect(WeakXml.new(xml, multiline: true)).to be_a(described_class)
    end
  end

  describe "#find" do
    it "is a proxy for .find" do
      expect(WeakXml.find("fee", xml).content).to eq(WeakXml.new(xml).find("fee").content)
    end
  end

  describe "#find_all" do
    it "is a proxy for .find_all" do
      expect(WeakXml.find_all("fee", xml).length).to eq(WeakXml.new(xml).find_all("fee").length)
    end
  end
end
