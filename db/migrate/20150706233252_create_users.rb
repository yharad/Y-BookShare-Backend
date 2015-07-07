class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, :null => false 
      t.string :firstname, :null => false 
      t.string :lastname, :null => false 
      t.string :school
      t.integer :lend_num
      t.integer :borrow_num
      t.string :invitation_code, :null => false 

      t.timestamps null: false
    end
  end
end