class SelectByMalts

  attr_accessor :malts_ary

  def initialize(malts_ary)
    @malts_ary = malts_ary
  end

  def select(style_list)
    subset = []
    style_list.each do |style|
      if style.required_malts.nil?
        subset << style
      elsif style.required_malts != nil
        # subset << style if malts_ary.flatten.include?(Malt.find_by_name(style.required_malts[0]))
        # does this only work for the first required malt?
        # Yes. Fuck.
        subset << style if (malts_ary.flatten & style.required_malts).sort == style.required_malts.sort
        # this is comparing malt objects and names - need to remove amounts from malts_ary and build an array of names only
        # to compare with name list in style definitions
      end
    end
    subset
  end
end


