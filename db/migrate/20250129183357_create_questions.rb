class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.text :content
      t.text :answer_a
      t.text :answer_b
      t.text :answer_c
      t.text :answer_d
      t.text :answer_e
      t.string :correct_answer
      t.string :category
      t.string :subject
      t.integer :year
      t.text :explanation
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
