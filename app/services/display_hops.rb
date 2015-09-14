class DisplayHops

  attr_accessor :hops_ary

  def initialize(hops_ary)
    @hops_ary = hops_ary
  end

  def display
    display_array = []
    time_ordered_hops_hash(flat_hops_array).each do |time, ary|
      display_array << "#{ary[1]} oz #{ary[0].name} @ #{time} min"
    end
    display_array.join(", ")
  end

  def flat_hops_array
    hop_ary = hops_ary.collect do |hop_addition|
      if hop_addition
        [ hop_addition[1][1], [ hop_addition[0], hop_addition[1][0] ] ]
      end
    end
    (hop_ary[0] == nil) ? hop_ary -= [nil] : hop_ary
  end

  def time_ordered_hops_hash(flat_array)
    ordered_hash = {}
    flat_array.sort.reverse.each do |timed_hops|
      ordered_hash[timed_hops[0]]= timed_hops[1]
    end
    return ordered_hash
  end

end