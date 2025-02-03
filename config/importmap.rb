# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "sweetalert2", to: "https://ga.jspm.io/npm:sweetalert2@11.7.32/dist/sweetalert2.all.js"
pin_all_from "app/javascript/controllers", under: "controllers"
