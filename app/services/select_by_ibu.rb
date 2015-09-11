class SelectByIbu

  attr_accessor :ibu

  def initialize(ibu)
    @ibu = ibu
  end

  def select(style_list)
    subset = []
    style_list.each do |style|
      subset << style if ((style.ibu_lower)..(style.ibu_upper)).cover?(@ibu)
    end
    return subset
  end

end