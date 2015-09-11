require 'service_objects_helper'

describe SelectByMalts do
  include_context "shared service variables"

  let(:by_malts) { SelectByMalts.new([]) }
  let(:style_1) { FactoryGirl.build(:style, name: 'malt match test', required_malts: ['malt_match_1']) }
  let(:malt_4) { FactoryGirl.create(:malt, name: 'malt_match_1') }

  before do
    malt_4.save!
    by_malts.malts_ary = [[malt_4, 5]]
  end

  after { malt_4.destroy! }
  context "includes a style which requires present malt" do
    it "returns one style" do
      expect(by_malts.select([style_1])).to eq([style_1])
    end
  end

  context "does not include a style which requires an absent malt" do
    let(:style_2) { FactoryGirl.build(:style, required_malts: ['malt_match_2']) }
    let(:style_3) { FactoryGirl.build(:style, required_malts: ['malt_match_1', 'malt_match_2']) }
    it "does not return a style whose only required malt is missing" do
      expect(by_malts.select([style_1, style_2])).not_to include(style_2)
    end
    it "does not return a style whose subsequent required malt is missing" do
      expect(by_malts.select([style_1, style_3])).not_to include(style_3)
    end
  end

  context "includes a style which has no required malts" do
    it "returns the new style" do
      expect(by_malts.select([style, style_1])).to include(style)
    end
  end

end

# includes a style which requires present malt
# does not include styles which requires an absent malt
# includes a style which has no required malts