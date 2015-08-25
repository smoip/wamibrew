RSpec.shared_context "shared service variables" do
  before { @recipe = Recipe.new }
  let(:malt) { FactoryGirl.build(:malt) }
  let(:malt_1) { FactoryGirl.build(:malt, name: 'test malt_1', malt_yield: 0.7) }
  let(:malt_2) { FactoryGirl.build(:malt, name: 'test malt_2') }
end
