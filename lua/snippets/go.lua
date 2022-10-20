local ls = require "luasnip"
-- some shorthands...
local snip = ls.snippet
local text = ls.text_node
local insert = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamic = ls.dynamic_node
local events = require "luasnip.util.events"
local snip_node = ls.snippet_node

local function string_split(s, delimter)
    local result = {}
    for match in (s .. delimter):gmatch("(.-)" .. delimter) do
        table.insert(result, match)
    end
    return result
end

local M = {
    ------------------------------------------------
    ----     Package  Statement
    ------------------------------------------------
    snip(
        { trig = "pkgmain", docstring = "package main\n func main(){\n}" },
        {
            text({ "package main", "" }),
            text({ "func main(){", "" }),
            text({ "}" }),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                }
            }
        }
    ),
    snip(
        { trig = "fmain", docstring = "func main(){\n}" },
        {
            text({ "func main(){", "" }),
            text({ "}" }),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                }
            }
        }
    ),
    ------------------------------------------------
    ----     Type  Keyword
    ------------------------------------------------
    snip(
        { trig = "typ",
            docstring = "////Press to <C-s> trigger \ntype Name struct{\n\tField\tType\n}\n\n////or type Name interface{\n\tMethod\n}" }
        ,
        {
            choice(1, {
                snip_node(nil, {
                    func(function(args, snip, _)
                        return "// " .. args[1][1] .. " represent " .. string.lower(args[1][1])
                    end, { 1 }, nil),
                    text({ "", "" }),
                    text({ "type " }), insert(1, "Name"), text({ " struct {", "" }), -- type Name interface{
                    text "\t",
                    insert(2, "Field"), text "\t", insert(3, "Type"),
                    text({ "", "}" }),
                    insert(0)
                }),
                snip_node(nil, {
                    func(function(args, snip, _)
                        return "// " .. args[1][1] .. " represent " .. string.lower(args[1][1])
                    end, { 1 }, nil),
                    text({ "", "" }),
                    text({ "type " }), insert(1, "Name"), text({ " interface {", "" }), -- type Name interface{
                    text "\t",
                    insert(2, "Method"),
                    text({ "", "}" }),
                    insert(0)
                }),
            })
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                }
            }
        }
    ),
    -- type Name struct {}
    snip(
        { trig = "typs", docstring = "type Name struct{\n\tField\tType\n}" },
        {
            func(function(args, snip, _)
                return "// " .. args[1][1] .. " represent " .. string.lower(args[1][1])
            end, { 1 }, nil),
            text({ "", "" }),
            text({ "type " }), insert(1, "Name"), text({ " struct {", "" }), -- type Name interface{
            text "\t",
            insert(2, "Field"), text "\t", insert(3, "Type"),
            text({ "", "}" }),
            insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- type Name interface{}
    snip(
        { trig = "typi", docstring = "type Name interface{\n\tMethod\n}" },
        {
            func(function(args, snip, _)
                return "// " .. args[1][1] .. " represent " .. string.lower(args[1][1])
            end, { 1 }, nil),
            text({ "", "" }),
            text({ "type " }), insert(1, "Name"), text({ " interface {", "" }), -- type Name interface{
            text "\t",
            insert(2, "Method"),
            text({ "", "}" }),
            insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),

    ------------------------------------------------
    ----     Struct Method
    ------------------------------------------------
    -- func(obj *Obj)FuncName(args..)(rets...){}
    snip(
        { trig = "methodsptr",
            docstring = "//this is example struct\ntype Example struct{\n}\n\n//following code will be autogenerated \n//Example cometrue MethodName\nfunc(example *Example) MethodName(Params...)(Rets...){\n\tpanic(\"unimplemented\")\n}" }
        ,
        {
            func(function(args, snip, _)
                return "// " .. args[1][1] .. " represent " .. string.lower(args[1][1])
            end, { 1 }, nil),
            text({ "", "" }),
            text({ "func (" }), func(function(args, snip, user_arg_1)
                local lowstr = string.lower(args[1][1])
                return lowstr .. " *"
            end, { 1 }, nil), insert(1, "Name"), text ") ",
            insert(2, "MethodName"), text({ "(" }), insert(3, "Args..."), text(")("), insert(4, "Rets"),
            text({ "){", "" }), -- func (c *Cat)Name(aegs)(){
            text "\t",
            insert(5, "panic(\"unimplemented\")"),
            text({ "", "" }),
            text("}"),
            insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),

    snip(
        { trig = "methodstruct",
            docstring = "// this is example struct \ntype Example struct{\n}\n\n//following code will be autogenerated \n//Example cometrue MethodName\nfunc(example Example) MethodName(Params...)(Rets...){\n\tpanic(\"unimplemented\")\n}" }
        ,
        {
            func(function(args, snip, _)
                return "// " .. args[1][1] .. " represent " .. string.lower(args[1][1])
            end, { 1 }, nil),
            text({ "", "" }),
            text({ "func (" }), func(function(args, snip, user_arg_1)
                local lowstr = string.lower(args[1][1])
                return lowstr .. " "
            end, { 1 }, nil), insert(1, "Name"), text ") ",
            insert(2, "MethodName"), text({ "(" }), insert(3, "Params..."), text(")("), insert(4, "Rets..."),
            text({ "){", "" }), -- func (c *Cat)Name(aegs)(){
            text "\t", insert(5, "panic(\"unimplemented\")"),
            text({ "", "" }),
            text("}"),
            insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- impl
    snip(
        { trig = "impl",
            docstring = "//example interface \ntype Animal interface{\n\tEat()\n}\n\n//example struct\ntype Cat struct{\n}\n\n//the following code will be auto generator \n\nvar _ Animal = new(Cat)\n\n// following code will be autogenerated\nfunc (*Cat) Eat(){\n\tpanic(\"unimplemented\")\n}" }
        ,
        {
            text({ "var _ " }), insert(1, "ImplName"), text " = new(", insert(2, "StructName"), text({ ")" }), insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.code_action() end,
                },
            },
        }
    ),
    snip(
        { trig = "`json", docstring = "type Example struct {\n\tField1\tstring\t`json:\"field1\"`\n}" },
        {
            func(function(args, snip, _)
                local _, env = {}, snip.env
                local result = string_split(env.TM_CURRENT_LINE:match("^[%s]*(.-)[%s]*$"), " ")
                if #result == 0 then
                    return ""
                end
                local field = string.lower(result[1]:match("^[%s]*(.-)[%s]*$"))
                return "`json:\"" .. field .. "\""
            end, {}, nil), insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    snip(
        { trig = "`xml", docstring = "type Example struct {\n\tField1\tstring\t`xml:\"field1\"`\n}" },
        {
            func(function(args, snip, _)
                local _, env = {}, snip.env
                local result = string_split(env.TM_CURRENT_LINE:match("^[%s]*(.-)[%s]*$"), " ")
                if #result == 0 then
                    return ""
                end
                local field = string.lower(result[1]:match("^[%s]*(.-)[%s]*$"))
                return "`json:\"" .. field .. "\""
            end, {}, nil), insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    snip(
        { trig = "funcerr", docstring = "func FuncName(Params...) error {\n\tpanic(\"unimplemented\")\n\treturn nil\n}" }
        ,
        {
            text("func "), insert(1, "FuncName"), text("("), insert(2, "Params..."), text(")"), insert(3, " error"),
            text({ "{", "" }),
            text("\t"), text({ "panic(\"unimplemented\")", "" }),
            text("\t"), text({ "return nil", "" }),
            text("}"), insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- function  with return
    snip(
        { trig = "funcret", docstring = "func FuncName(Params...)(Rets...){\n\tpanic(\"unimplemented\")\n}" },
        {
            text("func "), insert(1, "FuncName"), text("("), insert(2, "Params..."), text(")("), insert(3, "Rets..."),
            text({ "){", "" }),
            text("\t"), text({ "panic(\"unimplemented\")", "" }),
            text("}"), insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- function  with no return
    snip(
        { trig = "funcnil", docstring = "func FuncName(Params ...){\n\tpanic(\"unimplemented\")\n}" },
        {
            text("func "), insert(1, "FuncName"), text("("), insert(2, "Params..."), text({ "){", "" }),
            text("\t"), text({ "panic(\"unimplemented\")", "" }),
            text("}"), insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- for k,v := range xxx {}
    snip(
        { trig = "forrange", docstring = "for key,value := range iterObj {\n\tpanic(\"unimplemented\")\n}" },
        {
            text("for "), insert(1, "key"), text(","), insert(2, "value"), text(" := range "), insert(3, "iterObj"),
            text({ "{", "" }),
            text("\t"), insert(4, "panic(\"unimplemented\")"), text({ "", "" }),
            text("}"),
            insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- for index :=0; index < count; index ++{}
    snip(
        { trig = "forindex",
            docstring = "for index := initValue; index < bound;  index ++{\n\tpanic(\"unimplemented\")\n}" },
        {
            text("for "), insert(1, "index"), text(" := "), insert(2, "initValue"), text(" ; "),
            func(function(args, _, _) return args[1][1] end, { 1 }, nil), text(" < "),
            insert(3, "bound"), text(" ; "), func(function(args, _, _) return args[1][1] .. "++" end, { 1 }, nil);
            text({ "{", "" }),
            text "\t", insert(4, "panic(\"unimplemented\")"), text({ "", "" }),
            text("}"), insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- for condition {}
    snip(
        { trig = "forcondition", docstring = "for condition {\n\tpanic(\"unimplemented\")\n}" },
        {
            text("for "), insert(1, "condition"), text({ " {", "" }),
            text "\t", insert(2, "panic(\"unimplemented\")"), text({ "", "" }),
            text("}"), insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- for true {}
    snip(
        { trig = "fortrue", docstring = "for {\n\tpanic(\"unimplemented\")\n}" },
        {
            text({ "for {", "" }),
            text "\t", insert(1, "panic(\"unimplemented\")"), text({ "", "" }),
            text("}"), insert(0)
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),

    ------------------------------------------------
    ----      If Statement
    ------------------------------------------------
    snip(
        { trig = "ifcondition", docstring = "if condition {\n\tpanic(\"unimplemented\")\n}" },
        {
            text("if "), insert(1, "condition"), text({ " {", "" }), -- if condition {
            text "\t", insert(2, "panic(\"unimplemented\")"), text({ "", "" }),
            text("}"), insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    snip(
        { trig = "iferr", docstring = "if err!= nil {\n\treturn err\n}" },
        {
            text({ "if err != nil {", "" }), -- if condition {
            text "\t", text({ "return err", "" }),
            text("}"), insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    snip(
        { trig = "ifnil", docstring = "if !condition {\n\tpanic(\"unimplemented\")\n}" },
        {
            text("if !"), insert(1, "condition"), text({ " {", "" }), -- if condition {
            text "\t", insert(2, "panic(\"unimplemented\")"), text({ "", "" }),
            text("}"), insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    snip(
        { trig = "ifelse", docstring = "if condition {\n\tpanic(\"unimplemented\")\n}" },
        {
            text("if "), insert(1, "condition"), text({ " {", "" }), -- if condition {
            text "\t", insert(2, "panic(\"unimplemented\")"), text({ "", "" }),
            text({ "} else {", "" }),
            text "\t", insert(3, "panic(\"unimplemented\")"),
            text({ "", "" }),
            text("}"), insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- if debug
    snip(
        { trig = "ifdebug",
            docstring = "var debug = true\nif debug {\n\tpanic(\"unimplemented\")\n} else {\n\t panic(\"unimplemented\")\n}" }
        ,
        {
            text({ "var debug = true", "" }),
            text({ "if debug {", "" }),
            text "\t", insert(1, "panic(\"unimplemented\")"), text({ "", "" }),
            text({ "} else {", "" }),
            text "\t", insert(2, "panic(\"unimplemented\")"),
            text({ "", "" }),
            text("}"), insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),

    -- select
    snip(
        { trig = "select",
            docstring = "select{\ncase caseCondition:\n\tpanic(\"unimplemented\")\ndefault:\n\tpanic(\"unimplemented\")" }
        ,
        {
            text({ "select {", "" }),
            text "case ", insert(1, "caseCondition"), text({ ":", "" }),
            text "\t", text("panic(\"unimplemented\")"), text({ "", "" }),
            text({ "default:", "" }),
            text "\t", text("panic(\"unimplemented\")"), text({ "", "" }),
            text "}", insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- switch
    snip(
        { trig = "switch",
            docstring = "switch Type {\ncase CaseStatement:\n\tpanic(\"unimplemented\")\ndefault:\n\tpanic(\"unimplemented\")\n}" }
        ,
        {
            text "switch ", insert(1, "Type"), text({ " {", "" }),
            text "case ", insert(2, "CaseStatement"), text({ " :", "" }),
            text "\t", text("panic(\"unimplemented\")"), text({ "", "" }),
            text({ "default:", "" }),
            text "\t", text("panic(\"unimplemented\")"), text({ "", "" }),
            text("}"), insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),
    -- for test
    snip(
        { trig = "gofunc", docstring = "go func(){\n\tpanic(\"unimplemented\")\n}" },
        {
            text({ "go func(){", "" }),
            text "\t", text({ "panic(\"unimplemented\")", "" }),
            text({ "}()", "" }),
            insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),

    -- for business
    snip(
        { trig = "chanwrap",
            docstring = "func chanWrap(input chan <- int, process func(c int) int) int\n\tout := make(chan interface{})\n\tgo func(){\n\t\tdefer close (out)\n\t\tfor e := range input{\n\t\t\tout <- process(e)\n\t\t}\n\t}()\n\treturn out\n}" }
        ,
        {
            text({ "func chanRunWith(input <- chan " }), insert(1, "ChanType"), text ", process func(c ",
            func(function(args, _, _)
                return table.remove(vim.split(args[1][1], " "), 1)
            end, { 1 }, nil),
            text ")",
            func(function(args, _, _)
                return table.remove(vim.split(args[1][1], " "), 1)
            end, { 1 }, nil), text({ ") chan <- " }),
            func(function(args, _, _)
                return table.remove(vim.split(args[1][1], " "), 1)
            end, { 1 }, nil), text({ "{", "" }), -- function chanWrap(input chan <- Type, function(c chan <- Type) <- chan Type ) <- chan Type{
            text"\t",text({ "out := make(chan " }), func(function(args, _, _)
                return table.remove(vim.split(args[1][1], " "), 1)
            end, { 1 }, nil),  text{")", ""},-- out := make(chan interface{})
            text"\t",text({"go func(){", "" }), -- go func(){
            text"\t\t",text({ "defer close (out)", "" }), -- defer close (out)
            text"\t\t",text({ "for e := range input {", ""}),
            text"\t\t\t",text({"out <- process(e)", "" }), -- out <- process(e)
            text"\t\t", text({"}", "" }), -- }
            text"\t", text({"}()", ""}),
            text"\t",text({"return out", "" }), -- return out
            text({ "}", "" }), -- }
            insert(0),
        },
        {
            callbacks = {
                [0] = {
                    [events.enter] = function(node, _event_args) vim.lsp.buf.formatting() end,
                },
            },
        }
    ),


}


return M
