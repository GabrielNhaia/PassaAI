import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
  connect() {
    const message = this.element.dataset.alertsMessageValue
    const type = this.element.dataset.alertsTypeValue

    if (message) {
      Swal.fire({
        toast: true,
        position: 'top-end',
        icon: type,
        title: message,
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true
      })
    }
  }

  // Método para confirmação de exclusão
  async confirm(event) {
    event.preventDefault()
    
    const result = await Swal.fire({
      title: 'Você tem certeza?',
      text: "Esta ação não poderá ser revertida!",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      confirmButtonText: 'Sim, excluir!',
      cancelButtonText: 'Cancelar'
    })

    if (result.isConfirmed) {
      event.target.submit()
    }
  }

  // Adicione este novo método
  test() {
    Swal.fire({
      title: 'Teste',
      text: 'Mensagem de teste',
      icon: 'success'
    })
  }
}
