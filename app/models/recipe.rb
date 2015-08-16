class Recipe < ActiveRecord::Base

  attr_accessor :name, :style, :abv, :ibu, :srm, :malts, :hops, :yeast, :og, :stack_token

  def initialize
    @malts = { :base => {}, :specialty => {} }
    @hops = { :bittering => {}, :aroma => [] }
    @name = "Beer"
    @stack_token = 0
    super
  end

  def choose_attributes
    self.assign_malts
    self.assign_hops
    self.assign_yeast
    self.calc_abv
    self.calc_srm
    self.calc_ibu
    self.ibu_gravity_check
    self.extreme_ibu_check
    self.assign_style
    self.generate_name
  end

  def generate_name
    @name = @style.name unless @style.nil?
    check_smash
    add_yeast_family
    add_ingredient_to_name
    add_color_to_name
    add_strength_to_name
    add_article
  end

  def check_smash
    if @style == nil
      if single_malt? && single_hop?
        generate_smash_name
      end
    end
  end

  def single_hop?
    ( hop_names_to_array.uniq == [ hop_names_to_array[0] ] ) ? true : false
  end

  def single_malt?
    ( @malts[:specialty] == {} ) ? true : false
  end

  def generate_smash_name
    malt = capitalize_titles(pull_malt_name(malts_to_array[0]))
    hop = capitalize_titles(pull_hop_name(hops_to_array[0]))
    @name = "#{malt} #{hop} SMASH"
  end

  def capitalize_titles(title)
    (title.split(" ").collect { |word| word.capitalize }).join(" ")
  end

  def add_ingredient_to_name
    adjective = choose_ingredient_adjective
    unless adjective == nil
      if ([ adjective ] & get_required_malts) == []
        # no overlap between usuable malt names and adjective
        unless @name.include?(capitalize_titles(adjective))
          # no redundant adjectives
          add_adjective(@name, capitalize_titles(oatmeal_check(adjective)))
        end
      end
    end
  end

  def choose_ingredient_adjective
    adjectives = [ 'wheat', 'rye', 'honey', 'rice', 'oats', 'corn' ]
    # add more desired adjectives here
    malt_names = malts_to_array.collect {|malt| pull_malt_name(malt).split(' ')}
    adjective = (malt_names.flatten & adjectives).shuffle.first
    adjective
  end

  def oatmeal_check(adjective)
    if adjective == 'oats'
      adjective = 'oatmeal'
    end
    adjective
  end

  def get_required_malts
    required_malts = []
    unless @style == nil
      if @style.required_malts != nil
        required_malts = @style.required_malts.collect {|name| name.split(' ')}
      end
    end
    required_malts.flatten
  end

  def add_yeast_family
    if @style == nil
      if (rand(4) == 1) & (@name.include?("Beer"))
        unless @yeast.family == 'wheat'
          @name = ((@name.split(' ') - ["Beer"]) + [ capitalize_titles(@yeast.family) ] ).join(' ')
        end
      end
    end
  end

  def add_color_to_name
    if @style == nil
      if rand(4) == 1
        unless check_smash_name
          add_adjective(@name, choose_color_adjective(color_lookup))
        end
      end
    end
  end

  def check_smash_name
    @name.include?("SMASH") ? true : false
  end

  def color_lookup
    color = @srm.round(0).to_i
    color_adj = :none
    case color
    when 0..3 then color_adj = :yellow
    when 4..7 then color_adj = :gold
    when 8..11 then color_adj = :amber
    when 12..14 then color_adj = :red
    when 15..20 then color_adj = :brown
    when 21..25 then color_adj = :dark_brown
    when 26..35 then color_adj = :black
    else color_adj = :dark_black
    end
    color_adj
  end

  def choose_color_adjective(color)
    color_hash = { :yellow => [ "straw", "blonde", "light gold" ], :gold => [ "gold", "golden", "blonde" ], :amber => [ "amber", "copper" ], :red => [ "red", "amber" ], :brown => [ "brown", "chestnut" ], :dark_brown => [ "dark brown", "brown" ], :black => [ "black", "dark brown" ], :dark_black => [ "black", "jet black" ]  }
    capitalize_titles(color_hash[color].shuffle.first)
  end

  def add_strength_to_name
    if @style == nil
      if rand(4) == 1
        unless check_smash_name
          add_adjective(@name, choose_strength_adjective(strength_lookup))
        end
      end
    end
  end

  def strength_lookup
    strength = @abv.round(0).to_i
    strength_adj = :none
    case strength
    when 0..2 then strength_adj = :weak
    when 3..4 then strength_adj = :session
    when 5..7 then strength_adj = :average
    when 8..9 then strength_adj = :strong
    else strength_adj = :very_strong
    end
    strength_adj
  end

  def choose_strength_adjective(strength)
    strength_hash = { :weak => [ "mild", "low gravity" ], :session => [ "sessionable", "quaffable" ], :average => [""], :strong => [ "strong" ], :very_strong => [ "high gravity", "very strong" ]  }
    capitalize_titles(strength_hash[strength].shuffle.first)
  end

  def add_article
    @name = %w(a e i o u).include?(@name[0].downcase) ? "An #{@name}" : "A #{@name}"
  end

  def add_adjective(name, adjective)
    if @style == nil
      @name = "#{adjective} #{name}"
    else
      if name.split(' ') == [ name ]
        index = 0
      else
        index = 1
    end
    @name = name.split(' ').insert(index, adjective).join(' ')
    end
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

  def order_specialty_malts
    specialty_ary = ( @malts[:specialty].sort_by { |malt, amt| amt } ).reverse
    @malts[:specialty]= Hash[*specialty_ary.flatten]
  end

  def store_malt(type_key, malt)
    if @malts[type_key][malt].nil?
      @malts[type_key][malt]= malt_amount(malt)
    else
      @malts[type_key][malt]+= malt_amount(malt)
    end
  end

  def malt_type_to_key(malt_type)
    malt_type ? key = :base : key = :specialty
    key
  end

  def num_specialty_malts
    complexity = rand(5)
    [ [ 0, 1 ], [ 1, 2 ], [ 1, 2, 2, 3 ], [ 2, 3, 4 ], [ 3, 4, 5 ] ][ complexity ].shuffle.first
  end

  def choose_hop(hop_type)
    hop = similar_hop(hop_type)
    type_key = hop_type_to_key(hop_type)
    store_hop(type_key, hop, hop_type)
  end

  def store_hop(type_key, hop, hop_type)
    if hop_type
      @hops[type_key][hop]= [hop_amount, hop_time(hop_type)]
    else
      @hops[type_key] << { hop => [hop_amount, hop_time(hop_type)] }
    end
  end

  def similar_hop(hop_type)
    unless hop_type
      if rand(4) == 1
        unless (hop_names_to_array == [])
          hop = Hop.find_by_name(hop_names_to_array.last)
          unless hop.nil?
            return hop
          end
        end
      end
    end
    hop = Hop.find_by(id: rand(Hop.count) + 1)
    hop
  end

  def hop_type_to_key(hop_type)
    hop_type ? key = :bittering : key = :aroma
    key
  end

  def extreme_ibu_check
    if @ibu > 120
      re_assign_hops
    end
  end

  def ibu_gravity_check
    if ( ( @abv <= 4.5 ) && ( @ibu > 60 ) )
      re_assign_hops
    elsif ( ( @abv <= 6 ) && ( @ibu > 90 ) )
      re_assign_hops
    end
  end

  def re_assign_hops
    @stack_token += 1
    self.hops = { :bittering => {}, :aroma => [] }
    self.assign_hops
    self.calc_ibu
    unless @stack_token > 15
      self.ibu_gravity_check
      self.extreme_ibu_check
    end
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
    order_specialty_malts
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
    choose_hop(true)
    num_aroma_hops.times { choose_hop(false) }
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
    hop_ary = []
    unless @hops[:aroma].nil?
      @hops[:aroma].each do |aroma_hash|
        aroma_hash.each_key do |aroma|
          hop_ary << aroma.name
        end
      end
    end
    bitter = []
    @hops[:bittering].each_key do |bittering|
      bitter << bittering.name
    end
    hop_ary.unshift(bitter)
    hop_ary.flatten
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
    complexity = rand(6)
    [ [ 0, 1 ], [ 0, 1, 2 ], [ 1, 2, 2, 3 ], [ 2, 3, 3, 4 ], [ 3, 4, 5 ], [ 4, 5, 6 ] ][ complexity ].shuffle.first
  end

  def calc_abv
    # (og - fg) * weight of ethanol / fg * 100 = ABW
    # ABW / 0.79 = ABV
    @og = combine_og + 1.0
    fg = calc_fg(@og)
    @abv = ((@og - fg) * 1.05 / fg * 100 / 0.79).round(1)
  end

  def calc_og(malt_ary)
    return 0 if malt_ary.nil?
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
    display_array = []
    time_ordered_hops_hash(flat_hops_array).each do |time, ary|
      display_array << "#{ary[1]} oz #{ary[0].name} @ #{time} min"
    end
    display_array.join(", ")
  end

  def flat_hops_array
    hop_ary = self.hops_to_array.collect do |hop_addition|
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

  def display_malts
    display_array = []
    malts_to_array.each do |malt_ary|
      display_array << "#{pull_malt_amt(malt_ary)} lb #{pull_malt_name(malt_ary)}"
    end
    display_array.join(", ")
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
      if style.required_malts.nil?
        subset << style
      elsif style.required_malts != nil
        subset << style if malts_to_array.flatten.include?( Malt.find_by_name( style.required_malts[0] ) )
      end
    end
    return subset
  end

  def select_by_aroma(style_list)
    subset = style_list.dup
    unless aroma_present?
      style_list.each { |style| subset -= [style] if style.aroma_required? }
    end
    return subset
  end

  def aroma_present?
    aroma_present = false
    aroma_present = true if @hops[:aroma] != []
    aroma_present
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
    style_list = filter_possible_styles
    if style_list.length == 1
      @style = style_list[0]
    elsif style_list.length > 1
      @style = filter_style_by_ingredients(style_list)
    end
    # needs better case handling for no style match - approximate styles
  end

  def filter_style_by_ingredients(style_list)
    tally_table = tally_common_ingredients(style_list)
    malt_tally = tally_table[0]
    hop_tally = tally_table[1]
    tally = malt_tally.merge(hop_tally) { |style, m_count, h_count| m_count + h_count }
    tally = ( tally.sort_by { |style, count| -count } )
    tally = tally.first
    return tally[0]
  end

  def tally_common_ingredients(style_list)
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
      style.common_malts.each do |malt|
        if malts_to_array.flatten.include?(Malt.find_by_name(malt))
          tally[style]+= 1
        end
      end
    end
    return tally
  end

  def tally_common_hops(style)
    tally = { style => 0 }
    unless style.common_hops.nil?
      style.common_hops.each do |hop|
        if hops_to_array.flatten.include?(Hop.find_by_name(hop))
          tally[style]+= 1
        end
      end
    end
    return tally
  end


private

  def malt_amount(malt)
    if malt.base_malt?
      rand(10) + 5.0
    else
      (rand(8) + 1) / 4.0
    end
  end

  def hop_amount
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