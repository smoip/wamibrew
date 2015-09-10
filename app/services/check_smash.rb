class CheckSmash

  attr_accessor :style, :hops_names, :malts, :malts_ary, :hops_ary

  def initialize(style, hops_names, malts, malts_ary, hops_ary)
    @style = style
    @hops_names = hops_names
    @malts = malts
    @malts_ary = malts_ary
    @hops_ary = hops_ary
  end

  def check
    name = nil
    if @style == nil
      if single_malt? && single_hop?
        name = generate_smash_name
      end
    end
    name
  end

  def single_hop?
    ( hops_names.uniq == [ hops_names[0] ] ) ? true : false
  end

  def single_malt?
    ( @malts[:specialty] == {} ) ? true : false
  end

  def generate_smash_name
    malt = NameHelpers.capitalize_titles(MaltHelpers.pull_malt_name(malts_ary[0]))
    hop = NameHelpers.capitalize_titles(HopsHelpers.pull_hop_name(hops_ary[0]))
    "#{malt} #{hop} SMASH"
  end

end