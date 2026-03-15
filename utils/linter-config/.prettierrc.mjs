/** @type {import("prettier").Config} */
export default {
  printWidth: 179,
  tabWidth: 2,
  useTabs: false,
  quoteProps: 'as-needed',
  vueIndentScriptAndStyle: false,
  semi: false,
  singleQuote: false,
  trailingComma: 'none',
  bracketSpacing: true,
  arrowParens: 'always',
  proseWrap: 'preserve',
  endOfLine: 'lf',
  overrides: [
    {
      files: ['*.md'],
      options: {
        proseWrap: 'never'
      }
    },
    {
      files: "neomutt-*",
      options: { parser: "markdown" }
    }
  ]
}
