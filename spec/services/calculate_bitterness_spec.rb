require 'service_objects_helper'

describe CalculateBitterness do
  include_context 'shared service variables'

  let(:bitterness) { CalculateBitterness.new(@recipe.hops_to_array, 1.050) }

  describe "calc_ibu" do
    before { allow(bitterness).to receive(:calc_indiv_ibu).and_return(48.362) }
    context "with a single hop assigned" do
      it "returns a single ibu value" do
        bitterness.hops_ary = [[hop, [2.5, 60]]]
        expect(bitterness.calc_ibu).to eq(48.4)
      end
    end
    context "with multiple hops assigned" do
      it "returns the combined ibu contributions of all assigned hops" do
        bitterness.hops_ary = [[hop, [2.5, 60]], [hop, [1.0, 10]]]
        expect(bitterness.calc_ibu).to eq(96.7)
      end
    end
  end

  describe "calc_indiv_ibu" do
    it "calculates a single hop addition's ibu contribution" do
      hop_ary = [hop, [2.5, 60]]
      allow(HopsHelpers).to receive(:pull_hop_object).with(hop_ary).and_return(hop)
      allow(HopsHelpers).to receive(:pull_hop_amt).with(hop_ary).and_return(2.5)
      allow(HopsHelpers).to receive(:pull_hop_time).with(hop_ary).and_return(60)
      allow(bitterness).to receive(:calc_hop_util).and_return(0.3081950635151269)
      allow(bitterness).to receive(:calc_hop_ga).and_return(0.020000000000000018)
      expect(bitterness.calc_indiv_ibu([hop, [2.5, 60]])).to eq(48.362422594828296)
    end
    it "calculates another hop addition's ibu contribution" do
      hop_ary = [hop, [1.5, 10]]
      allow(HopsHelpers).to receive(:pull_hop_object).with(hop_ary).and_return(hop)
      allow(HopsHelpers).to receive(:pull_hop_amt).with(hop_ary).and_return(1.5)
      allow(HopsHelpers).to receive(:pull_hop_time).with(hop_ary).and_return(10)
      allow(bitterness).to receive(:calc_hop_util).and_return(0.06699216655991082)
      allow(bitterness).to receive(:calc_hop_ga).and_return(0)
      expect(bitterness.calc_indiv_ibu([hop, [1.5, 10]])).to eq(9.568000767092846)
    end
  end

  describe "rager_to_tinseth_q_and_d" do
    it "converts a rager ibu for > 30 min" do
      expect(bitterness.rager_to_tinseth_q_and_d(34, 50)).to be_within(0.1).of(39)
    end
    it "converts a rager ibu for <= 30 min" do
      expect(bitterness.rager_to_tinseth_q_and_d(15, 50)).to be_within(0.1).of(58)
    end
  end

  describe "calc_hop_util" do
    it "calculates hop utilization for a short boil period" do
      expect(bitterness.calc_hop_util(15)).to eq(0.08227765415996507)
    end
    it "calculates hop utilization for a long boil period" do
      expect(bitterness.calc_hop_util(60)).to eq(0.3081950635151269)
    end
  end

  describe "calc_hop_ga" do
    context "gravity > 1.058" do
      it "returns a higher-gravity adjustment value" do
        bitterness.og = 1.062
        expect(bitterness.calc_hop_ga).to eq(0.020000000000000018)
      end
    end
    context "gravity <= 1.058" do
      it "returns 0" do
        bitterness.og = 1.042
        expect(bitterness.calc_hop_ga).to eq(0)
      end
    end
  end

end