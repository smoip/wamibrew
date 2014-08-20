class AddMaltTypeToMalt < ActiveRecord::Migration
  def change
    add_column :malts, :base_malt?, :boolean, default: "false"
  end
end
