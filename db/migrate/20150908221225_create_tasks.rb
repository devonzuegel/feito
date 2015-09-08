class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.datetime :due
      t.boolean :completed
      t.boolean :archived
      t.datetime :schedule
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
