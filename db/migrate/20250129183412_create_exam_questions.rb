class CreateExamQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :exam_questions do |t|
      t.references :exam, foreign_key: true
      t.references :question, foreign_key: true
      t.string :selected_answer
      t.boolean :correct

      t.timestamps
    end
  end
end
