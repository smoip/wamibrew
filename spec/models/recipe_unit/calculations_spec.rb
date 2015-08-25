# require 'spec_helper'

describe "calculations" do
  before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after do
    @recipe.destroy!
  end
  let(:malt) { FactoryGirl.build(:malt) }
  let(:malt_1) { FactoryGirl.build(:malt, malt_yield: 0.7) }
  let(:yeast) { FactoryGirl.build(:yeast) }
  let(:hop) { FactoryGirl.build(:hop) }

  # describe "calc_abv" do
  #   context "og 1050 and fg 1010" do
  #     it "assigns a value to @abv" do
  #       allow(@recipe).to receive(:combine_og).and_return(0.050)
  #       allow(@recipe).to receive(:calc_fg).and_return(1.010)
  #       @recipe.calc_abv
  #       expect(@recipe.abv).to eq(5.3)
  #     end
  #   end
  #   context "og 1072 and fg 1021" do
  #     it "assigns a value to @abv" do
  #       allow(@recipe).to receive(:combine_og).and_return(0.072)
  #       allow(@recipe).to receive(:calc_fg).and_return(1.021)
  #       @recipe.calc_abv
  #       expect(@recipe.abv).to eq(6.6)
  #     end
  #   end
  # end

  # describe "calc_og" do
  #   context "empty malt array" do
  #     it "returns 0" do
  #       expect(@recipe.calc_og(nil)).to eq(0)
  #     end
  #   end
  #   context "with malt array" do
  #     it "returns an og value for malt and weight" do
  #       allow(@recipe).to receive(:pull_malt_amt).and_return(10)
  #       allow(@recipe).to receive(:pull_malt_object).and_return(malt)
  #       allow(@recipe).to receive(:pg_to_ep).and_return(37)
  #       expect(@recipe.calc_og('filler')).to eq(0.0592)
  #     end
  #     it "returns an og value for a second malt and weight" do
  #       allow(@recipe).to receive(:pull_malt_amt).and_return(2.5)
  #       allow(@recipe).to receive(:pull_malt_object).and_return(malt_1)
  #       allow(@recipe).to receive(:pg_to_ep).and_return(37)
  #       expect(@recipe.calc_og('filler')).to eq(0.01295)
  #     end
  #   end
  # end

  # describe "calc_fg" do
  #   before { @recipe.yeast = yeast }
  #   it "returns a final gravity" do
  #     allow(@recipe).to receive(:pg_to_ep).and_return(50)
  #     expect(@recipe.calc_fg(1.050)).to eq(1.0125)
  #   end
  #   it "returns a different gravity with another original gravity" do
  #     allow(@recipe).to receive(:pg_to_ep).and_return(90)
  #     expect(@recipe.calc_fg(1.090)).to eq(1.0225)
  #   end
  # end

  # describe "combine_og" do
  #   before { allow(@recipe).to receive(:calc_og).and_return(0.0592) }
  #   context "one malt assigned" do
  #     it "returns the single og value" do
  #       allow(@recipe).to receive(:malts_to_array).and_return([[malt, 10]])
  #       expect(@recipe.combine_og).to eq(0.0592)
  #     end
  #   end
  #   context "multiple malts assigned" do
  #     it "combines all individual og values" do
  #       allow(@recipe).to receive(:malts_to_array).and_return([[malt, 10], [malt_1, 1]])
  #       expect(@recipe.combine_og).to eq(0.1184)
  #     end
  #   end
  # end

  # describe "pg_to_ep" do
  #   it "returns an ep formatted value" do
  #     expect(@recipe.pg_to_ep(1.050)).to be_within(0.01).of(50)
  #   end
  # end

  describe "calc_ibu" do
    before { allow(@recipe).to receive(:calc_indiv_ibu).and_return(48.362) }
    context "with a single hop assigned" do
      it "returns a single ibu value" do
        allow(@recipe).to receive(:hops_to_array).and_return([[hop, [2.5, 60]]])
        expect(@recipe.calc_ibu).to eq(48.4)
      end
    end
    context "with multiple hops assigned" do
      it "returns the combined ibu contributions of all assigned hops" do
        allow(@recipe).to receive(:hops_to_array).and_return([[hop, [2.5, 60]], [hop, [1.0, 10]]])
        expect(@recipe.calc_ibu).to eq(96.7)
      end
    end
  end

  describe "calc_indiv_ibu" do
    before { allow(@recipe).to receive(:pull_hop_object).and_return(hop) }
    it "calculates a single hop addition's ibu contribution" do
      allow(@recipe).to receive(:pull_hop_amt).and_return(2.5)
      allow(@recipe).to receive(:pull_hop_time).and_return(60)
      allow(@recipe).to receive(:calc_hop_util).and_return(0.3081950635151269)
      allow(@recipe).to receive(:calc_hop_ga).and_return(0.020000000000000018)
      expect(@recipe.calc_indiv_ibu([ hop, [ 2.5, 60 ] ])).to eq(48.362422594828296)
    end
    it "calculates another hop addition's ibu contribution" do
      allow(@recipe).to receive(:pull_hop_amt).and_return(1.5)
      allow(@recipe).to receive(:pull_hop_time).and_return(10)
      allow(@recipe).to receive(:calc_hop_util).and_return(0.06699216655991082)
      allow(@recipe).to receive(:calc_hop_ga).and_return(0)
      expect(@recipe.calc_indiv_ibu([ hop, [ 1.5, 10 ] ])).to eq(9.568000767092846)
    end
  end

  describe "rager_to_tinseth_q_and_d" do
    it "converts a rager ibu for > 30 min" do
      expect(@recipe.rager_to_tinseth_q_and_d(34, 50)).to be_within(0.1).of(39)
    end
    it "converts a rager ibu for <= 30 min" do
      expect(@recipe.rager_to_tinseth_q_and_d(15, 50)).to be_within(0.1).of(58)
    end
  end

  describe "calc_hop_util" do
    it "calculates hop utilization for a short boil period" do
      expect(@recipe.calc_hop_util(15)).to eq(0.08227765415996507)
    end
    it "calculates hop utilization for a long boil period" do
      expect(@recipe.calc_hop_util(60)).to eq(0.3081950635151269)
    end
  end

  describe "calc_hop_ga" do
    context "gravity > 1.058" do
      it "returns a higher-gravity adjustment value" do
        @recipe.og = 1.062
        expect(@recipe.calc_hop_ga).to eq(0.020000000000000018)
      end
    end
    context "gravity <= 1.058" do
      it "returns 0" do
        @recipe.og = 1.042
        expect(@recipe.calc_hop_ga).to eq(0)
      end
    end
  end

  # describe "calc_mcu" do
  #   before { allow(@recipe).to receive(:pull_malt_object).and_return(malt) }
  #   it "returns a malt color value for a single malt addition" do
  #     allow(@recipe).to receive(:pull_malt_amt).and_return(5)
  #     expect(@recipe.calc_mcu([malt, 5])).to eq(1.8)
  #   end
  #   it "returns a malt color value for a different malt addition" do
  #     allow(@recipe).to receive(:pull_malt_amt).and_return(15)
  #     expect(@recipe.calc_mcu([malt, 15])).to eq(5.4)
  #   end
  # end

  # describe "combine_mcu" do
  #   before { allow(@recipe).to receive(:calc_mcu).and_return(1.8) }
  #   context "with single malt" do
  #     it "returns a single mcu value" do
  #       allow(@recipe).to receive(:malts_to_array).and_return([[malt, 5]])
  #       expect(@recipe.combine_mcu).to eq(1.8)
  #     end
  #   end
  #   context "with multiple malts assigned" do
  #     it "returns a sum of mcu values" do
  #       allow(@recipe).to receive(:malts_to_array).and_return([[malt, 5], [malt, 5]])
  #       expect(@recipe.combine_mcu).to eq(3.6)
  #     end
  #   end
  # end

  # describe "calc_srm" do
  #   it "converts mcu to srm" do
  #     allow(@recipe).to receive(:combine_mcu).and_return(3.6)
  #     @recipe.calc_srm
  #     expect(@recipe.srm).to eq(3.6)
  #   end
  # end


end