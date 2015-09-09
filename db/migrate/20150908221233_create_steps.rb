class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.string :title
      t.datetime :due
      t.boolean :completed, default: false
      t.references :task, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
