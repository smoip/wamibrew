require 'service_objects_helper'

describe AddYeast do
  include_context "shared service variables"
  let(:yeast_add) { AddYeast.new(@recipe) }

  describe "add_yeast" do
    before do
      @recipe.name = 'Beer'
    end
    after do
      @recipe.name = nil
      @recipe.style = nil
    end

    context "with assigned style" do
      before { @recipe.style = style }
      it "should not alter the name" do
        yeast_add.add_yeast
        expect(@recipe.name).to eq('Beer')
      end
    end

    context "without assigned style" do
      before do
        @recipe.style = nil
        @recipe.yeast = yeast
        allow(yeast_add).to receive(:rand).and_return(1)
      end
      after { @recipe.yeast = nil }

      it "should alter the name" do
        allow(@recipe).to receive(:capitalize_titles).and_return('Ale')
        yeast_add.add_yeast
        expect(@recipe.name).to eq('Ale')
      end
      it "should not add the yeast family \'wheat\'" do
        allow(@recipe.yeast).to receive(:family).and_return('wheat')
        yeast_add.add_yeast
        expect(@recipe.name).not_to eq('Wheat')
      end
    end
  end
end