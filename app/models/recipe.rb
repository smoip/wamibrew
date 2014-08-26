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
    malt_hash = { malt => malt_amount(malt) }
  end

  def choose_hop
    hop = Hop.find_by(id: rand(Hop.count) + 1)
    hop_hash = { hop => hop_amount(hop) }
  end

  def choose_yeast
    Yeast.find_by(id: rand(Yeast.count) + 1)
  end

  def assign_malts
    @malts = { :base => choose_malt(true), :specialty => choose_malt(false) }
  end

  def assign_hops
    @hops = { :bittering => nil, :aroma => nil }
  end

  def assign_yeast
    @yeast = choose_yeast
  end

  def calc_abv
  end

  def calc_ibu
  end

  def calc_srm
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