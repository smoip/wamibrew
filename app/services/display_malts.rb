class DisplayMalts

  attr_accessor :malts_ary

  def initialize(malts_ary)
    @malts_ary = malts_ary
  end

  def display
    display_array = []
    @malts_ary.each do |malt_ary|
      display_array << "#{MaltHelpers.pull_malt_amt(malt_ary)} lb #{MaltHelpers.pull_malt_name(malt_ary)}"
    end
    display_array.join(", ")
  end

end