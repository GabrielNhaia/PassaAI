// Dashboard JavaScript
document.addEventListener('DOMContentLoaded', function() {
  // Animação de contadores
  const animateCounters = () => {
    const counters = document.querySelectorAll('[data-counter]');
    
    counters.forEach(counter => {
      const target = parseInt(counter.dataset.counter);
      const duration = 1500; // 1.5 segundos
      const increment = target / (duration / 16); // 60 FPS
      let current = 0;
      
      const updateCounter = () => {
        if (current < target) {
          current += increment;
          counter.textContent = Math.floor(current);
          requestAnimationFrame(updateCounter);
        } else {
          counter.textContent = target;
        }
      };
      
      updateCounter();
    });
  };

  // Observer para detectar quando os elementos entram na tela
  const observeElements = () => {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate__animated', 'animate__fadeInUp');
          
          // Animar contadores quando visíveis
          if (entry.target.querySelector('[data-counter]')) {
            setTimeout(animateCounters, 300);
          }
        }
      });
    }, { threshold: 0.1 });

    // Observar cards de estatísticas
    document.querySelectorAll('.card').forEach(card => {
      observer.observe(card);
    });
  };

  // Tooltip para conquistas
  const initTooltips = () => {
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(tooltipTriggerEl => {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  };

  // Auto-refresh de dados (opcional)
  const autoRefresh = () => {
    // Atualizar dados a cada 5 minutos
    setInterval(() => {
      if (document.visibilityState === 'visible') {
        // Fazer uma requisição AJAX para atualizar dados
        fetch(window.location.href, {
          headers: {
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        .then(response => response.text())
        .then(html => {
          // Atualizar apenas seções específicas se necessário
          console.log('Dashboard data refreshed');
        });
      }
    }, 300000); // 5 minutos
  };

  // Efeitos de hover nos cards
  const addCardEffects = () => {
    document.querySelectorAll('.card').forEach(card => {
      card.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-5px)';
        this.style.transition = 'all 0.3s ease';
      });
      
      card.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0)';
      });
    });
  };

  // Notificações para conquistas
  const showAchievementNotification = (achievement) => {
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification('Nova Conquista Desbloqueada! 🏆', {
        body: achievement.title,
        icon: '/assets/trophy-icon.png'
      });
    }
  };

  // Solicitar permissão para notificações
  const requestNotificationPermission = () => {
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission();
    }
  };

  // Progresso visual das metas
  const animateProgressBars = () => {
    document.querySelectorAll('.progress-bar').forEach(bar => {
      const width = bar.style.width;
      bar.style.width = '0%';
      setTimeout(() => {
        bar.style.transition = 'width 1s ease-in-out';
        bar.style.width = width;
      }, 500);
    });
  };

  // Inicializar funcionalidades
  observeElements();
  initTooltips();
  addCardEffects();
  requestNotificationPermission();
  animateProgressBars();
  
  // Auto-refresh opcional (descomente se necessário)
  // autoRefresh();
});

// Função para mostrar detalhes de conquista
function showAchievementDetail(achievementId) {
  // Implementar modal ou tooltip com detalhes da conquista
  console.log('Showing achievement details for:', achievementId);
}

// Função para compartilhar conquista
function shareAchievement(achievementTitle) {
  if (navigator.share) {
    navigator.share({
      title: 'PassaAI - Nova Conquista!',
      text: `Acabei de desbloquear: ${achievementTitle}`,
      url: window.location.origin
    });
  }
}