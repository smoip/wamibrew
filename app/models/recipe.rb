class Recipe < ActiveRecord::Base

  attr_accessor :name, :style, :abv, :ibu, :srm, :malts, :hops, :yeast

  def create
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

  def choose_hop
    hop = Hop.find_by(id: rand(Hop.count) + 1)
    { hop => hop_amount(hop) }
  end

  def choose_yeast
    Yeast.find_by(id: rand(Yeast.count) + 1)
  end

  def assign_malts
    @malts = { :base => choose_malt(true), :specialty => choose_malt(false) }
  end

  def assign_hops
    @hops = { :bittering => choose_hop, :aroma => choose_hop }
  end

  def assign_yeast
    @yeast = choose_yeast
  end

  def calc_abv
    # (og - fg) * weight of ethanol / fg * 100 = ABW
    # ABW / 0.79 = ABV
    og = combine_og + 1.0
    fg = calc_fg(og)
    @abv = ((og - fg) * 1.05 / fg * 100 / 0.79).round(1)
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
  end

  def calc_mcu(malt_and_weight)
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

end