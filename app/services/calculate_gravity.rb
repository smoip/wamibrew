class CalculateGravity

  attr_accessor :yeast, :malts_ary

  WEIGHT_OF_ETHANOL = 1.05
  ABV_CONVERSION_FACTOR = 0.79

  def initialize(yeast, malts_ary)
    @yeast = yeast
    @malts_ary = malts_ary
  end

  def calc_abv
    # (og - fg) * weight of ethanol / fg * 100 = ABW
    # ABW / 0.79 = ABV
    og = combine_og + 1.0
    fg = calc_fg(og)
    [og, ((og - fg) * WEIGHT_OF_ETHANOL / fg * 100 / ABV_CONVERSION_FACTOR).round(1)]
  end

  def calc_og(malt_ary)
    return 0 if malt_ary.nil?
    malt = MaltHelpers.pull_malt_object(malt_ary)
    weight = MaltHelpers.pull_malt_amt(malt_ary)
    ((weight * pg_to_ep(malt.potential) * malt.malt_yield / 5.0) / 1000.0)
  end

  def calc_fg(og)
    1.0 + (pg_to_ep(og) * ((1.0 - (@yeast.attenuation/100.0)) / 1000.0))
  end

  def combine_og
    combined = 0.0
    @malts_ary.each do | malt_ary |
      combined += calc_og(malt_ary)
    end
    return combined
  end

  def pg_to_ep(potential)
    (potential - 1.0) * 1000
  end
end