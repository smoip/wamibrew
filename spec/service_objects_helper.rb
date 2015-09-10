RSpec.shared_context "shared service variables" do
  before { @recipe = Recipe.new }
  let(:malt) { FactoryGirl.build(:malt) }
  let(:malt_1) { FactoryGirl.build(:malt, name: 'test malt_1', malt_yield: 0.7) }
  let(:malt_2) { FactoryGirl.build(:malt, name: 'test malt_2') }
  let(:malt_3) { FactoryGirl.build(:malt, name: 'test specialty', base_malt?: false) }
  let(:malt_rye) { Malt.find_by_name('rye malt') }
  let(:malt_wheat) { Malt.find_by_name('white wheat') }
  let(:yeast) { FactoryGirl.build(:yeast) }
  let(:hop) { FactoryGirl.build(:hop) }
  let(:style) { FactoryGirl.build(:style) }
  let(:sugar) { Malt.find_by_name('honey') }
end
