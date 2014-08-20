class AddFamilyToYeastsTable < ActiveRecord::Migration
  def change
    add_column :yeasts, :family, :string, default: "ale"
  end
end
