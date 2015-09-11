require 'service_objects_helper'

describe MaltsArrays do
  include_context "shared service variables"

  let(:malts_arrays) { MaltsArrays.new(@recipe.malts) }

  describe "malts_to_array" do
    after { malts_arrays.malts = nil }
    context "with specialty malts" do
      it "returns base malt and one specialty malt" do
        malts_arrays.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0 } }
        expect(malts_arrays.malts_to_array).to eq([ [ malt, 10.0 ], [ malt_1, 1.0 ] ])
      end
      it "returns base malt and multiple specialty malts" do
        malts_arrays.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0, malt_2 => 0.25 } }
        expect(malts_arrays.malts_to_array).to eq([ [ malt, 10.0 ], [ malt_1, 1.0 ], [ malt_2, 0.25 ] ])
      end
    end
    context "without specialty malts" do
      it "returns base malt only" do
        malts_arrays.malts = { :base => { malt => 10.0 }, :specialty => {} }
        expect(malts_arrays.malts_to_array).to eq([ [ malt, 10.0 ] ])
      end
    end
  end

  describe "malt_names_to_array" do
    after { malts_arrays.malts = nil }
    context "has specialty malts" do
      it "returns base and specialty malts names in an array" do
         malts_arrays.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0 } }
        expect(malts_arrays.malt_names_to_array).to eq([ '2-row test', 'test malt_1'])
      end
    end
    context "does not have specialty malts" do
      it "returns only base malts names in an array" do
        malts_arrays.malts = { :base => { malt => 10.0 }, :specialty => {} }
        expect(malts_arrays.malt_names_to_array).to eq([ '2-row test' ])
      end
    end
  end
end