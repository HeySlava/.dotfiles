local M = {}

function M.is_dbt_project()
    return vim.fn.findfile("dbt_project.yml", ".;") ~= "" or vim.fn.findfile("dbt_project.yaml", ".;") ~= ""
end

local function get_project_root()
    local yml = vim.fn.findfile("dbt_project.yml", ".;")
    if yml == "" then
        yml = vim.fn.findfile("dbt_project.yaml", ".;")
    end
    if yml ~= "" then
        return vim.fn.fnamemodify(yml, ":h")
    end
    return vim.fn.getcwd()
end

local function find_target(line, col)
    local patterns = {
        { pattern = "ref%s*%(%s*['\"]([^'\"]+)['\"]%s*%)", kind = "model", target_idx = 1 },
        { pattern = "source%s*%(%s*['\"]([^'\"]+)['\"]%s*,%s*['\"]([^'\"]+)['\"]%s*%)", kind = "source", target_idx = 2 },
    }

    for _, p in ipairs(patterns) do
        local start = 1
        while true do
            local captures = { line:find(p.pattern, start) }
            local s, e = captures[1], captures[2]
            if not s then
                break
            end

            if col >= s - 1 and col <= e - 1 then
                return captures[p.target_idx + 2], p.kind
            end
            start = e + 1
        end
    end

    return nil, nil
end

local function is_dbt_path(path)
    return not (path:match("/target/") or path:match("/dbt_packages/"))
end

local function find_model_file(name, root)
    local dirs = { "models", "seeds", "snapshots", "analyses" }
    for _, dir in ipairs(dirs) do
        local glob = string.format("%s/%s/**/%s.*", root, dir, name)
        local files = vim.fn.glob(glob, false, true)
        for _, f in ipairs(files) do
            if is_dbt_path(f) then
                return f
            end
        end
    end
    return nil
end

local function find_source_definition(name, root)
    local escaped = vim.pesc(name)
    local globs = {
        root .. "/models/**/*.yml",
        root .. "/sources/**/*.yml",
        root .. "/seeds/**/*.yml",
        root .. "/snapshots/**/*.yml",
        root .. "/analyses/**/*.yml",
    }

    for _, glob in ipairs(globs) do
        local files = vim.fn.glob(glob, false, true)
        for _, f in ipairs(files) do
            if is_dbt_path(f) then
                local ok, lines = pcall(vim.fn.readfile, f)
                if ok then
                    for i, l in ipairs(lines) do
                        if l:find("name:%s*" .. escaped) then
                            return f, i
                        end
                    end
                end
            end
        end
    end
    return nil, nil
end

local function go_to_target(target, kind)
    local root = get_project_root()

    if kind == "model" then
        local file = find_model_file(target, root)
        if file then
            vim.cmd("edit " .. vim.fn.fnameescape(file))
        else
            vim.notify("dbt model not found: " .. target, vim.log.levels.ERROR)
        end
    elseif kind == "source" then
        local file, lineno = find_source_definition(target, root)
        if file then
            vim.cmd("edit +" .. lineno .. " " .. vim.fn.fnameescape(file))
        else
            vim.notify("dbt source not found: " .. target, vim.log.levels.ERROR)
        end
    end
end

local function find_alias_target(alias, lines)
    local ref_as_pattern = "%{%{%s*ref%s*%(%s*['\"]([^'\"]+)['\"]%s*%)%s*%}%}%s+as%s+(%w+)"
    local ref_pattern = "%{%{%s*ref%s*%(%s*['\"]([^'\"]+)['\"]%s*%)%s*%}%}%s+(%w+)"
    local source_as_pattern = "%{%{%s*source%s*%(%s*['\"]([^'\"]+)['\"]%s*,%s*['\"]([^'\"]+)['\"]%s*%)%s*%}%}%s+as%s+(%w+)"
    local source_pattern = "%{%{%s*source%s*%(%s*['\"]([^'\"]+)['\"]%s*,%s*['\"]([^'\"]+)['\"]%s*%)%s*%}%}%s+(%w+)"

    for i, line in ipairs(lines) do
        local model, al = line:match(ref_as_pattern)
        if al == alias and model then
            return { kind = "model", target = model, line = i }
        end
        local model2, al2 = line:match(ref_pattern)
        if al2 == alias and model2 then
            return { kind = "model", target = model2, line = i }
        end
        local src, tbl, al3 = line:match(source_as_pattern)
        if al3 == alias and src and tbl then
            return { kind = "source", target = tbl, line = i }
        end
        local src2, tbl2, al4 = line:match(source_pattern)
        if al4 == alias and src2 and tbl2 then
            return { kind = "source", target = tbl2, line = i }
        end
    end

    return nil
end

local function find_cte_definition(name, lines)
    for i, line in ipairs(lines) do
        local cte = line:match("with%s+(%w+)%s+as%s*%(")
        if cte == name then
            return i
        end
        local cte2 = line:match("^%s*(%w+)%s+as%s*%(")
        if cte2 == name then
            return i
        end
    end
    return nil
end

local function find_cte_alias(alias, lines)
    local function check(cte_name, al)
        if al == alias and cte_name then
            local def_line = find_cte_definition(cte_name, lines)
            if def_line then
                return def_line
            end
        end
        return nil
    end

    local patterns = {
        "from%s+(%w+)%s+(%w+)",
        "from%s+(%w+)%s+as%s+(%w+)",
        "join%s+(%w+)%s+(%w+)",
        "join%s+(%w+)%s+as%s+(%w+)",
    }

    for _, line in ipairs(lines) do
        for _, pattern in ipairs(patterns) do
            local cte_name, al = line:match(pattern)
            local def_line = check(cte_name, al)
            if def_line then
                return def_line
            end
        end
    end

    return nil
end

function M.goto_definition()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    local target, kind = find_target(line, col)
    if target and kind then
        go_to_target(target, kind)
        return
    end

    local alias = vim.fn.expand("<cword>")
    if alias and alias ~= "" then
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        local result = find_alias_target(alias, lines)
        if result then
            go_to_target(result.target, result.kind)
            return
        end

        local cte_alias_line = find_cte_alias(alias, lines)
        if cte_alias_line then
            vim.cmd("edit +" .. cte_alias_line .. " " .. vim.fn.fnameescape(vim.fn.expand("%:p")))
            return
        end

        local cte_line = find_cte_definition(alias, lines)
        if cte_line then
            vim.cmd("edit +" .. cte_line .. " " .. vim.fn.fnameescape(vim.fn.expand("%:p")))
            return
        end
    end

    vim.lsp.buf.definition()
end

function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "jinja" },
        callback = function(args)
            if M.is_dbt_project() then
                vim.keymap.set("n", "gd", M.goto_definition, {
                    buffer = args.buf,
                    desc = "DBT go to definition",
                    nowait = true,
                })
            end
        end,
    })
end

return M
