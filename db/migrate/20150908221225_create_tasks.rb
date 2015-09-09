class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.datetime :due
      t.boolean :completed, default: false
      t.boolean :archived, default: false
      t.datetime :schedule
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
