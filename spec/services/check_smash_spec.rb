require 'service_objects_helper'

describe CheckSmash do
  include_context "shared service variables"

  let(:smash) { CheckSmash.new(@recipe.style, @recipe.hop_names_to_array, @recipe.malts, @recipe.malts_to_array, @recipe.hops_to_array) }

  describe "check_smash" do
    context "with assigned style present" do
      before { smash.style = 'IPA' }
      it "should not generate a SMASH name" do
        expect(smash.check).to eq(nil)
      end
    end

    context "without assigned style" do
      before { smash.style = nil }
      it "should attempt to generate smash name" do
        allow(smash).to receive(:single_malt?).and_return(true)
        allow(smash).to receive(:single_hop?).and_return(true)
        allow(smash).to receive(:generate_smash_name).and_return('SMASH')
        expect(smash.check).to eq('SMASH')
      end
    end
  end

  describe "single_hop?" do
    context "single type of hop in hop instance variable" do
      before { smash.hops_names = ['hop'] }
      it "should be true" do
        expect(smash.single_hop?).to be(true)
      end
    end

    context "multiple types of hops in hop instance variable" do
      before { smash.hops_names = ['hop', 'other hop'] }
      it "should be false" do
        expect(smash.single_hop?).to be(false)
      end
    end

  end

  describe "single_malt?" do
    context "single type of malt in malt instance variable" do
      let(:single_malt)  { { :base => { malt => 9 }, :specialty => {} } }
      before { smash.malts = single_malt }
      it "should be true" do
        expect(smash.single_malt?).to be(true)
      end
    end

    context "multiple types of malts in malt instance variable" do
      let(:multi_malt) { { :base => { malt => 9 }, :specialty => { malt_2 => 1 } } }
      before { smash.malts = multi_malt }
      it "should be false" do
        expect(smash.single_malt?).to be(false)
      end
    end
  end

end