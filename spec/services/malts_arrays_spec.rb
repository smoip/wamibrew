require 'service_objects_helper'

describe MaltsArrays do
  include_context "shared service variables"

  let(:malts_arrays) { MaltsArrays.new(@recipe) }

  describe "malts_to_array" do
    after { @recipe.malts = nil }
    context "with specialty malts" do
      it "returns base malt and one specialty malt" do
        @recipe.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0 } }
        expect(malts_arrays.malts_to_array).to eq([ [ malt, 10.0 ], [ malt_1, 1.0 ] ])
      end

      it "returns base malt and multiple specialty malts" do
        @recipe.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0, malt_2 => 0.25 } }
        expect(malts_arrays.malts_to_array).to eq([ [ malt, 10.0 ], [ malt_1, 1.0 ], [ malt_2, 0.25 ] ])
      end
    end

    context "without specialty malts" do
      it "returns base malt only" do
        @recipe.malts = { :base => { malt => 10.0 }, :specialty => {} }
        expect(malts_arrays.malts_to_array).to eq([ [ malt, 10.0 ] ])
      end
    end
  end
end