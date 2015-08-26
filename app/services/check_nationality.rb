class CheckNationality

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def check
    if @recipe.name.include?('German')
      @recipe.name = swap_yeast_adjective_order(@recipe.name, 'German')
    end
    if @recipe.name.include?('Belgian')
      @recipe.name = swap_yeast_adjective_order(@recipe.name, 'Belgian')
    end
  end

  def swap_yeast_adjective_order(name, adjective)
    ((name.split - [adjective]).unshift([adjective])).join(' ')
  end
end