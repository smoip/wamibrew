describe NameHelpers do

  describe "capitalize_titles" do
    it "should capitalize multi-word titles" do
      expect(NameHelpers.capitalize_titles('delicious red wheat')).to eq('Delicious Red Wheat')
    end

    it "should capitalize one-word titles" do
      expect(NameHelpers.capitalize_titles('wheat')).to eq('Wheat')
    end
  end

  describe "check_smash_name" do
    context "includes \'SMASH\'" do
      it "should be true" do
        expect(NameHelpers.check_smash_name('Golden Promise Saaz SMASH')).to be(true)
      end
    end
    context "does not include \'SMASH\'" do
      it "should be false" do
        expect(NameHelpers.check_smash_name('Red Ale')).to be(false)
      end
    end
  end
end