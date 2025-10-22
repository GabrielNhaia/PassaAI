require 'minitest/autorun'
require_relative '../../app/services/essay_correction_service'

class EssayCorrectionServiceTest < Minitest::Test
  def setup
    @theme = "A importância da educação digital no Brasil contemporâneo"
    @sample_essay = <<~ESSAY
      No mundo atual, a tecnologia tem se tornado cada vez mais presente no cotidiano das pessoas. A educação digital é fundamental para preparar os jovens para o mercado de trabalho. Muitas escolas ainda não tem acesso adequado à internet e computadores.

      Além disso, os professores precisam de capacitação para usar as ferramentas digitais em sala de aula. E também é importante que os alunos aprendam a usar a tecnologia de forma responsável.

      Por isso, o governo deve investir mais em infraestrutura tecnológica nas escolas. E criar programas de formação para os educadores. Dessa forma, será possível melhorar a qualidade da educação no país.
    ESSAY
  end

  def test_should_provide_specific_feedback_for_grammatical_errors
    service = EssayCorrectionService.new(@sample_essay, @theme)
    
    # Mock da resposta da OpenAI para testar o enhancement
    mock_response = {
      "comp1" => { 
        "score" => 120, 
        "feedback" => "há alguns deslizes que comprometem a fluidez do texto." 
      },
      "comp4" => { 
        "score" => 100, 
        "feedback" => "apresenta dificuldades na articulação das ideias." 
      }
    }

    # Simular o método de enhancement
    enhanced = service.send(:validate_and_enhance_feedback, mock_response)
    
    # Verificar se o feedback foi melhorado
    assert_includes enhanced["comp1"]["feedback"], "concordância verbal"
    assert_includes enhanced["comp1"]["feedback"], "acentuação"
    assert_includes enhanced["comp4"]["feedback"], "conectivos como"
    assert_includes enhanced["comp4"]["feedback"], "ademais"
  end

  test "should not modify already detailed feedback" do
    service = EssayCorrectionService.new(@sample_essay, @theme)
    
    detailed_feedback = "Na linha 3, há erro de concordância em 'não tem' que deveria ser 'não têm'. " \
                       "Também observe a falta de vírgula antes de 'que' na oração subordinada."
    
    mock_response = {
      "comp1" => { 
        "score" => 160, 
        "feedback" => detailed_feedback
      }
    }

    enhanced = service.send(:validate_and_enhance_feedback, mock_response)
    
    # Feedback detalhado não deve ser modificado
    assert_equal detailed_feedback, enhanced["comp1"]["feedback"]
  end
end