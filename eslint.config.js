import js from "@eslint/js";
import globals from "globals";
import react from "eslint-plugin-react";
import importPlugin from "eslint-plugin-import";
import jsxA11y from "eslint-plugin-jsx-a11y";
import prettier from "eslint-plugin-prettier";
import prettierConfig from "eslint-config-prettier";

export default [
  // Base JS recommended rules
  js.configs.recommended,

  // Turn off rules that conflict with Prettier
  prettierConfig,

  // Ignore specific files
  {
    ignores: ["spec/javascript/psulib_blacklight/align_rtl_index.spec.js"]
  },

  {
    files: ["**/*.{js,jsx}"],

    languageOptions: {
      ecmaVersion: 2020,
      sourceType: "module",
      parserOptions: {
        ecmaFeatures: {
          jsx: true
        }
      },
      globals: {
        ...globals.browser,
        ...globals.node,
        ...globals.jest,
        Atomics: "readonly",
        SharedArrayBuffer: "readonly",
        Blacklight: "writable",
        $: "readonly",
        jQuery: "readonly"
      }
    },

    plugins: {
      react,
      import: importPlugin,
      "jsx-a11y": jsxA11y,
      prettier
    },

    settings: {
      react: {
        version: "detect"
      }
    },

    rules: {
      // --- General ---
      "consistent-return": "off",
      "guard-for-in": "off",
      "max-len": ["error", { code: 120 }],
      "no-alert": "off",
      "no-param-reassign": "off",
      "no-use-before-define": "off",

      "no-restricted-syntax": [
        "error",
        "LabeledStatement",
        "WithStatement"
      ],

      // --- Import (replacement for Airbnb defaults) ---
      "import/order": [
        "error",
        {
          groups: ["builtin", "external", "parent", "sibling", "index"]
        }
      ],
      "import/no-cycle": "off",

      // --- React ---
      "react/forbid-prop-types": "off",
      "react/function-component-definition": [
        "error",
        { namedComponents: "arrow-function" }
      ],
      "react/jsx-filename-extension": "off",
      "react/jsx-no-target-blank": "off",
      "react/jsx-uses-react": "off",
      "react/jsx-uses-vars": "error",
      "react/no-array-index-key": "off",
      "react/react-in-jsx-scope": "off",
      "react/require-default-props": "off",

      // --- Accessibility (jsx-a11y) ---
      // (Airbnb included this implicitly, so we keep it)
      "jsx-a11y/anchor-is-valid": "warn",

      // --- Prettier ---
      "prettier/prettier": [
        "error",
        { singleQuote: true }
      ]
    }
  }
];