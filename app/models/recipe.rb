class Recipe < ActiveRecord::Base

  attr_accessor :name, :style, :abv, :ibu, :srm

  def create
  end

  def generate_name(style)
    @name = "#{style}"
  end

  def calc_abv
  end

  def calc_ibu
  end

  def calc_srm
  end

end