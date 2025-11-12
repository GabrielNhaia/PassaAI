namespace :questions do
  desc "Remove todas as questões duplicadas e faz seed limpo"
  task reset: :environment do
    puts "Removendo todas as questões e registros relacionados..."

    puts "Removendo exam_questions relacionados..."
    ExamQuestion.destroy_all

    puts "Removendo todas as questões..."
    Question.destroy_all

    puts "Resetando contador de IDs..."
    ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='questions'")
    ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='exam_questions'")

    puts "Carregando seeds de questões..."
    load Rails.root.join('db', 'seeds.rb')

    total = Question.count
    puts "✓ Concluído! Total de questões no banco: #{total}"

    puts "\nQuestões por categoria:"
    Question.group(:category).count.each do |category, count|
      puts "  #{category}: #{count} questões"
    end

    duplicates = Question.group(:content).having('COUNT(*) > 1').count
    if duplicates.any?
      puts "\n⚠ AVISO: Encontradas #{duplicates.count} questões duplicadas!"
      puts "Execute novamente se necessário."
    else
      puts "\n✓ Nenhuma questão duplicada encontrada!"
    end
  end

  desc "Apenas remove questões duplicadas mantendo a primeira ocorrência"
  task remove_duplicates: :environment do
    puts "Procurando questões duplicadas..."

    duplicates_removed = 0
    exam_questions_updated = 0

    Question.select(:content).group(:content).having('COUNT(*) > 1').pluck(:content).each do |content|
      questions = Question.where(content: content).order(:id)
      first_question = questions.first

      questions.where.not(id: first_question.id).each do |dup|
        ExamQuestion.where(question_id: dup.id).update_all(question_id: first_question.id)
        exam_questions_updated += ExamQuestion.where(question_id: dup.id).count

        dup.destroy
        duplicates_removed += 1
      end
    end

    if duplicates_removed > 0
      puts "✓ Removidas #{duplicates_removed} questões duplicadas!"
      puts "✓ Atualizadas #{exam_questions_updated} referências em exam_questions!"
    else
      puts "✓ Nenhuma questão duplicada encontrada!"
    end

    puts "Total de questões no banco: #{Question.count}"
  end
end

namespace :exams do
  desc "Recalcula e atualiza os scores de todos os exames completados"
  task update_scores: :environment do
    puts "Atualizando scores dos exames..."

    updated_count = 0

    Exam.where(status: :completed).where.not(category: 'redacao').find_each do |exam|
      total_questions = exam.exam_questions.count
      correct_answers = exam.exam_questions.where(correct: true).count

      if total_questions > 0
        score = (correct_answers.to_f / total_questions * 100).round(2)
        exam.update_column(:score, score)
        updated_count += 1
        puts "Exam ##{exam.id}: #{correct_answers}/#{total_questions} = #{score}%"
      end
    end

    puts "✓ Atualizados #{updated_count} exames!"
  end
end
