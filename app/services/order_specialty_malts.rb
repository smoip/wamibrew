class OrderSpecialtyMalts

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def order
    specialty_ary = ( @recipe.malts[:specialty].sort_by { |malt, amt| amt } ).reverse
    @recipe.malts[:specialty]= Hash[*specialty_ary.flatten]
  end

end