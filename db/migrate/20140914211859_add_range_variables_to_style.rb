class AddRangeVariablesToStyle < ActiveRecord::Migration
  def change
    add_column :styles, :abv_upper, :float
    add_column :styles, :abv_lower, :float
    add_column :styles, :ibu_upper, :float
    add_column :styles, :ibu_lower, :float
    add_column :styles, :srm_upper, :float
    add_column :styles, :srm_lower, :float
  end
end
