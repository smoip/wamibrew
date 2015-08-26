class MaltsArrays

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def malts_to_array
    malt_ary = []
    unless @recipe.malts[:specialty] == {}
      @recipe.malts[:specialty].each do |malt_obj, amt|
        malt_ary << [malt_obj, amt]
      end
    end
    malt_ary.unshift(@recipe.malts[:base].to_a[0])
  end
end