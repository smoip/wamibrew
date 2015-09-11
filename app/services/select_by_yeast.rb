class SelectByYeast

  attr_accessor :yeast

  def initialize(yeast)
    @yeast = yeast
  end

  def select
    style_list = []
    Style.find_each do |style|
      style_list << style if (style.yeast_family == "#{@yeast.family}")
    end
    style_list
  end

end