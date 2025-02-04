class AddEssayScoresToExams < ActiveRecord::Migration[7.0]
  def change
    add_column :exams, :comp1_score, :integer
    add_column :exams, :comp2_score, :integer
    add_column :exams, :comp3_score, :integer
    add_column :exams, :comp4_score, :integer
    add_column :exams, :comp5_score, :integer
    add_column :exams, :comp1_feedback, :text
    add_column :exams, :comp2_feedback, :text
    add_column :exams, :comp3_feedback, :text
    add_column :exams, :comp4_feedback, :text
    add_column :exams, :comp5_feedback, :text
    add_column :exams, :essay_total_score, :integer
    add_column :exams, :essay_general_feedback, :text
  end
end
