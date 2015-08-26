require 'service_objects_helper'

describe HopsArrays do
  include_context "shared service variables"

  let(:hops_arrays) { HopsArrays.new(@recipe) }

  describe "hops_to_array" do
    after { @recipe.hops = nil }
    context "with aroma hops" do
      it "returns bittering hops and one aroma hops" do
        @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] } ] }
        expect(hops_arrays.hops_to_array).to eq([ [ hop, [ 1.5, 60 ] ], [ hop, [ 1.0, 15 ] ] ])
      end

      it "returns bittering hops and multiple aroma hops" do
        @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] }, { hop => [ 2.25, 5 ] } ] }
        expect(hops_arrays.hops_to_array).to eq([ [ hop, [ 1.5, 60 ] ], [ hop, [ 1.0, 15 ] ], [ hop, [ 2.25, 5 ] ] ])
      end
    end

    context "without aroma hops" do
      it "returns bittering hops only" do
        @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :specialty => nil }
        expect(hops_arrays.hops_to_array).to eq([ [ hop, [ 1.5, 60 ] ] ])
      end
    end
  end

  describe "hop_names_to_array" do
    after { @recipe.hops = nil }
    context "has aroma hops" do
      it "returns bittering and aroma hops names in an array" do
        @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] }, { hop => [ 2.25, 5 ] } ] }
        expect(hops_arrays.hop_names_to_array).to eq([ 'cascade test', 'cascade test', 'cascade test' ])
      end
    end
    context "does not have aroma hops" do
      it "returns only bittering hops names in an array" do
        @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :specialty => nil }
        expect(hops_arrays.hop_names_to_array).to eq([ 'cascade test' ])
      end
    end
  end
end