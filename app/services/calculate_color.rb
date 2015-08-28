class CalculateColor

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def calc_mcu(malt_ary)
    # calculates malt color units
    malt = MaltHelpers.pull_malt_object(malt_ary)
    weight = MaltHelpers.pull_malt_amt(malt_ary)
    malt.srm * weight / 5.0
  end

  def combine_mcu
    combined = 0.0
    @recipe.malts_to_array.each do | malt_ary |
      combined += calc_mcu(malt_ary)
    end
    return combined
  end

  def calc_srm
    ((combine_mcu ** 0.69) * 1.49).round(1)
    # Morey's logarithmic srm conversion
  end
end