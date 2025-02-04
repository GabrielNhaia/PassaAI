
class UpdateExamCategories < ActiveRecord::Migration[7.0]
  def change
    change_column :exams, :category, :integer, using: 'category::integer'
  end
end