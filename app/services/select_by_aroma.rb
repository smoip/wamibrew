class SelectByAroma

  attr_accessor :hops

  def initialize(hops)
    @hops = hops
  end

  def select(style_list)
    subset = style_list.dup
    unless aroma_present?
      style_list.each { |style| subset -= [style] if style.aroma_required? }
    end
    return subset
  end

  def aroma_present?
    aroma_present = false
    aroma_present = true if @hops[:aroma] != []
    aroma_present
  end

end