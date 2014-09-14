require 'rails_helper'

describe "Styles" do
  before do
    @style = Style.new
    @recipe = recipe.new
  end

  describe "comparison methods" do

    describe "check_ibu" do
      before { style.ibu = [40, 70] }

      it "should return '1' for an ibu value in style range" do
        allow(recipe).to recieve(:ibu).and_return(50)
        expect(style.check_ibu(recipe)).to eq(1)
      end

      it "should return '0' for an ibu value out of style range" do
        expect(style.check_ibu(recipe)).to eq(0)
      end
    end
  end
end
