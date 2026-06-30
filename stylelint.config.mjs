export default {
  ignoreFiles: ["app/assets/stylesheets/mvpa/**/*.css"],
  rules: {
    "at-rule-no-unknown": [true, { ignoreAtRules: ["view-transition"] }],
    "selector-pseudo-element-no-unknown": [
      true,
      { ignorePseudoElements: ["view-transition-new", "view-transition-old"] }
    ],
    "selector-type-no-unknown": [true, { ignore: ["custom-elements"] }]
  }
};
