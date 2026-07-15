import assert from "node:assert/strict"
import fs from "node:fs"
import test from "node:test"
import vm from "node:vm"

const source = fs.readFileSync("app/javascript/controllers/notifications_controller.js", "utf8")

function buildController({ registration = {}, permission = "default", permissionResult = "granted" } = {}) {
  let permissionRequested = false
  const context = {
    Controller: class {},
    Notification: {
      permission,
      requestPermission: async () => {
        permissionRequested = true
        return permissionResult
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
  controller.buttonTarget = { hidden: false }
  controller.statusTarget = { hidden: true, textContent: "" }
  controller.unsupportedValue = "unsupported"
  controller.blockedValue = "blocked"
  controller.enabledValue = "enabled"
  controller.failedValue = "failed"

  return {
    controller,
    permissionRequested: () => permissionRequested,
  }
}

function workingRegistration() {
  let registrationAttempts = 0
  return {
    registration: {
      periodicSync: {
        register: async () => {
          registrationAttempts += 1
        },
      },
    },
    registrationAttempts: () => registrationAttempts,
  }
}

test("shows unsupported status without requesting permission when periodic sync is unavailable", async () => {
  const { controller, permissionRequested } = buildController()

  await controller.enable()

  assert.equal(permissionRequested(), false)
  assert.equal(controller.statusTarget.textContent, "unsupported")
  assert.equal(controller.statusTarget.hidden, false)
  assert.equal(controller.buttonTarget.hidden, true)
})

test("keeps the button and shows failed status when periodic sync registration is denied", async () => {
  let registrationAttempts = 0
  const registration = {
    periodicSync: {
      register: async () => {
        registrationAttempts += 1
        throw new Error("Permission denied")
      },
    },
  }
  const { controller } = buildController({ registration })

  await assert.doesNotReject(() => controller.enable())

  assert.equal(registrationAttempts, 1)
  assert.equal(controller.statusTarget.textContent, "failed")
  assert.equal(controller.statusTarget.hidden, false)
  assert.equal(controller.buttonTarget.hidden, false)
})

test("shows enabled status and hides the button after a successful enable", async () => {
  const { registration, registrationAttempts } = workingRegistration()
  const { controller, permissionRequested } = buildController({ registration })

  await controller.enable()

  assert.equal(permissionRequested(), true)
  assert.equal(registrationAttempts(), 1)
  assert.equal(controller.statusTarget.textContent, "enabled")
  assert.equal(controller.statusTarget.hidden, false)
  assert.equal(controller.buttonTarget.hidden, true)
})

test("shows blocked status when the permission prompt is denied", async () => {
  const { registration, registrationAttempts } = workingRegistration()
  const { controller } = buildController({ registration, permissionResult: "denied" })

  await controller.enable()

  assert.equal(registrationAttempts(), 0)
  assert.equal(controller.statusTarget.textContent, "blocked")
  assert.equal(controller.statusTarget.hidden, false)
})

test("connect shows blocked status without prompting when permission was previously denied", async () => {
  const { registration } = workingRegistration()
  const { controller, permissionRequested } = buildController({ registration, permission: "denied" })

  await controller.connect()

  assert.equal(permissionRequested(), false)
  assert.equal(controller.statusTarget.textContent, "blocked")
  assert.equal(controller.statusTarget.hidden, false)
})

test("connect shows the button when permission has not been decided", async () => {
  const { registration, registrationAttempts } = workingRegistration()
  const { controller, permissionRequested } = buildController({ registration })
  controller.buttonTarget.hidden = true
  controller.statusTarget.hidden = false
  controller.statusTarget.textContent = "stale"

  await controller.connect()

  assert.equal(permissionRequested(), false)
  assert.equal(registrationAttempts(), 0)
  assert.equal(controller.buttonTarget.hidden, false)
  assert.equal(controller.statusTarget.hidden, true)
})

test("connect re-registers and shows enabled status when permission was already granted", async () => {
  const { registration, registrationAttempts } = workingRegistration()
  const { controller } = buildController({ registration, permission: "granted" })

  await controller.connect()

  assert.equal(registrationAttempts(), 1)
  assert.equal(controller.statusTarget.textContent, "enabled")
  assert.equal(controller.buttonTarget.hidden, true)
})
