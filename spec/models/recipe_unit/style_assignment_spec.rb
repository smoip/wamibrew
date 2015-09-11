# require 'spec_helper'

describe "style determination" do
  before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after do
    @recipe.destroy!
  end
  let(:style) { FactoryGirl.build(:style) }
  let(:style_1) { FactoryGirl.build(:style, yeast_family: 'test', abv_upper: 5.8, abv_lower: 3.2,
    ibu_upper: 50, ibu_lower: 30, srm_upper: 12, srm_lower: 4) }
  let(:yeast) { FactoryGirl.build(:yeast) }
  let(:yeast_1) { FactoryGirl.build(:yeast, name: 'test ale', family: 'test') }
  let(:hop) { FactoryGirl.build(:hop) }
  let(:style_list) { [ style, style_1 ] }

  # # select_by_yeast
  # describe "select_by_yeast" do
  #   # learn how to mock database entries to unit test this method
  #   context "one matching style" do
  #     before do
  #       @recipe.yeast = yeast_1
  #     end
  #     after { style_1.destroy! }
  #     it "returns one style" do
  #       # expect(@recipe.select_by_yeast).to eq( [ style_1 ] )
  #     end
  #   end
  #   context "multiple matching styles" do
  #   end
  #   context "no matching styles" do
  #   end
  # end

  # describe "select_by_malt" do
  #   # learn how to mock database entries to unit test this method
  # end

  # describe "select_by_aroma" do
  #   let(:style_aroma_true) { FactoryGirl.build(:style, name: 'aroma needed', aroma_required?: true) }
  #   let(:style_aroma_false) { FactoryGirl.build(:style, name: 'aroma not needed', aroma_required?: false) }
  #   let(:style_list_1) { [ style_aroma_true, style_aroma_false ] }
  #   context "style_list includes aroma required style, aroma hops not present" do
  #     before { allow(@recipe).to receive(:aroma_present?).and_return(false) }
  #     it "returns at least one style" do
  #       expect(@recipe.select_by_aroma(style_list_1)).not_to eq( [] )
  #     end
  #     it "returns only aroma not required styles" do
  #       expect(@recipe.select_by_aroma(style_list_1)).not_to include( style_aroma_true )
  #     end
  #   end
  #   context "style_list includes aroma required style, aroma hops present" do
  #     it "returns at least one style" do
  #       expect(@recipe.select_by_aroma(style_list_1)).not_to eq( [] )
  #     end
  #     it "returns both aroma required styles and aroma not required styles" do
  #       allow(@recipe).to receive(:aroma_present?).and_return(true)
  #       expect(@recipe.select_by_aroma(style_list_1)).to (include( style_aroma_true ) && include(style_aroma_false))
  #     end
  #   end
  #   context "style_list does not include aroma required style, aroma hops not present" do
  #     before { allow(@recipe).to receive(:aroma_present?).and_return(false) }
  #     it "returns at least one style" do
  #       style_list_1 = [ style_aroma_false ]
  #       expect(@recipe.select_by_aroma(style_list_1)).not_to eq( [] )
  #     end
  #     it "returns only aroma not required styles" do
  #       style_list_1 = [ style_aroma_false ]
  #       expect(@recipe.select_by_aroma(style_list_1)).not_to include( style_aroma_true )
  #     end
  #   end
  #   context "style_list does not include aroma required style, aroma hops present" do
  #     before { allow(@recipe).to receive(:aroma_present?).and_return(true) }
  #     it "returns at least one style" do
  #       style_list_1 = [ style_aroma_false ]
  #       expect(@recipe.select_by_aroma(style_list)).not_to eq( [] )
  #     end
  #     it "returns only aroma not required styles" do
  #       style_list_1 = [ style_aroma_false ]
  #       expect(@recipe.select_by_aroma(style_list_1)).not_to include( style_aroma_true )
  #     end
  #   end
  # end

  # describe "aroma_present?" do
  #   context "aroma hops present" do
  #     it "returns true" do
  #       @recipe.hops[:aroma]= [ { hop => [ 1.25, 20 ] } ]
  #       expect(@recipe.aroma_present?).to be( true )
  #     end
  #   end
  #   context "aroma hops not present" do
  #     it "returns false" do
  #       @recipe.hops[:aroma]= []
  #       expect(@recipe.aroma_present?).to be( false )
  #     end
  #   end
  # end

  # describe "select_by_abv" do
  #   context "no styles cover @abv" do
  #     it "returns an empty array" do
  #       @recipe.abv = 3.0
  #       expect(@recipe.select_by_abv(style_list)).to eq([])
  #     end
  #   end
  #   context "one style covers @abv" do
  #     it "returns a single style in an array" do
  #       @recipe.abv = 7.0
  #       expect(@recipe.select_by_abv(style_list)).to eq([ style ])
  #     end
  #   end
  #   context "multiple styles cover @abv" do
  #     it "returns a list of multiple styles" do
  #       @recipe.abv = 5.6
  #       expect(@recipe.select_by_abv(style_list)).to eq([ style, style_1 ])
  #     end
  #   end
  # end

  # describe "select_by_ibu" do
  #   context "no styles cover @ibu" do
  #     it "returns an empty array" do
  #       @recipe.ibu = 99
  #       expect(@recipe.select_by_ibu(style_list)).to eq([])
  #     end
  #   end
  #   context "one style covers @ibu" do
  #     it "returns a single style in an array" do
  #       @recipe.ibu = 60
  #       expect(@recipe.select_by_ibu(style_list)).to eq([ style ])
  #     end
  #   end
  #   context "multiple styles cover @ibu" do
  #     it "returns a list of multiple styles" do
  #       @recipe.ibu = 45
  #       expect(@recipe.select_by_ibu(style_list)).to eq([ style, style_1 ])
  #     end
  #   end
  # end

  # describe "select_by_srm" do
  #   context "no styles cover @srm" do
  #     it "returns an empty array" do
  #       @recipe.srm = 19
  #       expect(@recipe.select_by_srm(style_list)).to eq([])
  #     end
  #   end
  #   context "one style covers @srm" do
  #     it "returns a single style in an array" do
  #       @recipe.srm = 13
  #       expect(@recipe.select_by_srm(style_list)).to eq([ style ])
  #     end
  #   end
  #   context "multiple styles cover @srm" do
  #     it "returns a list of multiple styles" do
  #       @recipe.srm = 10
  #       expect(@recipe.select_by_srm(style_list)).to eq([ style, style_1 ])
  #     end
  #   end
  # end

  describe "filter_possible_styles" do
    before do
      allow(@recipe).to receive(:select_by_yeast).and_return(nil)
      allow(@recipe).to receive(:select_by_malt).and_return(nil)
    end
    context "no style by aroma, malt, or yeast" do
      before { allow(@recipe).to receive(:select_by_aroma).and_return([]) }
      it "returns an empty array" do
        expect(@recipe.filter_possible_styles).to eq([])
      end
    end
    context "possible styles by aroma, malt, and yeast" do
      before do
        allow(@recipe).to receive(:select_by_aroma).and_return( style_list )
        allow(@recipe).to receive(:select_by_abv).and_return([ style ])
      end
      context "one of three matches" do
        it "returns an empty array" do
          expect(@recipe.filter_possible_styles).to eq([])
        end
      end
      context "two of three matches" do
        it "returns an empty array" do
          allow(@recipe).to receive(:select_by_ibu).and_return([ style ])
          expect(@recipe.filter_possible_styles).to eq([])
        end
      end
      context "all three matches, one possible style" do
        it "returns a style" do
          allow(@recipe).to receive(:select_by_ibu).and_return([ style ])
          allow(@recipe).to receive(:select_by_srm).and_return([ style ])
          expect(@recipe.filter_possible_styles).to eq([ style ])
        end
      end
      context "all three matches, multiple possible styles" do
        it "returns multiple styles" do
          allow(@recipe).to receive(:select_by_abv).and_return( style_list )
          allow(@recipe).to receive(:select_by_ibu).and_return( style_list )
          allow(@recipe).to receive(:select_by_srm).and_return( style_list )
          expect(@recipe.filter_possible_styles).to eq( style_list )
        end
      end
    end
  end

  describe "assign_style" do
    context "no style matches" do
      before { allow(@recipe).to receive(:filter_possible_styles).and_return([]) }
      it "does not assign a style" do
        @recipe.assign_style
        expect(@recipe.style).to eq(nil)
      end
    end
    context "one possible style" do
      before { allow(@recipe).to receive(:filter_possible_styles).and_return([style]) }
      it "assigns that style" do
        @recipe.assign_style
        expect(@recipe.style).to eq(style)
      end
    end
    context "multiple possible styles" do
      before do
        allow(@recipe).to receive(:filter_possible_styles).and_return(style_list)
        allow(@recipe).to receive(:filter_style_by_ingredients).and_return(style)
      end
      it "assigns a style" do
        @recipe.assign_style
        expect(@recipe.style).to eq(style)
      end
    end
  end
  # filter_style_by_ingredients
  describe "filter_style_by_ingredients" do
  end
  # tally_common_ingredients
  describe "tally_common_ingredients" do
  end

  describe "tally_common_malts" do
    # learn how to mock database entries to unit test this method
  end

  describe "tally_common_hops" do
    # learn how to mock database entries to unit test this method
  end

end