class ChangeRegesteredColumnName < ActiveRecord::Migration
  def change
  	  rename_column :submissions, :date, :registration_date
  end
end
