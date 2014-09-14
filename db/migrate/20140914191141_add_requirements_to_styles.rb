class AddRequirementsToStyles < ActiveRecord::Migration
  def change
    change_table :styles do |t|
      t.string :required_malts, array: true
      t.string :required_hops,  array: true
      t.string :common_malts,   array: true
      t.string :common_hops,    array: true
    end
  end
end
