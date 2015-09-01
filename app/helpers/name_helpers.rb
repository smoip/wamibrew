module NameHelpers

  def self.capitalize_titles(title)
    (title.split(" ").collect { |word| word.capitalize }).join(" ")
  end

end