require 'rails_helper'

describe "helper methods" do
    before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after { @recipe.destroy! }
  let(:hop) { FactoryGirl.build(:hop) }
  let(:hop_1) { FactoryGirl.build(:hop, name: 'polaris') }
  let(:hop_2) { FactoryGirl.build(:hop, name: 'aurora') }
  let(:malt) { FactoryGirl.build(:malt) }
  let(:malt_1) { FactoryGirl.build(:malt, name: 'rye malt') }
  let(:malt_2) { FactoryGirl.build(:malt, name: 'black malt') }
  let(:no_hops) { { :bittering => {}, :aroma => [] } }
  let(:bitter_only) { { :bittering => { hop => [ 2.0, 60 ] }, :aroma => [] } }
  let(:one_aroma_no_bitter) { { :bittering => {}, :aroma => [ { hop => [ 2.0, 10 ] } ] } }
  let(:two_aroma_no_bitter) { { :bittering => {}, :aroma => [ { hop => [ 2.0, 10 ] }, { hop_1 => [ 1.25, 20 ] } ] } }
  let(:bitter_and_two_aroma) { { :bittering => { hop => [ 2.0, 60 ] }, :aroma => [ { hop_1 => [ 2.0, 10 ] }, { hop_2 => [ 1.25, 20 ] } ] } }

  describe "hops related" do
    describe "hop_names_to_array" do
      context "no hops present" do
        before { @recipe.hops = no_hops }
        it "returns an empty array" do
          expect(@recipe.hop_names_to_array).to eq( [] )
        end
      end
      context "only bittering hops present" do
        before { @recipe.hops = bitter_only }
        it "returns only a bittering hop name" do
          expect(@recipe.hop_names_to_array).to eq( ['cascade test'] )
        end
      end
      context "only aroma hops present" do
        it "returns a single aroma hop name" do
          @recipe.hops = one_aroma_no_bitter
          expect(@recipe.hop_names_to_array).to eq( ['cascade test'] )
        end
        it "returns multiple aroma hop names" do
          @recipe.hops = two_aroma_no_bitter
          expect(@recipe.hop_names_to_array).to eq( ['cascade test', 'polaris'] )
        end
      end
      context "both bittering and aroma hops present" do
        before { @recipe.hops = bitter_and_two_aroma }
        it "returns bittering and aroma hops names" do
          expect(@recipe.hop_names_to_array).to eq( ['cascade test', 'polaris', 'aurora'] )
        end
      end
    end

    describe "hops_to_array" do
      context "no hops present" do
        before { @recipe.hops = no_hops }
        it "returns an empty array" do
          expect(@recipe.hops_to_array).to eq( [ nil ] )
        end
      end
      context "only bittering hops present" do
        before { @recipe.hops = bitter_only }
        it "returns an array of one hop object" do
          expect(@recipe.hops_to_array).to eq( [ [ hop, [ 2.0, 60 ] ] ] )
        end
      end
      context "only aroma hops present" do
        it "returns an array of one hop object" do
          @recipe.hops = one_aroma_no_bitter
          expect(@recipe.hops_to_array).to eq( [ nil, [ hop, [ 2.0, 10 ] ] ] )
        end
        it "returns an array of multiple hop objects" do
          @recipe.hops = two_aroma_no_bitter
          expect(@recipe.hops_to_array).to eq( [ nil, [ hop, [ 2.0, 10 ] ], [ hop_1, [ 1.25, 20 ] ] ] )
        end
      end
      context "both bittering and aroma hops present" do
        before { @recipe.hops = bitter_and_two_aroma }
        it "returns an array of multiple hop objects" do
          expect(@recipe.hops_to_array).to eq( [ [ hop, [ 2.0, 60 ] ], [ hop_1, [ 2.0, 10 ] ], [ hop_2, [ 1.25, 20 ] ] ] )
        end
      end
    end
  end

  describe "malt related" do

    describe "malts_to_array" do
      context "only basemalt present" do
        before { @recipe.malts = { :base => { malt => 10 }, :specialty => {} } }
        it "returns an array of one malt object" do
          expect(@recipe.malts_to_array).to eq( [ [ malt, 10 ] ] )
        end
      end
      context "both basemalt and specialty grains present" do
        it "returns an array containing both base and one specialty grain" do
          @recipe.malts = { :base => { malt => 10 }, :specialty => { malt_1 => 2 } }
          expect(@recipe.malts_to_array).to eq( [ [ malt, 10 ], [ malt_1, 2 ] ] )
        end
        it "returns an array containing both base and multiple specialty grains" do
          @recipe.malts = { :base => { malt => 10 }, :specialty => { malt_1 => 2, malt_2 => 1 } }
          expect(@recipe.malts_to_array).to eq( [ [ malt, 10 ], [ malt_1, 2 ], [ malt_2, 1 ] ] )
        end
      end
    end
  end

  describe "display" do
    describe "display_hops" do
      before { allow(@recipe).to receive(:flat_hops_array).and_return( nil ) }
      context "with one hop addition" do
        it "returns a display string with one hop only" do
          allow(@recipe).to receive(:time_ordered_hops_hash).and_return( [ [ 60, [ hop, 2.0 ] ] ] )
          expect(@recipe.display_hops).to eq( '2.0 oz cascade test @ 60 min' )
        end
      end
      context "with multiple hop additions" do
        it "returns a display string with multiple hops" do
          allow(@recipe).to receive(:time_ordered_hops_hash).and_return( [ [ 60, [ hop, 2.0 ] ], [ 10, [ hop_1, 2.0 ] ], [ 20, [ hop_2, 1.25 ] ] ] )
          expect(@recipe.display_hops).to eq( '2.0 oz cascade test @ 60 min, 2.0 oz polaris @ 10 min, 1.25 oz aurora @ 20 min' )
        end
      end
    end

    describe "flat_hops_array" do
      context "with bittering only" do
        before { @recipe.hops = bitter_only }
        it "returns a time-formatted array with bittering hop only" do
          expect(@recipe.flat_hops_array).to eq( [ [ 60, [ hop, 2.0 ] ] ] )
        end
      end
      context "with aroma only" do
        before { @recipe.hops = one_aroma_no_bitter }
        it "returns a time-formatted array with aroma hop only" do
          expect(@recipe.flat_hops_array).to eq( [ [ 10, [ hop, 2.0 ] ] ] )
        end
        it "does not return nil for the bittering hop slot" do
          expect(@recipe.flat_hops_array[0]).not_to eq( nil )
        end
      end
      context "with bittering and multiple aromas" do
        before { @recipe.hops = bitter_and_two_aroma }
        it "returns a time-formatted array with bittering and aroma hops" do
          expect(@recipe.flat_hops_array).to eq( [ [ 60, [ hop, 2.0 ] ], [ 10, [ hop_1, 2.0 ] ], [ 20, [ hop_2, 1.25 ] ] ] )
        end
      end
    end

    describe "time_ordered_hops_hash" do
      context "one hop addition only" do
        it "returns single entry hash" do
          expect(@recipe.time_ordered_hops_hash( [ [ 10, [ hop, 2.0 ] ] ] ) ).to eq( { 10 => [ hop, 2.0 ] } )
        end
      end
      context "multiple hop additions" do
        it "returns a hash keyed by addition time in descending order" do
          expect(@recipe.time_ordered_hops_hash( [ [ 10, [ hop, 2.0 ] ], [ 20, [ hop_1, 1.0 ] ], [ 5, [ hop_2, 1.25 ] ] ] ) ).to eq( { 20 => [ hop_1, 1 ], 10 => [ hop, 2.0 ], 5 => [ hop_2, 1.25 ] } )
          expect(@recipe.time_ordered_hops_hash( [ [ 20, [ hop_1, 1.0 ] ], [ 10, [ hop, 2.0 ] ], [ 5, [ hop_2, 1.25 ] ] ] ) ).to eq( { 20 => [ hop_1, 1 ], 10 => [ hop, 2.0 ], 5 => [ hop_2, 1.25 ] } )
        end
      end
    end

    describe "display_malts" do
      context "with one malt" do
        it "returns a display string with one malt" do
          allow(@recipe).to receive(:malts_to_array).and_return( [ [ malt, 10 ] ] )
          expect(@recipe.display_malts).to eq( '10 lb 2-row test' )
        end
      end
      context "with multiple malts" do
        it "returns a display string with one malt" do
          allow(@recipe).to receive(:malts_to_array).and_return( [ [ malt, 10 ], [ malt_1, 2 ], [ malt_2, 1 ] ] )
          expect(@recipe.display_malts).to eq( '10 lb 2-row test, 2 lb rye malt, 1 lb black malt' )
        end
      end
    end
  end

end