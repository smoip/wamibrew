require 'service_objects_helper'

describe CalculateGravity do
  include_context "shared service variables"

  let(:gravity) { CalculateGravity.new(@recipe) }

  describe "calc_abv" do
    context "og 1050 and fg 1010" do
      it "assigns a value to @abv" do
        allow(gravity).to receive(:combine_og).and_return(0.050)
        allow(gravity).to receive(:calc_fg).and_return(1.010)
        gravity.calc_abv
        expect(@recipe.abv).to eq(5.3)
      end
    end
    context "og 1072 and fg 1021" do
      it "assigns a value to @abv" do
        allow(gravity).to receive(:combine_og).and_return(0.072)
        allow(gravity).to receive(:calc_fg).and_return(1.021)
        gravity.calc_abv
        expect(@recipe.abv).to eq(6.6)
      end
    end
  end

  describe "calc_og" do
    context "empty malt array" do
      it "returns 0" do
        expect(gravity.calc_og(nil)).to eq(0)
      end
    end
    context "with malt array" do
      before { allow(gravity).to receive(:pg_to_ep).and_return(37) }
      it "returns an og value for malt and weight" do
        allow(@recipe).to receive(:pull_malt_amt).and_return(10)
        allow(@recipe).to receive(:pull_malt_object).and_return(malt)
        expect(gravity.calc_og('filler')).to eq(0.0592)
      end
      it "returns an og value for a second malt and weight" do
        allow(@recipe).to receive(:pull_malt_amt).and_return(2.5)
        allow(@recipe).to receive(:pull_malt_object).and_return(malt_1)
        expect(gravity.calc_og('filler')).to eq(0.01295)
      end
    end
  end

  describe "calc_fg" do
    before { @recipe.yeast = yeast }
    it "returns a final gravity" do
      allow(gravity).to receive(:pg_to_ep).and_return(50)
      expect(gravity.calc_fg(1.050)).to eq(1.0125)
    end
    it "returns a different gravity with another original gravity" do
      allow(gravity).to receive(:pg_to_ep).and_return(90)
      expect(gravity.calc_fg(1.090)).to eq(1.0225)
    end
  end

  describe "combine_og" do
    before { allow(gravity).to receive(:calc_og).and_return(0.0592) }
    context "one malt assigned" do
      it "returns the single og value" do
        allow(@recipe).to receive(:malts_to_array).and_return([[malt, 10]])
        expect(gravity.combine_og).to eq(0.0592)
      end
    end
    context "multiple malts assigned" do
      it "combines all individual og values" do
        allow(@recipe).to receive(:malts_to_array).and_return([[malt, 10], [malt_1, 1]])
        expect(gravity.combine_og).to eq(0.1184)
      end
    end
  end

  describe "pg_to_ep" do
    it "returns an ep formatted value" do
      expect(gravity.pg_to_ep(1.050)).to be_within(0.01).of(50)
    end
  end
end