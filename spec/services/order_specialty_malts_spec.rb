require 'service_objects_helper'

describe OrderSpecialtyMalts do

  describe "order_specialty_malts" do
    include_context "shared service variables"

    context "no specialty malts" do
      before do
        @recipe.malts[:specialty]= {}
        @service = OrderSpecialtyMalts.new(@recipe)
      end
      it "assigns an empty hash" do
        @service.order
        expect(@recipe.malts[:specialty]).to eq({})
      end
    end
    context "specialty malts present" do
      before do
        @recipe.malts[:specialty]= { malt => 2, malt_1 => 2.25, malt_2 => 0.5 }
        @service = OrderSpecialtyMalts.new(@recipe)
      end
      it "assigns @malts[:specialty] a hash ordered by malt amount" do
        expect(@recipe.malts[:specialty]).to eq({ malt_1 => 2.25, malt => 2, malt_2 => 0.5 })
      end
    end
  end
end