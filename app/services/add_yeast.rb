class AddYeast

  attr_accessor :style, :name, :yeast

  def initialize(style, name, yeast)
    @style = style
    @name = name
    @yeast = yeast
  end

  def add_yeast
    yst = nil
    if @style == nil
      if (rand(4) == 1) & (@name.include?("Beer"))
        unless @yeast.family == 'wheat'
          yst = ((@name.split(' ') - ["Beer"]) + [ NameHelpers.capitalize_titles(@yeast.family) ] ).join(' ')
        end
      end
    end
    yst
  end
end