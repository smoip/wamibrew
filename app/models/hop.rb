class Hop < ActiveRecord::Base
  validates( :name, :uniqueness => { :case_senstive => false } )
  validates( :alpha, :numericality => { :greater_than => 0.0, :less_than => 25.0 } )
end
