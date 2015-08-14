require 'rails_helper'

describe "style determination" do
  before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after do
    @recipe.destroy!
  end
  let(:style) { FactoryGirl.build(:style) }
  let(:style_1) { FactoryGirl.build(:style, yeast_family: 'test') }
  let(:yeast) { FactoryGirl.build(:yeast) }
  let(:yeast_1) { FactoryGirl.build(:yeast, name: 'test ale', family: 'test') }
  let(:hop) { FactoryGirl.build(:hop) }

  # select_by_yeast
  describe "select_by_yeast" do
    context "one matching style" do
      before do
        @recipe.yeast = yeast_1
      end
      after { style_1.destroy! }
      it "returns one style" do
        # expect(@recipe.select_by_yeast).to eq( [ style_1 ] )
      end
    end
    context "multiple matching styles" do
    end
    context "no matching styles" do
    end
  end
  # select_by_malt
  describe "select_by_malt" do
  end

  describe "select_by_aroma" do
    let(:style_aroma_true) { FactoryGirl.build(:style, name: 'aroma needed', aroma_required?: true) }
    let(:style_aroma_false) { FactoryGirl.build(:style, name: 'aroma not needed', aroma_required?: false) }
    let(:style_list) { [ style_aroma_true, style_aroma_false ] }
    context "style_list includes aroma required style, aroma hops not present" do
      before { allow(@recipe).to receive(:aroma_present?).and_return(false) }
      it "returns at least one style" do
        expect(@recipe.select_by_aroma(style_list)).not_to eq( [] )
      end
      it "returns only aroma not required styles" do
        expect(@recipe.select_by_aroma(style_list)).not_to include( style_aroma_true )
      end
    end
    context "style_list includes aroma required style, aroma hops present" do
      it "returns at least one style" do
        expect(@recipe.select_by_aroma(style_list)).not_to eq( [] )
      end
      it "returns both aroma required styles and aroma not required styles" do
        allow(@recipe).to receive(:aroma_present?).and_return(true)
        expect(@recipe.select_by_aroma(style_list)).to (include( style_aroma_true ) && include(style_aroma_false))
      end
    end
    context "style_list does not include aroma required style, aroma hops not present" do
      before { allow(@recipe).to receive(:aroma_present?).and_return(false) }
      it "returns at least one style" do
        style_list = [ style_aroma_false ]
        expect(@recipe.select_by_aroma(style_list)).not_to eq( [] )
      end
      it "returns only aroma not required styles" do
        style_list = [ style_aroma_false ]
        expect(@recipe.select_by_aroma(style_list)).not_to include( style_aroma_true )
      end
    end
    context "style_list does not include aroma required style, aroma hops present" do
      before { allow(@recipe).to receive(:aroma_present?).and_return(true) }
      it "returns at least one style" do
        style_list = [ style_aroma_false ]
        expect(@recipe.select_by_aroma(style_list)).not_to eq( [] )
      end
      it "returns only aroma not required styles" do
        style_list = [ style_aroma_false ]
        expect(@recipe.select_by_aroma(style_list)).not_to include( style_aroma_true )
      end
    end
  end

  describe "aroma_present?" do
    context "aroma hops present" do
      it "returns true" do
        @recipe.hops[:aroma]= [ { hop => [ 1.25, 20 ] } ]
        expect(@recipe.aroma_present?).to be( true )
      end
    end
    context "aroma hops not present" do
      it "returns false" do
        @recipe.hops[:aroma]= []
        expect(@recipe.aroma_present?).to be( false )
      end
    end
  end

  # select_by_abv
  describe "select_by_abv" do
  end
  # select_by_ibu
  describe "select_by_ibu" do
  end
  # select_by_srm
  describe "select_by_srm" do
  end
  # filter_possible_styles
  describe "filter_possible_styles" do
  end
  # assign_style
  describe "assign_style" do
  end
  # filter_style_by_ingredients
  describe "filter_style_by_ingredients" do
  end
  # tally_common_ingredients
  describe "tally_common_ingredients" do
  end
  # tally_common_malts
  describe "tally_common_malts" do
  end
  # tally_common_hops
  describe "tally_common_hops" do
  end

end