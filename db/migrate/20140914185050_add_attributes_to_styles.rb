class AddAttributesToStyles < ActiveRecord::Migration
  change_table :styles do |t|
    t.hstore :calc_attributes
  end
end
