class Malt < ActiveRecord::Base
  validates( :name,       { :uniqueness =>   { :case_sensitive => false } } )
  validates( :potential,  { :numericality => { :greater_than => 1.020, :less_than => 1.050 } } )
  validates( :malt_yield, { :numericality => { :greater_than => 0.0, :less_than_or_equal_to => 1.0 } } )
  validates( :srm, { :numericality => { :greater_than => 0.0, :less_than => 800.0 } } )
end
