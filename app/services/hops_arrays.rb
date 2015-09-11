class HopsArrays

  attr_accessor :hops

  def initialize(hops)
    @hops = hops
  end

  def hops_to_array
    hop_ary = []
    unless @hops[:aroma].nil?
      @hops[:aroma].each do |aroma_hash|
        hop_ary << aroma_hash.to_a
      end
      hop_ary = hop_ary.flatten(1)
    end
    hop_ary.unshift(@hops[:bittering].to_a[0])
  end

  def hop_names_to_array
    hops_ary = hops_to_array.flatten.keep_if { |x| x.class == Hop }
    hops_ary.collect { |hop| hop.name }
  end
end