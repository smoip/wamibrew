require 'service_objects_helper'

describe DisplayHops do
  include_context "shared service variables"

  let(:show_hops) { DisplayHops.new(@recipe.hops_to_array) }

  describe "display" do
    before { allow(show_hops).to receive(:flat_hops_array).and_return(nil) }
    context "with one hop addition" do
      it "returns a display string with one hop only" do
        allow(show_hops).to receive(:time_ordered_hops_hash).and_return([[60, [hop, 2.0]]])
        expect(show_hops.display).to eq('2.0 oz cascade test @ 60 min')
      end
    end
    context "with multiple hop additions" do
      it "returns a display string with multiple hops" do
        allow(show_hops).to receive(:time_ordered_hops_hash).and_return([[60, [hop, 2.0]], [10, [hop_1, 2.0]], [20, [hop_2, 1.25]]])
        expect(show_hops.display).to eq('2.0 oz cascade test @ 60 min, 2.0 oz polaris @ 10 min, 1.25 oz aurora @ 20 min')
      end
    end
  end

  describe "flat_hops_array" do
    context "with bittering only" do
      before { show_hops.hops_ary = [[hop, [2, 60]]] }
      it "returns a time-formatted array with bittering hop only" do
        expect(show_hops.flat_hops_array).to eq([[60, [hop, 2.0]]])
      end
    end
    context "with aroma only" do
      before { show_hops.hops_ary = [[hop, [2, 10]]] }
      it "returns a time-formatted array with aroma hop only" do
        expect(show_hops.flat_hops_array).to eq([[10, [hop, 2.0]]])
      end
      it "does not return nil for the bittering hop slot" do
        expect(show_hops.flat_hops_array[0]).not_to eq(nil)
      end
    end
    context "with bittering and multiple aromas" do
      before { show_hops.hops_ary = [[hop, [2, 60]],[hop_1, [2, 10]],[hop_2, [1.25, 20]]] }
      it "returns a time-formatted array with bittering and aroma hops" do
        expect(show_hops.flat_hops_array).to eq([[60, [hop, 2.0]], [10, [hop_1, 2.0]], [20, [hop_2, 1.25]]])
      end
    end
  end

  describe "time_ordered_hops_hash" do
    context "one hop addition only" do
      it "returns single entry hash" do
        expect(show_hops.time_ordered_hops_hash([[10, [hop, 2.0]]])).to eq({ 10 => [hop, 2.0] })
      end
    end
    context "multiple hop additions" do
      it "returns a hash keyed by addition time in descending order" do
        expect(show_hops.time_ordered_hops_hash([[10, [hop, 2.0]], [20, [hop_1, 1.0]], [5, [hop_2, 1.25]]])).to eq({ 20 => [hop_1, 1], 10 => [hop, 2.0], 5 => [hop_2, 1.25] })
        expect(show_hops.time_ordered_hops_hash([[20, [hop_1, 1.0]], [10, [hop, 2.0]], [5, [hop_2, 1.25]]])).to eq({ 20 => [hop_1, 1], 10 => [hop, 2.0], 5 => [hop_2, 1.25] })
      end
    end
  end

end