class CreateRuns < ActiveRecord::Migration[7.1]
  def change
    create_table :runs do |t|
      t.integer :runNumber
      t.time :duration
      t.decimal :distance, precision: 8, scale: 2
      t.integer :calories
      t.time :averagePace
      t.integer :averageHR

      t.timestamps
    end
  end
end
