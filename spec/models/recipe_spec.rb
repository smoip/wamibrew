require 'rails_helper'

describe "Recipe" do
  before { @recipe = Recipe.new }

  subject  {@recipe }

  it { should respond_to(:name) }
  it { should respond_to(:style) }
  it { should respond_to(:abv) }
  it { should respond_to(:ibu) }
  it { should respond_to(:srm) }

end
