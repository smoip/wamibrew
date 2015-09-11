class SelectByAbv

  attr_accessor :abv

  def initialize(abv)
    @abv = abv
  end

  def select(style_list)
    subset = []
    style_list.each do |style|
      subset << style if ((style.abv_lower)..(style.abv_upper)).cover?(@abv)
    end
    return subset
  end

end