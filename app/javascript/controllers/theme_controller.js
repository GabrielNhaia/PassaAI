import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["switch"]

  connect() {
    if (this.hasSwitchTarget) {
      this.updateTheme(this.switchTarget.checked)
    }
  }

  toggle(event) {
    this.updateTheme(event.target.checked)
  }

  updateTheme(isDark) {
    const theme = isDark ? 'dark' : 'light'
    document.documentElement.setAttribute('data-theme', theme)
    
    // Salvar preferência no localStorage
    localStorage.setItem('theme', theme)
    
    // Atualizar cores do sistema (opcional)
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      document.querySelector('meta[name="theme-color"]')?.setAttribute('content', isDark ? '#212529' : '#ffffff')
    }
  }
}
