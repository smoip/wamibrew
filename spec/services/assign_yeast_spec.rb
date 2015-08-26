require 'service_objects_helper'

describe AssignYeast do
  include_context "shared service variables"

  let(:pick_yeast) { AssignYeast.new(@recipe) }

  describe "choose_yeast" do
    it "should choose a yeast" do
      expect(pick_yeast.choose_yeast).to be_kind_of(Yeast)
    end
  end

  describe "associate_yeast" do
    let(:two_row) { Malt.find_by_name("2-row") }
    let(:vienna) { Malt.find_by_name("vienna") }
    context "base malt has associated yeast" do
      before { @recipe.malts = { :base => { two_row => 10.0 }, :specialty => {} } }
      it "chooses an associated yeast by family" do
        expect(pick_yeast.associate_yeast.family).to eq('ale')
      end
    end
    context "base malt does not have associated yeast" do
      before { @recipe.malts = { :base => { vienna => 10.0 }, :specialty => {} } }
      it "chooses any yeast" do
        expect(pick_yeast.associate_yeast).to be_kind_of(Yeast)
      end
    end
  end
end