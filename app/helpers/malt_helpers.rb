module MaltHelpers

  def self.pull_malt_object(malt_ary)
    malt_ary[0]
  end

  def self.pull_malt_name(malt_ary)
    malt_ary[0].name
  end

  def self.pull_malt_amt(malt_ary)
    malt_ary[1]
  end

end