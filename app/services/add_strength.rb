class AddStrength

  attr_accessor :style, :name, :abv

  STRENGTH_HASH = { :weak => [ "mild", "low gravity" ], :session => [ "sessionable", "quaffable" ], :average => [""], :strong => [ "strong" ], :very_strong => [ "high gravity", "imperial" ]  }

  def initialize(style, name, abv)
    @style = style
    @name = name
    @abv = abv
  end

  def add_strength
    str = nil
    if @style == nil
      if rand(4) == 1
        unless NameHelpers.check_smash_name(@name)
          str = choose_strength_adjective(strength_lookup)
        end
      end
    end
    str
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
    NameHelpers.capitalize_titles(STRENGTH_HASH[strength].shuffle.first)
  end
end