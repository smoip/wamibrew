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


  describe "hops related" do
    describe "hop_names_to_array" do
      context "no hops present" do
        before { @recipe.hops = { :bittering => {}, :aroma => [] } }
        it "returns an empty array" do
          expect(@recipe.hop_names_to_array).to eq( [] )
        end
      end
      context "only bittering hops present" do
        before { @recipe.hops = { :bittering => { hop => [ 2.0, 60 ] }, :aroma => [] } }
        it "returns only a bittering hop name" do
          expect(@recipe.hop_names_to_array).to eq( ['cascade test'] )
        end
      end
      context "only aroma hops present" do
        it "returns a single aroma hop name" do
          @recipe.hops = { :bittering => {}, :aroma => [ { hop => [ 2.0, 10 ] } ] }
          expect(@recipe.hop_names_to_array).to eq( ['cascade test'] )
        end
        it "returns multiple aroma hop names" do
          @recipe.hops = { :bittering => {}, :aroma => [ { hop => [ 2.0, 10 ] }, { hop_1 => [ 1.25, 20 ] } ] }
          expect(@recipe.hop_names_to_array).to eq( ['cascade test', 'polaris'] )
        end
      end
      context "both bittering and aroma hops present" do
        before { @recipe.hops = { :bittering => { hop => [ 2.0, 60 ] }, :aroma => [ { hop_1 => [ 2.0, 10 ] }, { hop_2 => [ 1.25, 20 ] } ] } }
        it "returns bittering and aroma hops names" do
          expect(@recipe.hop_names_to_array).to eq( ['cascade test', 'polaris', 'aurora'] )
        end
      end
    end
  # hops_to_array

  # pull_hop_object
  # pull_hop_name
  # pull_hop_amt
  # pull_hop_time
  end

  describe "malt related" do
  # malts_to_array
  # pull_malt_object
  # pull_malt_name
  # pull_malt_amt
  end

  describe "display" do
  # display_hops
  # flat_hops_array
  # time_ordered_hops_hash
  # display_malts
  end

end