class AddAdjective

  attr_accessor :style

  def initialize(style)
    @style = style
  end

  def add_adjective(name, adjective)
    if @style == nil
      return "#{adjective} #{name}"
    else
      if name.split(' ') == [ name ]
        index = 0
      elsif name == 'Pale Ale'
        index = 0
      elsif name == 'Red Ale'
        index = 0
      elsif name == 'Wheat Wine'
        index = 0
      else
        index = 1
      end
    name.split(' ').insert(index, adjective).join(' ')
    end
  end
end