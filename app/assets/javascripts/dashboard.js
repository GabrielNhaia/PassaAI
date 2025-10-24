document.addEventListener('DOMContentLoaded', function() {
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

  const observeElements = () => {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate__animated', 'animate__fadeInUp');
          
          if (entry.target.querySelector('[data-counter]')) {
            setTimeout(animateCounters, 300);
          }
        }
      });
    }, { threshold: 0.1 });

    document.querySelectorAll('.card').forEach(card => {
      observer.observe(card);
    });
  };

  const initTooltips = () => {
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(tooltipTriggerEl => {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  };

  const autoRefresh = () => {
    setInterval(() => {
      if (document.visibilityState === 'visible') {
        fetch(window.location.href, {
          headers: {
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        .then(response => response.text())
        .then(html => {
          console.log('Dashboard data refreshed');
        });
      }
    }, 300000); // 5 minutos
  };

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

  const showAchievementNotification = (achievement) => {
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification('Nova Conquista Desbloqueada! 🏆', {
        body: achievement.title,
        icon: '/assets/trophy-icon.png'
      });
    }
  };

  const requestNotificationPermission = () => {
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission();
    }
  };

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

  observeElements();
  initTooltips();
  addCardEffects();
  requestNotificationPermission();
  animateProgressBars();
  
});

function showAchievementDetail(achievementId) {
  console.log('Showing achievement details for:', achievementId);
}

function shareAchievement(achievementTitle) {
  if (navigator.share) {
    navigator.share({
      title: 'PassaAI - Nova Conquista!',
      text: `Acabei de desbloquear: ${achievementTitle}`,
      url: window.location.origin
    });
  }
}