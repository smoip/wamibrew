describe HopsHelpers do
  let(:hop) { FactoryGirl.build(:hop) }
  let(:hop_ary) { [ hop, [ 2.0, 15 ] ] }
  it "returns a hop object" do
    expect(HopsHelpers.pull_hop_object(hop_ary)).to eq(hop)
  end
  it "returns a hop name" do
    expect(HopsHelpers.pull_hop_name(hop_ary)).to eq(hop.name)
  end
  it "returns a hop amount" do
    expect(HopsHelpers.pull_hop_amt(hop_ary)).to eq(2.0)
  end
  it "returns a hop time" do
    expect(HopsHelpers.pull_hop_time(hop_ary)).to eq(15)
  end
end