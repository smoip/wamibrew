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
    self.calc_gravities
    self.calc_color
    self.calc_bitterness
    self.ibu_checks
    self.assign_style
    self.generate_name
  end

  def generate_name
    @name = @style.name unless @style.nil?
    check_smash
    add_yeast_family
    add_ingredient_to_name
    add_color_to_name
    nationality_check
    add_strength_to_name
    add_article
  end

  def check_smash
    smash = CheckSmash.new(@style, hop_names_to_array, @malts, malts_to_array, hops_to_array)
    smash_name = smash.check
    @name = smash_name unless smash_name == nil
  end

  def add_ingredient_to_name
    ingredient = AddIngredient.new(@name, malts_to_array, @style)
    add_adjective(@name, ingredient.add_ingredient)
  end

  def add_yeast_family
    yeast = AddYeast.new(@style, @name, @yeast)
    with_yeast = yeast.add_yeast
    @name = with_yeast if with_yeast != nil
  end

  def nationality_check
    nationality = CheckNationality.new(@name)
    @name = nationality.check
  end

  def add_color_to_name
    color = AddColor.new(@style, @name, @srm)
    add_adjective(@name, color.add_color)
  end

  def add_strength_to_name
    strength = AddStrength.new(@style, @name, @abv)
    add_adjective(@name, strength.add_strength)
  end

  def add_article
    @name = %w(a e i o u).include?(@name.strip[0].downcase) ? "An #{@name}" : "A #{@name}"
  end

  def add_adjective(name, adjective)
    adjective_adder = AddAdjective.new(@style)
    @name = adjective_adder.add_adjective(name, adjective)
  end

  def ibu_checks
    re_hop = ReAssignHops.new(self)
    re_hop.extreme_ibu_check
    re_hop.ibu_gravity_check
  end

  def assign_malts
    maltster = AssignMalts.new(self)
    store_malt(maltster.choose_malt(true))
    maltster.num_specialty_malts.times { store_malt(maltster.choose_malt(false)) }
    @malts[:specialty]= maltster.order_specialty_malts(@malts)
  end

  def store_malt(arg)
    type_key = arg[0]
    malt = arg[1]
    amt = arg[2]
    if @malts[type_key][malt].nil?
      @malts[type_key][malt]= amt
    else
      @malts[type_key][malt]+= amt
    end
  end

  def malts_to_array
    malt_ary = MaltsArrays.new(@malts)
    malt_ary.malts_to_array
  end

  def assign_hops
    hopster = AssignHops.new(self)
    store_hop(hopster.choose_hop(true))
    hopster.num_aroma_hops.times { store_hop(hopster.choose_hop(false)) }
  end

  def store_hop(arg)
    type_key = arg[0]
    hop = arg[1]
    amt = arg[2]
    time = arg[3]
    if type_key == :bittering
      @hops[type_key][hop]= [amt, time]
    else
      @hops[type_key] << { hop => [amt, time] }
    end
  end

  def hops_to_array
    hop_ary = HopsArrays.new(@hops)
    hop_ary.hops_to_array
  end

  def hop_names_to_array
    hop_ary = HopsArrays.new(@hops)
    hop_ary.hop_names_to_array
  end

  def assign_yeast
    pick_yeast = AssignYeast.new(@malts)
    if rand(3) == 0
      @yeast = pick_yeast.associate_yeast
    else
      @yeast = pick_yeast.choose_yeast
    end
  end

  def calc_gravities
    gravity = CalculateGravity.new(@yeast, malts_to_array)
    gravity_ary = gravity.calc_abv
    @og = gravity_ary[0]
    @abv = gravity_ary[1]
  end

  def calc_bitterness
    bitterness = CalculateBitterness.new(hops_to_array, @og)
    @ibu = bitterness.calc_ibu
  end

  def calc_color
    color = CalculateColor.new(malts_to_array)
    @srm = color.calc_srm
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
      display_array << "#{MaltHelpers.pull_malt_amt(malt_ary)} lb #{MaltHelpers.pull_malt_name(malt_ary)}"
    end
    display_array.join(", ")
  end

  def select_by_yeast
    by_yeast = SelectByYeast.new(@yeast)
    by_yeast.select
  end

  def select_by_malt(style_list)
    by_malts = SelectByMalts.new(malts_to_array)
    by_malts.select(style_list)
  end

  # def select_by_malt(style_list)
  #   subset = []
  #   style_list.each do |style|
  #     if style.required_malts.nil?
  #       subset << style
  #     elsif style.required_malts != nil
  #       subset << style if malts_to_array.flatten.include?( Malt.find_by_name( style.required_malts[0] ) )
  #     end
  #   end
  #   return subset
  # end

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

end