class TallyIngredients

  attr_accessor :malt_names, :hops_names

  def initialize(malt_names, hops_names)
    @malt_names = malt_names
    @hops_names = hops_names
  end

  def tally_common(style_list)
    malt_tally = {}
    hop_tally = {}
    style_list.each do |style|
      malt_tally.merge!(tally_common_malts(style)) { |style, old_tally, new_tally| old_tally + new_tally }
      hop_tally.merge!(tally_common_hops(style)) { |style, old_tally, new_tally| old_tally + new_tally }
    end
    return [ malt_tally, hop_tally ]
  end

  def tally_common_malts(style)
    tally = { style => 0 }
    unless style.common_malts.nil?
      style.common_malts.each do |malt_name|
        # if malts_ary.flatten.include?(Malt.find_by_name(malt))
        #   tally[style]+= 1
        # end
        if @malt_names.include?(malt_name)
          tally[style]+= 1
        end
      end
    end
    return tally
  end

  def tally_common_hops(style)
    tally = { style => 0 }
    unless style.common_hops.nil?
      style.common_hops.each do |hop_name|
        # if hops_ary.flatten.include?(Hop.find_by_name(hop))
        #   tally[style]+= 1
        # end
        if @hops_names.include?(hop_name)
          tally[style]+= 1
        end
      end
    end
    return tally
  end

end