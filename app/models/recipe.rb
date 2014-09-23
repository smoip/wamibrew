class Recipe < ActiveRecord::Base

  attr_accessor :name, :style, :abv, :ibu, :srm, :malts, :hops, :yeast, :og

  def initialize
    @malts = { :base => {}, :specialty => {} }
    @name = "a beer"
    super
  end

  def choose_attributes
    self.assign_malts
    self.assign_hops
    self.assign_yeast
    self.calc_abv
    self.calc_srm
    self.calc_ibu
    self.assign_style
    self.generate_name
  end

  def generate_name
    @name = @style.name unless @style == nil
  end

  def choose_malt(malt_type)
    match = false
    until match == true
      malt = Malt.find_by(id: rand(Malt.count) + 1)
      if malt.base_malt? == malt_type
        match = true
      end
    end
    type_key = malt_type_to_key(malt_type)
    store_malt(type_key, malt)
  end

  def store_malt(type_key, malt)
    if @malts[type_key][malt] == nil
      @malts[type_key][malt]= malt_amount(malt)
    else
      @malts[type_key][malt]+= malt_amount(malt)
    end
  end

  def malt_type_to_key(malt_type)
    if malt_type == true
      key = :base
    else
      key = :specialty
    end
    return key
  end

  def num_specialty_malts
    rand(4)
    # needs probability weighting table
  end

  def choose_hop(hop_type)
    hop = Hop.find_by(id: rand(Hop.count) + 1)
    { hop => [ hop_amount(hop), hop_time(hop_type) ] }
  end

  def choose_yeast
    yeast = nil
    until yeast != nil do
      yeast = Yeast.find_by(id: rand(Yeast.count) + 1)
    end
    return yeast
  end

  def associate_yeast
    base_malt_name = pull_malt_name(@malts[:base].to_a[0])
    malt_associations = { "2-row" => "ale", "pilsen" => "lager", "white wheat" => "wheat", "maris otter" => "ale" }
    if malt_associations[base_malt_name] != nil
      yeast = Yeast.find_by(family: "#{malt_associations[base_malt_name]}")
      return yeast
    else
      choose_yeast
    end
  end

  def assign_malts
    choose_malt(true)
    num_specialty_malts.times { choose_malt(false) }
  end

  def malts_to_array
    malt_ary = []
    unless @malts[:specialty] == {}
      @malts[:specialty].each do |malt_obj, amt|
        malt_ary << [malt_obj, amt]
      end
    end
    malt_ary.unshift(@malts[:base].to_a[0])
  end

  def pull_malt_object(malt_ary)
    malt_ary[0]
  end

  def pull_malt_name(malt_ary)
    malt_ary[0].name
  end

  def pull_malt_amt(malt_ary)
    malt_ary[1]
  end

  def assign_hops
    @hops = { :bittering => choose_hop(true), :aroma => choose_aroma_hops }
    # probably want to refactor to mirror new malt structure (initialize @hops, assign to hash)
    # yes, do that
  end

  def hops_to_array
    hop_ary = []
    unless @hops[:aroma] == nil
      @hops[:aroma].each do |aroma_hash|
        hop_ary << aroma_hash.to_a
      end
      hop_ary = hop_ary.flatten(1)
    end
    hop_ary.unshift(@hops[:bittering].to_a[0])
  end

  def pull_hop_object(hop_ary)
    hop_ary[0]
  end

  def pull_hop_name(hop_ary)
    hop_ary[0].name
  end

  def pull_hop_amt(hop_ary)
    hop_ary[1][0]
  end

  def pull_hop_time(hop_ary)
    hop_ary[1][1]
  end

  def assign_yeast
    if rand(3) == 0
      @yeast = associate_yeast
    else
      @yeast = choose_yeast
    end
  end

  def num_aroma_hops
    rand(5)
    # needs probability weighting table
  end

  def choose_aroma_hops
    late_additions = num_aroma_hops
    if late_additions == 0
      return nil
    else
      aroma_hops = []
      late_additions.times do
        aroma_hops << choose_hop(false)
      end
    end
    return aroma_hops
  end

  def calc_abv
    # (og - fg) * weight of ethanol / fg * 100 = ABW
    # ABW / 0.79 = ABV
    @og = combine_og + 1.0
    fg = calc_fg(@og)
    @abv = ((@og - fg) * 1.05 / fg * 100 / 0.79).round(1)
  end

  def calc_og(malt_ary)
    return 0 if malt_ary == nil
    malt = pull_malt_object(malt_ary)
    weight = pull_malt_amt(malt_ary)
    # weight = malt_and_weight[malt]
    ((weight * pg_to_ep(malt.potential) * malt.malt_yield / 5.0) / 1000.0)
  end

  def calc_fg(og)
    1.0 + (pg_to_ep(og) * ((1.0 - (@yeast.attenuation/100.0)) / 1000.0))
  end

  def combine_og
    combined = 0.0
    malts_to_array.each do | malt_ary |
      combined += calc_og(malt_ary)
    end
    return combined
  end

  def pg_to_ep(potential)
    (potential - 1.0) * 1000
  end

  def calc_ibu
    combined = 0.0
    hops_to_array.each do |hop_ary|
      combined += calc_indiv_ibu(hop_ary)
    end
    @ibu = combined.round(1)
  end

  def calc_indiv_ibu(hop_ary)
    hop = pull_hop_object(hop_ary)
    weight = pull_hop_amt(hop_ary)
    time = pull_hop_time(hop_ary)
    rager_ibu = ( weight * (calc_hop_util(time)) * (hop.alpha / 100) * 7462 ) / ( 5 * ( 1 + calc_hop_ga ) )
    rager_to_tinseth_q_and_d(time, rager_ibu)
    # remove last line to reset to Rager
  end

  def rager_to_tinseth_q_and_d(time, rager_ibu)
    # need to match BJCP IBU style guidelines
    faux_tinseth = 0
    if time > 30
      faux_tinseth = rager_ibu * 0.78
    else
      faux_tinseth = rager_ibu * 1.16
    end
    return faux_tinseth
  end

  def calc_hop_util(minutes)
    # rager hop utilization
    (18.11 + (13.86 * Math.tanh((minutes - 31.32)/18.27))) / 100
  end

  def calc_hop_ga
    if @og > (1.058)
      (@og - 1.058) / 0.2
      # rager gravity adjustment
      # +0.008 added to extrapolate generic pre-boil from og
    else
      0
    end
  end

  def calc_mcu(malt_ary)
    # calculates malt color units
    malt = pull_malt_object(malt_ary)
    weight = pull_malt_amt(malt_ary)
    malt.srm * weight / 5.0
  end

  def combine_mcu
    combined = 0.0
    malts_to_array.each do | malt_ary |
      combined += calc_mcu(malt_ary)
    end
    return combined
  end

  def calc_srm
    @srm = ((combine_mcu ** 0.69) * 1.49).round(1)
    # Morey's logarithmic srm conversion
  end

  def display_hops
    display_string = ""
    hops_to_array.each do |hop_ary|
      display_string += "#{pull_hop_amt(hop_ary)} oz #{pull_hop_name(hop_ary)} @ #{pull_hop_time(hop_ary)} min, "
    end
    return display_string
  end

  def display_malts
    display_string = ""
    malts_to_array.each do |malt_ary|
      display_string += "#{pull_malt_amt(malt_ary)} lb #{pull_malt_name(malt_ary)}, "
    end
    return display_string
  end

  def select_by_yeast
    style_list = []
    Style.find_each do |style|
      style_list << style if (style.yeast_family == "#{@yeast.family}")
    end
    return style_list
  end

  def select_by_malt(style_list)
    subset = []
    style_list.each do |style|
      if style.required_malts == nil
        subset << style
      elsif style.required_malts != nil
        subset << style if malts_to_array.flatten.include?( Malt.find_by_name( style.required_malts[0] ) )
      end
    end
    return subset
  end

  def select_by_aroma(style_list)
    subset = []
    aroma_present = false
    aroma_present = true if @hops[:aroma] != nil
    if aroma_present
      style_list.each { |style| subset << style if style.aroma_required? }
    else
      subset = style_list
    end
    return subset
  end

  def select_by_abv(style_list)
    subset = []
    style_list.each do |style|
      subset << style if ((style.abv_lower)..(style.abv_upper)).cover?(@abv)
    end
    return subset
  end

    def select_by_ibu(style_list)
    subset = []
    style_list.each do |style|
      subset << style if ((style.ibu_lower)..(style.ibu_upper)).cover?(@ibu)
    end
    return subset
  end

  def select_by_srm(style_list)
    subset = []
    style_list.each do |style|
      subset << style if ((style.srm_lower)..(style.srm_upper)).cover?(@srm)
    end
    return subset
  end


  def filter_possible_styles
    style_list = select_by_aroma(select_by_malt(select_by_yeast))
    select_by_abv(style_list) & select_by_ibu(style_list) & select_by_srm(style_list)
  end

  def assign_style
    list = filter_possible_styles
    if list.length == 1
      @style = list[0]
    else
      # needs case handling for two possible style assignments
      @style = list[0]
    end
  end


private

  def malt_amount(malt)
    if malt.base_malt?
      rand(10) + 5.0
    else
      (rand(8) + 1) / 4.0
    end
  end

  def hop_amount(hop)
    (rand(6) + 1) / 2.0
  end

  def hop_time(hop_type)
    if hop_type
      if rand(3) == 0
        60
        # force to 60 1/3 of attempts
      else
        round_to_fives(rand(25) + 41)
        # pick a number between 60 and 40 rounded to 5
        # adjusted for truncation rounding
      end
    else
      # pick a number between 30 and 0 rounded to 5
      round_to_fives(rand(35))
    end
  end

  def round_to_fives(number)
    (number / 5).round * 5
  end
end