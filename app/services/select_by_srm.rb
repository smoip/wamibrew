class SelectBySrm

  attr_accessor :srm

  def initialize(srm)
    @srm = srm
  end

  def select(style_list)
    subset = []
    style_list.each do |style|
      subset << style if ((style.srm_lower)..(style.srm_upper)).cover?(@srm)
    end
    return subset
  end

end