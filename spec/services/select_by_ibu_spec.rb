require 'service_objects_helper'

describe SelectByIbu do
  include_context "shared service variables"

  let(:by_ibu) { SelectByIbu.new(@recipe.ibu) }

  context "no styles cover @ibu" do
    it "returns an empty array" do
      by_ibu.ibu = 99
      expect(by_ibu.select(style_list)).to eq([])
    end
  end
  context "one style covers @ibu" do
    it "returns a single style in an array" do
      by_ibu.ibu = 60
      expect(by_ibu.select(style_list)).to eq([ style ])
    end
  end
  context "multiple styles cover @ibu" do
    it "returns a list of multiple styles" do
      by_ibu.ibu = 45
      expect(by_ibu.select(style_list)).to eq([ style, style_1 ])
    end
  end

end