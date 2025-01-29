
class CreateExams < ActiveRecord::Migration[7.0]
  def change
    create_table :exams do |t|
      t.string :category
      t.integer :status, default: 0
      t.integer :score
      t.datetime :started_at
      t.datetime :finished_at
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end