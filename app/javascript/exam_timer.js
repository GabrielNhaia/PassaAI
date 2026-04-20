// Timer do Simulado
document.addEventListener('DOMContentLoaded', function() {
  const timerElement = document.getElementById('exam-timer');
  
  if (timerElement) {
    let seconds = 0;
    let minutes = 0;
    let hours = 0;
    
    // Função para formatar números com dois dígitos
    function pad(num) {
      return num.toString().padStart(2, '0');
    }
    
    // Função para atualizar o display do timer
    function updateTimer() {
      seconds++;
      
      if (seconds >= 60) {
        seconds = 0;
        minutes++;
      }
      
      if (minutes >= 60) {
        minutes = 0;
        hours++;
      }
      
      timerElement.textContent = `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
    }
    
    // Iniciar o timer
    const timerInterval = setInterval(updateTimer, 1000);
    
    // Parar o timer quando a página for descarregada
    window.addEventListener('beforeunload', function() {
      clearInterval(timerInterval);
    });
    
    // Salvar tempo no sessionStorage para persistir entre questões
    function saveTime() {
      sessionStorage.setItem('examTime', JSON.stringify({ hours, minutes, seconds }));
    }
    
    // Carregar tempo salvo (se existir)
    const savedTime = sessionStorage.getItem('examTime');
    if (savedTime) {
      const time = JSON.parse(savedTime);
      hours = time.hours || 0;
      minutes = time.minutes || 0;
      seconds = time.seconds || 0;
      timerElement.textContent = `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
    }
    
    // Salvar tempo a cada segundo
    setInterval(saveTime, 1000);
    
    // Limpar sessionStorage quando o simulado for concluído
    const submitButtons = document.querySelectorAll('input[type="submit"]');
    submitButtons.forEach(button => {
      button.addEventListener('click', function() {
        const questionsRemaining = document.querySelector('.timer')?.textContent.includes('de 45');
        if (!questionsRemaining) {
          sessionStorage.removeItem('examTime');
        }
      });
    });
  }
});
