require 'service_objects_helper'

describe AddIngredient do
  include_context "shared service variables"

  let(:ingredient) { AddIngredient.new(@recipe.name, @recipe.malts_to_array, @recipe.style) }

  describe "add_ingredient" do
    before { allow(ingredient).to receive(:rand).and_return(1) }
    context "recipe includes one adjective-able malt" do
      before do
        allow(ingredient).to receive(:get_required_malts).and_return([])
        ingredient.name = 'Beer'
      end
      it "adds \'rye\' to the name" do
        allow(ingredient).to receive(:choose_ingredient_adjective).and_return('rye')
        expect(ingredient.add_ingredient).to eq('Rye')
      end
      it "adds \'honey\' to the name" do
        allow(ingredient).to receive(:choose_ingredient_adjective).and_return('honey')
        expect(ingredient.add_ingredient).to eq('Honey')
      end
    end
    context "recipe includes multiple adjective-able malts" do
      before do
        ingredient.name = 'Beer'
        ingredient.malts_ary = [[malt, 10], [malt_rye, 2.5], [malt_wheat, 2]]
      end
      it "adds an adjective to the name" do
        adjectives = [ "Rye", "Wheat" ]
        expect((ingredient.add_ingredient.split(' ') & adjectives)[0]).to be_truthy
      end
      it "does not add multiple adjectives to the name" do
        ingredient.name = 'Beer'
         adj = ingredient.add_ingredient
        expect(adj).not_to eq('Rye Wheat')
        expect(adj).not_to eq('Wheat Rye')
      end
    end
    context "recipe includes no adjective-able malts" do
      before { ingredient.name = 'Beer' }
      it "does not add an adjective to the name" do
        allow(ingredient).to receive(:choose_ingredient_adjective).and_return(nil)
        allow(ingredient).to receive(:get_required_malts).and_return([ 'wheat' ])
        expect(ingredient.add_ingredient).to eq(nil)
      end
    end
    context "recipe includes an adjective-able malt which is also a required malt for style" do
      before { ingredient.name = 'Beer' }
      it "does not add an adjective to the name" do
        allow(ingredient).to receive(:choose_ingredient_adjective).and_return('wheat')
        allow(ingredient).to receive(:get_required_malts).and_return([ 'wheat' ])
        expect(ingredient.add_ingredient).to eq(nil)
      end
    end
    context "recipe includes oats" do
      before { ingredient.name = 'Beer' }
      it "adds \'oatmeal\' rather than \'oats\'" do
        allow(ingredient).to receive(:choose_ingredient_adjective).and_return('oats')
        allow(ingredient).to receive(:get_required_malts).and_return([])
        expect(ingredient.add_ingredient).to eq('Oatmeal')
      end
    end
  end

  describe "choose_ingredient_adjective" do
    context "recipe includes one adjective-able malt" do
      it "returns \'rye\'" do
        ingredient.malts_ary = [[malt, 10], [malt_rye, 2]]
        expect(ingredient.choose_ingredient_adjective).to eq('rye')
      end
      it "returns \'honey\'" do
        ingredient.malts_ary = [[malt, 10], [sugar, 2]]
        expect(ingredient.choose_ingredient_adjective).to eq('honey')
      end
    end
    context "recipe includes multiple adjective-able malts" do
      it "returns only one adjective" do
        ingredient.malts_ary = [[malt, 10], [malt_rye, 1], [malt_wheat, 0.25]]
        adjs = [ 'wheat', 'rye' ]
        expect(([ ingredient.choose_ingredient_adjective ] & adjs)[0]).not_to eq(nil)
        expect(([ ingredient.choose_ingredient_adjective ] & adjs)[0]).to be_truthy
      end
    end
    context "recipe includes no adjective-able malts" do
      it "returns nothing" do
        ingredient.malts_ary = [[malt, 10]]
        expect(ingredient.choose_ingredient_adjective).to eq(nil)
      end
    end
  end

  describe "get_required_malts" do
    context "assigned style has no required malts" do
      before { ingredient.style = nil }
      it "returns an empty array" do
        expect(ingredient.get_required_malts).to eq([])
      end
    end
    context "assigned style has one required malt" do
      let(:style_req_one) { FactoryGirl.build(:style, required_malts: [ '2-row' ]) }
      before { ingredient.style = style_req_one }
      it "returns an array containing the test malt name" do
        expect(ingredient.get_required_malts).to eq([ '2-row' ])
      end
    end
    context "assigned style has multiple required malts" do
      let(:style_req_two) { FactoryGirl.build(:style, required_malts: [ '2-row', 'black malt' ]) }
      before { ingredient.style = style_req_two }
      it "returns an array containing two test malt names" do
        expect(ingredient.get_required_malts).to eq([ '2-row', 'black', 'malt' ])
      end
    end
  end

  describe "oatmeal_check" do
    it "should change oats to oatmeal" do
      expect(ingredient.oatmeal_check('oats')).to eq('oatmeal')
    end
    it "does not change non-oat words" do
      expect(ingredient.oatmeal_check('rye')).to eq('rye')
    end
  end

end