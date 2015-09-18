require 'service_objects_helper'

describe DisplayMalts do
  include_context "shared service variables"

  let(:show_malts) { DisplayMalts.new([]) }

  describe "display" do
    before { allow(show_malts).to receive(:decimal_to_mixed).with(10).and_return('10 lbs') }
    context "with one malt" do
      it "returns a display string with one malt" do
        show_malts.malts_ary = [[malt, 10]]
        expect(show_malts.display).to eq('10 lbs 2-row test')
      end
    end
    context "with multiple malts" do
      it "returns a display string with multiple malts" do
        allow(show_malts).to receive(:decimal_to_mixed).with(2).and_return('2 lbs')
        allow(show_malts).to receive(:decimal_to_mixed).with(1).and_return('1 lb')
        show_malts.malts_ary = [[malt, 10], [malt_1, 2], [malt_2, 1]]
        expect(show_malts.display).to eq('10 lbs 2-row test, 2 lbs test malt_1, 1 lb test malt_2')
      end
    end
  end

  describe "decimal_to_mixed" do
    before { allow(show_malts).to receive(:pluralize_lbs).with(4).and_return('4 lbs') }
    context "with a whole number pound amount" do
      it "returns a string format x lb" do
        expect(show_malts.decimal_to_mixed(4)).to eq('4 lbs')
      end
    end
    context "with a decimal pound amount" do
      it "returns a string format x lb y oz" do
        expect(show_malts.decimal_to_mixed(4.25)).to eq('4 lbs 4 oz')
      end
    end
    context "with less than one pound" do
      it "returns a string format y oz" do
        expect(show_malts.decimal_to_mixed(0.25)).to eq('4 oz')
      end
    end
  end

  describe "pluralize_lbs" do
    context "1 pound" do
      it "returns string format x lb" do
        expect(show_malts.pluralize_lbs(1)).to eq('1 lb')
      end
    end
    context "> 1 pound" do
      it "returns string format x lbs" do
        expect(show_malts.pluralize_lbs(4)).to eq('4 lbs')
      end
    end
  end
end