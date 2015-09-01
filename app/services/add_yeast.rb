class AddYeast

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def add_yeast
    if @recipe.style == nil
      if (rand(4) == 1) & (@recipe.name.include?("Beer"))
        unless @recipe.yeast.family == 'wheat'
          @recipe.name = ((@recipe.name.split(' ') - ["Beer"]) + [ NameHelpers.capitalize_titles(@recipe.yeast.family) ] ).join(' ')
        end
      end
    end
  end
end