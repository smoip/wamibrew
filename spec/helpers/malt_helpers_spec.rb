describe MaltHelpers do
  let(:malt) { FactoryGirl.build(:malt) }
  let(:malt_ary) { [ malt, 8.25 ] }
  it "returns a malt object" do
    expect(MaltHelpers.pull_malt_object(malt_ary)).to eq(malt)
  end
  it "returns a malt name" do
    expect(MaltHelpers.pull_malt_name(malt_ary)).to eq(malt.name)
  end
  it "returns a malt amount" do
    expect(MaltHelpers.pull_malt_amt(malt_ary)).to eq(8.25)
  end
end