class CreateMalts < ActiveRecord::Migration
  def change
    create_table :malts do |t|
      t.string :name
      t.float :potential
      t.float :yield
      t.float :srm

      t.timestamps
    end
  end
end
