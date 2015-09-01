class AddColor

  attr_accessor :recipe

  COLOR_HASH = { :yellow => [ "very pale", "blonde", "light" ], :gold => [ "gold", "golden", "blonde" ], :amber => [ "amber", "copper" ], :red => [ "red", "amber" ], :brown => [ "brown", "chestnut" ], :dark_brown => [ "dark brown", "brown" ], :black => [ "black", "dark brown", "dark" ], :dark_black => [ "very dark", "black", "jet black" ]  }

  def initialize(recipe)
    @recipe = recipe
  end

  def add_color
    if @recipe.style == nil
      if rand(4) == 1
        unless @recipe.check_smash_name
          @recipe.add_adjective(@recipe.name, choose_color_adjective(color_lookup))
        end
      end
    end
  end

  def color_lookup
    color = @recipe.srm.round(0).to_i
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
    NameHelpers.capitalize_titles(COLOR_HASH[color].shuffle.first)
  end

end