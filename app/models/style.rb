class Style < ActiveRecord::Base
  validates( :name, { :uniqueness => { :case_sensitive => false } } )
end
