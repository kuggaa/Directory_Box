class ChangeRegestrationToRegistration < ActiveRecord::Migration
  def change
  	  rename_column :submissions, :regestration, :registration 
  end
end
