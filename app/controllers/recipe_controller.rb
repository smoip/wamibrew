class RecipeController < ApplicationController

  def new
    @recipe = Recipe.new
  end

  def show
  end

  def choose_malt
    @malt = Malt.new
  end

  def choose_hops
    @hops
  end

  def choose_yeast
    @yeast
  end

end
