class Recipe < ActiveRecord::Base

  attr_accessor :name, :style, :abv, :ibu, :srm

  def create
  end

  def generate_name(style)
    @name = "#{style}"
  end

  def choose_malt
    @malt = Malt.find_by(id: 1)
  end

  def choose_hops
    @hops
  end

  def choose_yeast
    @yeast
  end

  def calc_abv
  end

  def calc_ibu
  end

  def calc_srm
  end

end