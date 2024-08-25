return {
  filetypes = {
    -- html
    "aspnetcorerazor",
    "astro",
    "astro-markdown",
    "blade",
    "django-html",
    "edge",
    "eelixir", -- vim ft
    "ejs",
    "erb",
    "eruby", -- vim ft
    "gohtml",
    "haml",
    "handlebars",
    "hbs",
    "html",
    -- 'HTML (Eex)',
    -- 'HTML (EEx)',
    "html-eex",
    "jade",
    "leaf",
    "liquid",
    -- "markdown",
    "mdx",
    "mustache",
    "njk",
    "nunjucks",
    "php",
    "razor",
    "slim",
    "twig",
    -- css
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "stylus",
    "sugarss",
    -- js
    -- "javascript",
    "javascriptreact",
    -- "reason",
    -- "rescript",
    -- "typescript",
    "typescriptreact",
    -- mixed
    "vue",
    "svelte",
  },
  root_dir = function(filename)
    return vim.fs.root(filename, { "tailwind.config.js", "tailwind.config.cjs", "tailwind.js", "tailwind.cjs" })
  end,
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          [[tw`([^`]*)]],
          [[tw\\..+`([^`]*)]],
          [[tw\\(.*?\\).*?`([^`]*)]],
          [[css`([^`]*)]],
          [[css\\..+`([^`]*)]],
          [[css\\(.*?\\).*?`([^`]*)]],
          [[tw`([^`]*)]],
          [[tw=\"([^\"]*)]],
          [[tw={\"([^\"}]*)]],
          [[tw\\.\\w+`([^`]*)]],
          [[tw\\(.*?\\)`([^`]*)]],
        },
      },
    },
  },
}
