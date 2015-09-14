require 'service_objects_helper'

describe DisplayMalts do
  include_context "shared service variables"

  let(:show_malts) { DisplayMalts.new([]) }

  describe "display" do
    context "with one malt" do
      it "returns a display string with one malt" do
        show_malts.malts_ary = [[malt, 10]]
        expect(show_malts.display).to eq('10 lb 2-row test')
      end
    end
    context "with multiple malts" do
      it "returns a display string with multiple malts" do
        show_malts.malts_ary = [[malt, 10], [malt_1, 2], [malt_2, 1]]
        expect(show_malts.display).to eq('10 lb 2-row test, 2 lb test malt_1, 1 lb test malt_2')
      end
    end
  end
end