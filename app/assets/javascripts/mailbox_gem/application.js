import { Application } from "@hotwired/stimulus"
import AutoRefreshController from "mailbox_gem/controllers/auto_refresh_controller"

const application = Application.start()
application.register("auto-refresh", AutoRefreshController)
