class AddAdjective

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def add_adjective(name, adjective)
    if @recipe.style == nil
      @recipe.name = "#{adjective} #{name}"
    else
      if name.split(' ') == [ name ]
        index = 0
      elsif name == 'Pale Ale'
        index = 0
      elsif name == 'Red Ale'
        index = 0
      elsif name == 'Wheat Wine'
        index = 0
      else
        index = 1
    end
    @recipe.name = name.split(' ').insert(index, adjective).join(' ')
    end
  end
end