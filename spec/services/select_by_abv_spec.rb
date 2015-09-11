require 'service_objects_helper'

describe SelectByAbv do
  include_context "shared service variables"

  let(:by_abv) { SelectByAbv.new(@recipe.abv) }

  context "no styles cover @abv" do
    it "returns an empty array" do
      by_abv.abv = 3.0
      expect(by_abv.select(style_list)).to eq([])
    end
  end
  context "one style covers @abv" do
    it "returns a single style in an array" do
      by_abv.abv = 7.0
      expect(by_abv.select(style_list)).to eq([ style ])
    end
  end
  context "multiple styles cover @abv" do
    it "returns a list of multiple styles" do
      by_abv.abv = 5.6
      expect(by_abv.select(style_list)).to eq([ style, style_1 ])
    end
  end

end