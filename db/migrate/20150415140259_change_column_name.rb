class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :submissions, :registration, :business_name
  end
end
