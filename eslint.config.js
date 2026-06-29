import js from "@eslint/js"

export default [
  {
    ...js.configs.recommended,
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        window: "readonly",
        document: "readonly",
        navigator: "readonly",
        self: "readonly",
        clients: "readonly",
        indexedDB: "readonly",
        Notification: "readonly",
      },
    },
  },
]
