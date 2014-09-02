require 'rails_helper'

describe "Recipe Controller" do
  before { get new_recipe_path }
  it "should redirect properly" do
    expect(response).to redirect_to(new_recipe_path)
  end
end
