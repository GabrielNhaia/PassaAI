// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@rails/ujs"
import "rails_admin"
import Swal from 'sweetalert2'

// Tornando o Swal disponível globalmente de forma explícita
window.Swal = Swal

// Helper para toast notifications
window.Toast = Swal.mixin({
  toast: true,
  position: 'top-end',
  showConfirmButton: false,
  timer: 3000,
  timerProgressBar: true
})
