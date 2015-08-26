class AddStrength

  attr_accessor :recipe

  STRENGTH_HASH = { :weak => [ "mild", "low gravity" ], :session => [ "sessionable", "quaffable" ], :average => [""], :strong => [ "strong" ], :very_strong => [ "high gravity", "imperial" ]  }

  def initialize(recipe)
    @recipe = recipe
  end

  def add_strength
    if @recipe.style == nil
      if rand(4) == 1
        unless @recipe.check_smash_name
          @recipe.add_adjective(@recipe.name, choose_strength_adjective(strength_lookup))
        end
      end
    end
  end

  def strength_lookup
    strength = @recipe.abv.round(0).to_i
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
    @recipe.capitalize_titles(STRENGTH_HASH[strength].shuffle.first)
  end
end