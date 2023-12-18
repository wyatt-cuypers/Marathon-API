class ChangeDecimalTypeInDistance < ActiveRecord::Migration[7.1]
  def change
	change_column :runs, :distance, :decimal
  end
end
