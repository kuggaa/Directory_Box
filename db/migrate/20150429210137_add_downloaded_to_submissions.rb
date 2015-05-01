class AddDownloadedToSubmissions < ActiveRecord::Migration
  
  def change
  	add_column :submissions, :client_id, :integer
   	remove_column :submissions, :business_name, :string
  	remove_column :submissions, :registration_date, :string
  	add_column :submissions, :registration_date, :datetime
  end

end
