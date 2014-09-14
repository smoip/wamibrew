class AddIngredientsToStyles < ActiveRecord::Migration
  change_table :styles do |t|
    t.hstore :ingredients
  end
end
