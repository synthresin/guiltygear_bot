class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.string :code

      t.timestamps
    end

    add_index :rooms, :code
  end
end