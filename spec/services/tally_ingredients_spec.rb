require 'service_objects_helper'

describe TallyIngredients do
  include_context "shared service variables"

  let(:ingredients) { TallyIngredients.new(@recipe.malt_names_to_array, @recipe.hop_names_to_array) }
  let(:style_2) { FactoryGirl.build(:style, common_malts: ['common_malt'], common_hops: ['common_hop']) }

  describe "tally_common_ingredients" do
    # needs testing
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