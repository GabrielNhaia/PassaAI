class AddWritingFieldsToExams < ActiveRecord::Migration[7.0]
  def change
    add_column :exams, :selected_theme, :string
    add_column :exams, :essay_text, :text
  end
end
