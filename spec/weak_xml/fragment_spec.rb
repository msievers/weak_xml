describe WeakXml::Fragment do
  let(:xml) do
    read_asset("alma_user_fees.xml")
  end

  subject { WeakXml.find("fee", xml) }

  describe "#attr" do
    context "if there is an attribte with the given name" do
      it "returns the value of the attribute" do
        expect(subject.attr("link")).not_to be_nil
      end
    end

    context "if there is no attribute with the given name" do
      it "returns nil" do
        expect(subject.attr("foobar")).to be_nil
      end
    end
  end

  describe "#content" do
    it "returns the fragment's content" do
      expect(subject.content).not_to be_nil
    end
  end
end
