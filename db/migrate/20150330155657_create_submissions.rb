class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.string :regestration
      t.string :date

      t.timestamps null: false
    end
  end
end
