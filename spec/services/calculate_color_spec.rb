require 'service_objects_helper'

describe CalculateColor do
  include_context "shared service variables"
  let(:color) { CalculateColor.new(@recipe) }
# unedited tests - need transfer

  describe "calc_mcu" do
    before { allow(@recipe).to receive(:pull_malt_object).and_return(malt) }
    it "returns a malt color value for a single malt addition" do
      allow(@recipe).to receive(:pull_malt_amt).and_return(5)
      expect(color.calc_mcu([malt, 5])).to eq(1.8)
    end
    it "returns a malt color value for a different malt addition" do
      allow(@recipe).to receive(:pull_malt_amt).and_return(15)
      expect(color.calc_mcu([malt, 15])).to eq(5.4)
    end
  end

  describe "combine_mcu" do
    before { allow(color).to receive(:calc_mcu).and_return(1.8) }
    context "with single malt" do
      it "returns a single mcu value" do
        allow(@recipe).to receive(:malts_to_array).and_return([[malt, 5]])
        expect(color.combine_mcu).to eq(1.8)
      end
    end
    context "with multiple malts assigned" do
      it "returns a sum of mcu values" do
        allow(@recipe).to receive(:malts_to_array).and_return([[malt, 5], [malt, 5]])
        expect(color.combine_mcu).to eq(3.6)
      end
    end
  end

  describe "calc_srm" do
    it "converts mcu to srm" do
      allow(color).to receive(:combine_mcu).and_return(3.6)
      expect(color.calc_srm).to eq(3.6)
    end
  end
end