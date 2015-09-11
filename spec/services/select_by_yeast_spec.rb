require 'service_objects_helper'

describe SelectByYeast do
  include_context "shared service variables"

  let(:by_yeast) { SelectByYeast.new(@recipe.yeast) }

  describe "select_by_yeast" do
    let(:style_1) { FactoryGirl.create(:style, name: 'test style', yeast_family: 'test') }
    let(:yeast_1) { FactoryGirl.build(:yeast, name: 'test ale', family: 'test') }
    before do
      style_1.save!
      by_yeast.yeast = yeast_1
    end
    after { style_1.destroy! }
    context "one matching style" do
      it "returns one style" do
        expect(by_yeast.select).to eq([style_1])
      end
    end
    context "multiple matching styles" do
      let(:style_2) { FactoryGirl.create(:style, name: 'test style 1', yeast_family: 'test') }
      before { style_2.save! }
      after { style_2.destroy! }
      it "returns two styles" do
        expect(by_yeast.select).to eq([style_1, style_2])
      end
    end
    context "no matching styles" do
      let(:yeast_2) { FactoryGirl.build(:yeast, family: 'no match') }
      before { by_yeast.yeast = yeast_2 }
      it "returns no styles" do
        expect(by_yeast.select).to eq([])
      end
    end
  end
end
