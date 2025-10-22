class AddJustificationFieldsToExams < ActiveRecord::Migration[7.1]
  def change
    add_column :exams, :comp1_justification, :text
    add_column :exams, :comp2_justification, :text
    add_column :exams, :comp3_justification, :text
    add_column :exams, :comp4_justification, :text
    add_column :exams, :comp5_justification, :text
  end
end
