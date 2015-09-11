class SelectByMalts

  attr_accessor :malt_names_ary

  def initialize(malt_names_ary)
    @malt_names_ary = malt_names_ary
  end

  def select(style_list)
    subset = []
    style_list.each do |style|
      if style.required_malts.nil?
        subset << style
      elsif style.required_malts != nil
        subset << style if (malt_names_ary & style.required_malts).sort == style.required_malts.sort
      end
    end
    subset
  end
end


