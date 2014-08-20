class CreateYeasts < ActiveRecord::Migration
  def change
    create_table :yeasts do |t|
      t.string :name
      t.integer :attenuation

      t.timestamps
    end
  end
end
