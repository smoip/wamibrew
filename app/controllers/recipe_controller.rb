class RecipeController < ApplicationController

  def new
    @recipe = Recipe.new
    @recipe.choose_attributes
  end

  def show
  end

end
