# require 'spec_helper'

describe "variable assignment" do
  before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after { @recipe.destroy! }
  let(:malt) { FactoryGirl.build(:malt) }
  let(:malt_1) { FactoryGirl.build(:malt, name: 'test malt_1') }
  let(:malt_2) { FactoryGirl.build(:malt, name: 'test malt_2') }
  let(:hop) { FactoryGirl.build(:hop) }
  let(:yeast) { FactoryGirl.build(:yeast) }

  describe "malt assignment" do
    describe "malts_to_array" do
      after { @recipe.malts = nil }
      context "with specialty malts" do
        it "returns base malt and one specialty malt" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0 } }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ], [ malt_1, 1.0 ] ] )
        end

        it "returns base malt and multiple specialty malts" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0, malt_2 => 0.25 } }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ], [ malt_1, 1.0 ], [ malt_2, 0.25 ] ] )
        end
      end

      context "without specialty malts" do
        it "returns base malt only" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => {} }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ] ] )
        end
      end
    end

  end

  describe "hops assignment" do

    describe "hops_to_array" do
      after { @recipe.hops = nil }
      context "with aroma hops" do
        it "returns bittering hops and one aroma hops" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] } ] }
          expect( @recipe.hops_to_array ).to eq( [ [ hop, [ 1.5, 60 ] ], [ hop, [ 1.0, 15 ] ] ] )
        end

        it "returns bittering hops and multiple aroma hops" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] }, { hop => [ 2.25, 5 ] } ] }
          expect( @recipe.hops_to_array ).to eq( [ [ hop, [ 1.5, 60 ] ], [ hop, [ 1.0, 15 ] ], [ hop, [ 2.25, 5 ] ] ] )
        end
      end

      context "without aroma hops" do
        it "returns bittering hops only" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :specialty => nil }
          expect( @recipe.hops_to_array ).to eq( [ [ hop, [ 1.5, 60 ] ] ] )
        end
      end
    end

    describe "hop_names_to_array" do
      after { @recipe.hops = nil }
      context "has aroma hops" do
        it "returns bittering and aroma hops names in an array" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] }, { hop => [ 2.25, 5 ] } ] }
          expect( @recipe.hop_names_to_array ).to eq( [ 'cascade test', 'cascade test', 'cascade test' ] )
        end
      end
      context "does not have aroma hops" do
        it "returns only bittering hops names in an array" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :specialty => nil }
          expect( @recipe.hop_names_to_array ).to eq( [ 'cascade test' ] )
        end
      end
    end
  end

end