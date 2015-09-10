class CheckNationality

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def check
    if @name.include?('German')
      @name = swap_yeast_adjective_order(@name, 'German')
    end
    if @name.include?('Belgian')
      @name = swap_yeast_adjective_order(@name, 'Belgian')
    end
    @name
  end

  def swap_yeast_adjective_order(name, adjective)
    ((name.split - [adjective]).unshift([adjective])).join(' ')
  end
end