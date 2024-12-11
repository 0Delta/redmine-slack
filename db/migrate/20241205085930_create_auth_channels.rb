class CreateAuthChannels < ActiveRecord::Migration[6.1]
  def change
    create_table :auth_channels do |t|
      t.string :name
      t.string :key
    end
  end
end
