class Recipe < ActiveRecord::Base

  attr_accessor :name, :style, :abv, :ibu, :srm, :malts, :hops, :yeast, :og

  def choose_attributes
    self.assign_malts
    self.assign_hops
    self.assign_yeast
    self.calc_abv
    self.calc_srm
    self.calc_ibu
    # needs to call generate name once Style is done
  end

  def generate_name(style)
    @name = "#{style}"
  end

  def choose_malt(malt_type)
    match = false
    until match == true
      malt = Malt.find_by(id: rand(Malt.count) + 1)
      if malt.base_malt? == malt_type
        match = true
      end
    end
    { malt => malt_amount(malt) }
  end

  def choose_hop(hop_type)
    hop = Hop.find_by(id: rand(Hop.count) + 1)
    { hop => [ hop_amount(hop), hop_time(hop_type) ] }
  end

  def choose_yeast
    yeast = nil
    until yeast != nil do
      yeast = Yeast.find_by(id: rand(Yeast.count) + 1)
    end
    return yeast
  end

  def assign_malts
    @malts = { :base => choose_malt(true), :specialty => choose_malt(false) }
  end

  def assign_hops
    @hops = { :bittering => choose_hop(true), :aroma => choose_hop(false) }
    # :aroma => choose_aroma_hops
    # then refactor any method that pulls info from @recipe.hops[:aroma] to accomodate an array
    # then a new method to order the aroma hop array by hop_time
    # then copy structure to allow for multiple specialty malts
  end

  def assign_yeast
    @yeast = choose_yeast
  end

  def num_aroma_hops
    rand(5)
  end

  def choose_aroma_hops
    late_additions = num_aroma_hops
    if late_additions == 0
      return nil
    else
      aroma_hops = []
      late_additions.times do
        aroma_hops << choose_hop(false)
      end
    end
    return aroma_hops
  end

  def calc_abv
    # (og - fg) * weight of ethanol / fg * 100 = ABW
    # ABW / 0.79 = ABV
    @og = combine_og + 1.0
    fg = calc_fg(@og)
    @abv = ((@og - fg) * 1.05 / fg * 100 / 0.79).round(1)
  end

  def calc_og(malt_and_weight)
    malt = malt_and_weight.to_a[0][0]
    weight = malt_and_weight[malt]
    ((weight * pg_to_ep(malt.potential) * malt.malt_yield / 5.0) / 1000.0)
  end

  def calc_fg(og)
    1.0 + (pg_to_ep(og) * ((1.0 - (@yeast.attenuation/100.0)) / 1000.0))
  end

  def combine_og
    combined = 0.0
    combined += calc_og(@malts[:base])
    # refactor to include multiple basemalts
    # same structure as below
    @malts[:specialty].each do | malt, amount |
       combined += calc_og({ malt => amount })
    end
    return combined
  end

  def pg_to_ep(potential)
    (potential - 1.0) * 1000
  end

  def calc_ibu
    combined = 0.0
    combined += calc_indiv_ibu(@hops[:bittering])
    @hops[:aroma].each do | hop, weight_time |
       combined += calc_indiv_ibu({ hop => weight_time })
    end
    @ibu = combined.round(1)
  end

  def calc_indiv_ibu(hop_weight_time)
    hop = hop_weight_time.to_a[0][0]
    weight = hop_weight_time[hop][0]
    time = hop_weight_time[hop][1]
    ( weight * (calc_hop_util(time)) * (hop.alpha / 100) * 7462 ) / ( 5 * ( 1 + calc_hop_ga ) )
  end

  def calc_hop_util(minutes)
    # rager hop utilization
    (18.11 + (13.86 * Math.tanh((minutes - 31.32)/18.27))) / 100
  end

  def calc_hop_ga
    if @og > (1.058)
      (@og - 1.058) / 0.2
      # rager gravity adjustment
      # +0.008 added to extrapolate generic pre-boil from og
    else
      0
    end
  end

  def calc_mcu(malt_and_weight)
    # calculates malt color units
    malt = malt_and_weight.to_a[0][0]
    weight = malt_and_weight[malt]
    malt.srm * weight / 5.0
  end

  def combine_mcu
    combined = 0.0
    combined += calc_mcu(@malts[:base])
    # refactor to include multiple basemalts
    # same structure as below
    @malts[:specialty].each do | malt, amount |
       combined += calc_mcu({ malt => amount })
    end
    return combined
  end

  def calc_srm
    @srm = ((combine_mcu ** 0.69) * 1.49).round(1)
    # Morey's logarithmic srm conversion
  end

private

  def malt_amount(malt)
    if malt.base_malt?
      rand(15) + 1.0
    else
      (rand(4) + 1) / 2.0
    end
  end

  def hop_amount(hop)
    (rand(6) + 1) / 2.0
  end

  def hop_time(hop_type)
    if hop_type
      if rand(3) == 0
        60
        # force to 60 1/3 of attempts
      else
        round_to_fives(rand(25) + 41)
        # pick a number between 60 and 40 rounded to 5
        # adjusted for truncation rounding
      end
    else
      # pick a number between 30 and 0 rounded to 5
      round_to_fives(rand(35))
    end
  end

  def round_to_fives(number)
    (number / 5).round * 5
  end
end