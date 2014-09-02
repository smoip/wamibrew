class Yeast < ActiveRecord::Base
  validates( :name, :uniqueness => { :case_sensitive => false } )
  validates( :attenuation, :numericality => { :greater_than => 50, :less_than => 100 } )
end
