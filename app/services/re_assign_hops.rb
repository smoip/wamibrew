class ReAssignHops
  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def extreme_ibu_check
    if @recipe.ibu > 120
      self.re_assign_hops
    end
  end

  def ibu_gravity_check
    if ( ( @recipe.abv <= 4.5 ) && ( @recipe.ibu > 60 ) )
      self.re_assign_hops
    elsif ( ( @recipe.abv <= 6 ) && ( @recipe.ibu > 90 ) )
      self.re_assign_hops
    end
  end

  def re_assign_hops
    @recipe.stack_token += 1
    @recipe.hops = { :bittering => {}, :aroma => [] }
    @recipe.assign_hops
    @recipe.calc_bitterness
    unless @recipe.stack_token > 15
      self.ibu_gravity_check
      self.extreme_ibu_check
    end
  end
end