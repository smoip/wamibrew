class AddIngredient

  attr_accessor :name, :malts_ary, :style

  def initialize(name, malts_ary, style)
    @name = name
    @malts_ary = malts_ary
    @style = style
  end

  def add_ingredient
    descriptor = nil
    adjective = choose_ingredient_adjective
    unless adjective == nil
      if ([ adjective ] & get_required_malts) == []
        # no overlap between usuable malt names and adjective
        unless @name.include?(NameHelpers.capitalize_titles(adjective))
          # no redundant adjectives
          descriptor = NameHelpers.capitalize_titles(oatmeal_check(adjective)) unless rand(3) == 0
        end
      end
    end
    descriptor
  end

  def choose_ingredient_adjective
    adjectives = [ 'wheat', 'rye', 'honey', 'rice', 'oats', 'corn', 'smoked' ]
    # add more desired adjectives here
    malt_names = @malts_ary.collect {|malt| MaltHelpers.pull_malt_name(malt).split(' ')}
    adjective = (malt_names.flatten & adjectives).shuffle.first
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

end