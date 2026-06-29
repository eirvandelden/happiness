import assert from "node:assert/strict"
import fs from "node:fs"
import test from "node:test"
import vm from "node:vm"

const source = fs.readFileSync("app/javascript/controllers/notifications_controller.js", "utf8")

function buildController({ registration = {} } = {}) {
  let permissionRequested = false
  const context = {
    Controller: class {},
    Notification: {
      permission: "default",
      requestPermission: async () => {
        permissionRequested = true
        return "granted"
      },
    },
    navigator: {
      serviceWorker: {
        ready: Promise.resolve(registration),
      },
    },
    window: {
      Notification: true,
    },
  }
  const script = source
    .replace('import { Controller } from "@hotwired/stimulus"\n\n', "")
    .replace("export default class extends Controller", "class NotificationsController extends Controller")

  vm.createContext(context)
  const ControllerClass = vm.runInContext(`${script}\nNotificationsController`, context)

  const controller = new ControllerClass()
  controller.element = { hidden: false }

  return {
    controller,
    permissionRequested: () => permissionRequested,
  }
}

test("does not request permission when periodic sync is unavailable", async () => {
  const { controller, permissionRequested } = buildController()

  await controller.enable()

  assert.equal(permissionRequested(), false)
})
