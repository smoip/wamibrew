describe NameHelpers do

    describe "capitalize_titles" do
      it "should capitalize multi-word titles" do
        expect(NameHelpers.capitalize_titles('delicious red wheat')).to eq('Delicious Red Wheat')
      end

      it "should capitalize one-word titles" do
        expect(NameHelpers.capitalize_titles('wheat')).to eq('Wheat')
      end
    end
end