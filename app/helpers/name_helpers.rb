module NameHelpers

  def self.capitalize_titles(title)
    (title.split(" ").collect { |word| word.capitalize }).join(" ")
  end

  def self.check_smash_name(name)
    name.include?("SMASH") ? true : false
  end

end