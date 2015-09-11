require 'service_objects_helper'

describe SelectBySrm do
  include_context "shared service variables"

  let(:by_srm) { SelectBySrm.new(@recipe.srm) }

  context "no styles cover @srm" do
    it "returns an empty array" do
      by_srm.srm = 19
      expect(by_srm.select(style_list)).to eq([])
    end
  end
  context "one style covers @srm" do
    it "returns a single style in an array" do
      by_srm.srm = 13
      expect(by_srm.select(style_list)).to eq([ style ])
    end
  end
  context "multiple styles cover @srm" do
    it "returns a list of multiple styles" do
      by_srm.srm = 10
      expect(by_srm.select(style_list)).to eq([ style, style_1 ])
    end
  end

end