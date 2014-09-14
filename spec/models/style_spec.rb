require 'rails_helper'

describe "Styles" do
  before do
    @style = Style.new
    @recipe = Recipe.new
  end

  subject { @style }

  it { should respond_to(:name) }
  it { should respond_to(:yeast_family) }
  it { should respond_to(:abv) }
  it { should respond_to(:ibu) }
  it { should respond_to(:srm) }
  it { should respond_to(:required_malts) }
  it { should respond_to(:required_hops) }
  it { should respond_to(:common_malts) }
  it { should respond_to(:common_hops) }

end
