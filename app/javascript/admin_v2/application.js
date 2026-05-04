import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

const installAdminV2Confirm = () => {
  if (!window.Turbo?.setConfirmMethod || window.Turbo.adminV2ConfirmInstalled) return

  window.Turbo.setConfirmMethod((message, formElement, submitter) => {
    const source = submitter?.dataset.adminV2Confirm ? submitter : formElement
    const customEnabled = source?.dataset.adminV2Confirm === "true"
    if (!customEnabled) return Promise.resolve(window.confirm(message))

    const dialog = window.AdminV2ConfirmDialog
    if (!dialog) return Promise.resolve(window.confirm(message))

    return dialog.request({
      title: source.dataset.adminV2ConfirmTitle,
      message,
      body: source.dataset.adminV2ConfirmBody,
      action: source.dataset.adminV2ConfirmAction
    })
  })

  window.Turbo.adminV2ConfirmInstalled = true
}

const application = Application.start()
application.debug = false
window.AdminV2Stimulus = application

eagerLoadControllersFrom("admin_v2/controllers", application)
installAdminV2Confirm()
document.addEventListener("turbo:load", installAdminV2Confirm)
