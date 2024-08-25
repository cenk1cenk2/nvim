local s = require("ck.utils.snippets")

return {
  s.s(
    {
      name = "export globstar",
      trig = "exgs",
      desc = { "Export globstar from the file." },
    },
    s.fmt(
      [[
      export * from './<>'
      ]],
      {
        s.i(1),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      name = "export selected",
      trig = "exps",
      desc = { "Export selected from the file." },
    },
    s.fmt(
      [[
      export { <> } from './<>'
      ]],
      {
        s.i(2),
        s.i(1),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      name = "constructor",
      trig = "cns",
      desc = { "Add a constructor to the class." },
    },
    s.fmt(
      [[
      constructor (<>) {
        <>
      }
      ]],
      {
        s.i(1),
        s.i(2),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      name = "nestjs controller",
      trig = "n-controller",
      desc = { "Create a NestJS Controller." },
    },
    s.fmt(
      [[
      import { Controller } from '@nestjs/common'

      @Controller()
      export class <>Controller {
        constructor (<>) {}
      }
      ]],
      {
        s.i(1),
        s.i(2),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      name = "nestjs service",
      trig = "n-service",
      desc = { "Create a NestJS Service." },
    },
    s.fmt(
      [[
      import { Injectable } from '@nestjs/common'

      @Injectable()
      export class <>Service {
        constructor (<>) {}
      }
      ]],
      {
        s.i(1),
        s.i(2),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      name = "nestjs module",
      trig = "n-module",
      desc = { "Create a NestJS Module." },
    },
    s.fmt(
      [[
      import { Module } from '@nestjs/common'

      @Module({
        imports: [],
        controllers: [],
        providers: [<>],
        exports: []
      })
      export class <>Module {}
      ]],
      {
        s.i(2),
        s.i(1),
      },
      { delimiters = "<>" }
    )
  ),
}
