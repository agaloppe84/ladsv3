import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

const application = Application.start()
application.debug = false
window.PublicV2Stimulus = application

eagerLoadControllersFrom("public_v2/controllers", application)
