require 'service_objects_helper'

describe AddYeast do
  include_context "shared service variables"
  let(:yeast_add) { AddYeast.new(@recipe.style, @recipe.name, @recipe.yeast) }

  describe "add_yeast" do
    before { yeast_add.name = 'Beer' }

    context "with assigned style" do
      before { yeast_add.style = style }
      it "should return nil" do
        expect(yeast_add.add_yeast).to eq(nil)
      end
    end

    context "without assigned style" do
      before do
        yeast_add.style = nil
        yeast_add.yeast = yeast
        allow(yeast_add).to receive(:rand).and_return(1)
      end

      it "should alter the name" do
        allow(NameHelpers).to receive(:capitalize_titles).and_return('Ale')
        expect(yeast_add.add_yeast).to eq('Ale')
      end
      it "should not add the yeast family \'wheat\'" do
        allow(yeast_add.yeast).to receive(:family).and_return('wheat')
        expect(yeast_add.add_yeast).not_to eq('Wheat')
      end
    end
  end
end