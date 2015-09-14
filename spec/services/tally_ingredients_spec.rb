require 'service_objects_helper'

describe TallyIngredients do
  include_context "shared service variables"

  let(:ingredients) { TallyIngredients.new(@recipe.malt_names_to_array, @recipe.hop_names_to_array) }
  let(:style_2) { FactoryGirl.build(:style, common_malts: ['common_malt'], common_hops: ['common_hop']) }

  describe "tally_common" do
    it "returns hashes with tallies for each style called" do
      allow(ingredients).to receive(:tally_common_malts).with(:style_key_1).and_return({ :style_key_1 => 1 })
      allow(ingredients).to receive(:tally_common_malts).with(:style_key_2).and_return({ :style_key_2 => 1 })
      allow(ingredients).to receive(:tally_common_hops).with(:style_key_1).and_return({ :style_key_1 => 1 })
      allow(ingredients).to receive(:tally_common_hops).with(:style_key_2).and_return({ :style_key_2 => 0 })
      expect(ingredients.tally_common([:style_key_1, :style_key_2])).to eq([{ :style_key_1 => 1, :style_key_2 => 1 }, { :style_key_1 => 1, :style_key_2 => 0 }])
    end
  end

  describe "tally_common_malts" do
    context "malt is common in style and present in recipe" do
      it "increases the tally" do
        ingredients.malt_names = ['common_malt']
        expect(ingredients.tally_common_malts(style_2)).to eq({ style_2 => 1 })
      end
    end

    context "malt is common in style and absent in recipe" do
      it "does not increase the tally" do
        ingredients.malt_names = ['malt']
        expect(ingredients.tally_common_malts(style_2)).to eq({ style_2 => 0 })
      end
    end
  end

  describe "tally_common_hops" do
    context "hop is common in style and present in recipe" do
      it "increases the tally" do
        ingredients.hops_names = ['common_hop']
        expect(ingredients.tally_common_hops(style_2)).to eq({ style_2 => 1 })
      end
    end

    context "hop is common in style and absent in recipe" do
      it "does not increase the tally" do
        ingredients.hops_names = ['hop']
        expect(ingredients.tally_common_hops(style_2)).to eq({ style_2 => 0 })
      end
    end
  end
end