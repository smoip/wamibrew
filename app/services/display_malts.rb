class DisplayMalts

  attr_accessor :malts_ary

  def initialize(malts_ary)
    @malts_ary = malts_ary
  end

  def display
    display_array = []
    @malts_ary.each do |malt_ary|
      display_array << "#{decimal_to_mixed(MaltHelpers.pull_malt_amt(malt_ary))} #{MaltHelpers.pull_malt_name(malt_ary)}"
    end
    display_array.join(", ")
  end

  def decimal_to_mixed(amt)
    if amt == amt.truncate
      "#{pluralize_lbs(amt)}"
    elsif amt < 1
      "#{((amt - amt.truncate) * 16).to_i} oz"
    else
      "#{pluralize_lbs(amt.truncate)} #{((amt - amt.truncate) * 16).to_i} oz"
    end
  end

  def pluralize_lbs(lb_amt)
    if lb_amt == 1
      "#{lb_amt} lb"
    else
      "#{lb_amt} lbs"
    end
  end

end