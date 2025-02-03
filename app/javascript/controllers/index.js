// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import Swal from 'sweetalert2'

eagerLoadControllersFrom("controllers", application)
