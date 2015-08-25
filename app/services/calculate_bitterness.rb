class CalculateBitterness

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def calc_ibu
    combined = 0.0
    @recipe.hops_to_array.each do |hop_ary|
      combined += calc_indiv_ibu(hop_ary)
    end
    @recipe.ibu = combined.round(1)
  end

  def calc_indiv_ibu(hop_ary)
    hop = @recipe.pull_hop_object(hop_ary)
    weight = @recipe.pull_hop_amt(hop_ary)
    time = @recipe.pull_hop_time(hop_ary)
    rager_ibu = ( weight * (calc_hop_util(time)) * (hop.alpha / 100) * 7462 ) / ( 5 * ( 1 + calc_hop_ga ) )
    rager_to_tinseth_q_and_d(time, rager_ibu)
    # comment out previous line to reset to Rager
  end

  def rager_to_tinseth_q_and_d(time, rager_ibu)
    # needed to match BJCP IBU style guidelines
    faux_tinseth = 0
    if time > 30
      faux_tinseth = rager_ibu * 0.78
    else
      faux_tinseth = rager_ibu * 1.16
    end
    return faux_tinseth
  end

  def calc_hop_util(minutes)
    # rager hop utilization
    # list 'magic numbers' as constants?
    (18.11 + (13.86 * Math.tanh((minutes - 31.32)/18.27))) / 100
  end

  def calc_hop_ga
    if @recipe.og > (1.058)
      (@recipe.og - 1.058) / 0.2
      # rager gravity adjustment
      # +0.008 added to extrapolate generic pre-boil from og
    else
      0
    end
  end

end