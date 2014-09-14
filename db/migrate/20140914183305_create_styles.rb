class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.string :name
      t.string :yeast_family
      t.boolean :aroma_required?

      t.timestamps
    end
  end
end
