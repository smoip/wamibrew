class Recipe < ActiveRecord::Base

  def create
  end

  def name_gen(style)
    recipe_name = "#{RandomWordGenerator.word} #{RandomWordGenerator.word} #{style}"
  end
end