class AssignYeast

  attr_accessor :recipe

  MALT_ASSOCIATIONS = { "2-row" => "ale", "pilsen" => "lager", "white wheat" => "wheat", "maris otter" => "ale", "vienna" => "lager", "golden promise" => "ale" }

  def initialize(recipe)
    @recipe = recipe
  end

  def associate_yeast
    base_malt_name = @recipe.pull_malt_name(@recipe.malts[:base].to_a[0])
    if MALT_ASSOCIATIONS[base_malt_name] != nil
      yeast = Yeast.find_by(family: "#{MALT_ASSOCIATIONS[base_malt_name]}")
      return yeast
    else
      choose_yeast
    end
  end

  def choose_yeast
    yeast = nil
    until yeast != nil do
      yeast = Yeast.find_by(id: rand(Yeast.count) + 1)
    end
    return yeast
  end

end