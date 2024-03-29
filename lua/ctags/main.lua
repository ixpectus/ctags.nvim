local _2afile_2a = "fnl/ctags/main.fnl"
local _2amodule_name_2a = "ctags.main"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local finders = require("telescope.finders")
local conf = (require("telescope.config")).values
local pickers = require("telescope.pickers")
local entry_display = require("telescope.pickers.entry_display")
local strings = require("plenary.strings")
local sorters = require("telescope.sorters")
local function build_shell_cmd(opts)
  local cmd = opts.cmd
  for key, value in pairs(opts.exclude) do
    table.insert(cmd, ("--exclude=" .. value))
  end
  if (opts.type ~= "") then
    if (opts.filetype ~= "") then
      table.insert(cmd, ("--" .. opts.filetype .. "-kinds=" .. opts.type))
      table.insert(cmd, ("--languages" .. "=" .. opts.filetype))
    else
    end
  else
  end
  if (opts.type == "") then
    if (opts.filetype ~= "") then
      table.insert(cmd, ("--languages" .. "=" .. opts.filetype))
    else
    end
  else
  end
  table.insert(cmd, opts.path)
  _G.cmdMap = cmd
  return cmd
end
_2amodule_locals_2a["build-shell-cmd"] = build_shell_cmd
local function run_shell_cmd(cmd)
  return vim.fn.systemlist(cmd)
end
_2amodule_locals_2a["run-shell-cmd"] = run_shell_cmd
local function common_part(str1, str2)
  local i = 1
  if (str1 ~= nil) then
    for c in str1:gmatch(".") do
      if (string.sub(str2, i, i) == c) then
        i = (i + 1)
      else
      end
    end
    return string.sub(str1, 1, (i - 1))
  else
    return nil
  end
end
_2amodule_locals_2a["common-part"] = common_part
local function build_make_display(confOpts)
  local opts = confOpts
  local function _7_(entry)
    _G.assert((nil ~= entry), "Missing argument entry on fnl/ctags/main.fnl:44")
    local display_items = {{remaining = true}, {remaining = true}}
    local items = {{(entry.value.type .. " "), "TelescopeResultsVariable"}}
    if opts.show_scope then
      local scope = vim.trim(entry.value.scope)
      if (scope ~= "") then
        table.insert(display_items, {remaining = true})
        table.insert(items, {(entry.value.scope .. " "), "TelescopeResultsStruct"})
      else
      end
    else
    end
    table.insert(items, {(entry.value.name .. " "), "TelescopeResultsFunction"})
    if opts.show_file then
      local estimatedLen = (string.len(entry.filename) - string.len(opts.path))
      local filename = strings.truncate(entry.filename, estimatedLen, "", -1)
      table.insert(display_items, {remaining = true})
      table.insert(items, {filename, "TelescopeResultsComment"})
    else
    end
    if opts.show_line then
      table.insert(display_items, {remaining = true})
      table.insert(items, {(":" .. entry.value.line), "TelescopeResultsComment"})
    else
    end
    return entry_display.create({separator = "", items = display_items})(items)
  end
  return _7_
end
local function prepare_entry_to_telescope_display(opts, entry)
  if string.match(entry, "{") then
    local _12_, _13_ = pcall(vim.json.decode, ("{" .. string.gsub(string.gsub(entry, "}", ""), "{", "") .. "}"))
    if ((_12_ == true) and (nil ~= _13_)) then
      local decoded = _13_
      local value = {type = decoded.kind, line = tonumber(decoded.line), name = decoded.name, pattern = decoded.pattern, filename = decoded.path}
      if vim.F.if_nil(opts.show_scope, false) then
        value["scope"] = vim.F.if_nil(decoded.scope, "")
      else
      end
      return {filename = value.filename, lnum = tonumber(value.line), value = value, display = build_make_display(opts), ordinal = (value.line .. value.type .. value.name .. value.filename)}
    elseif ((_12_ == false) and (nil ~= _13_)) then
      local errMsg = _13_
      return error(string.format("error %s on parse ctag results %s", errMsg, entry))
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_locals_2a["prepare-entry-to-telescope-display"] = prepare_entry_to_telescope_display
local function filter_empty(items)
  local result = {}
  for key, value in pairs(items) do
    if (value ~= "") then
      table.insert(result, value)
    else
    end
  end
  return result
end
_2amodule_locals_2a["filter-empty"] = filter_empty
local function items_common_part(items)
  if (table.getn(items) > 0) then
    local commonPart = ((items[1]).value).scope
    for key, value in pairs(items) do
      if (key ~= table.getn(items)) then
        local nextValue = items[(key + 1)]
        commonPart = common_part(commonPart, nextValue.value.scope)
      else
      end
    end
    return commonPart
  else
    return nil
  end
end
_2amodule_locals_2a["items-common-part"] = items_common_part
local function trim(s, sym)
  local res = string.gsub(string.gsub(s, ("^" .. sym), ""), (sym .. "$"), "")
  return res
end
_2amodule_locals_2a["trim"] = trim
local function remove_items_common_part(items, common_part0)
  if (common_part0 ~= nil) then
    local res
    local function _20_(entry)
      _G.assert((nil ~= entry), "Missing argument entry on fnl/ctags/main.fnl:111")
      do end (entry.value)["scope"] = trim(string.gsub(entry.value.scope, common_part0, "", 1), "%.")
      return entry
    end
    res = vim.tbl_map(_20_, items)
  else
  end
  if (common_part0 == nil) then
    return items
  else
    return nil
  end
end
_2amodule_locals_2a["remove-items-common-part"] = remove_items_common_part
local function RunCtags(initOpts)
  local defaults
  local function default_filter(entry)
    return true
  end
  defaults = {filter = default_filter, path = vim.fn.expand("%:p"), exclude = {}, type = "", show_file = false, show_line = true, show_scope = false, cmd = {"ctags", "--recurse", "--fields=+n", "--quiet=yes", "-f-", "--output-format=json"}}
  local opts = vim.tbl_deep_extend("force", defaults, vim.F.if_nil(initOpts, {}))
  if (opts.filetype == nil) then
    opts["filetype"] = vim.fn.fnamemodify(opts.path, ":e")
  else
  end
  local items = filter_empty(run_shell_cmd(build_shell_cmd(opts)))
  local finalItems = {}
  for key, value in pairs(items) do
    table.insert(finalItems, prepare_entry_to_telescope_display(opts, value))
  end
  remove_items_common_part(finalItems, items_common_part(finalItems))
  if (opts.show_scope and opts.scope_filter) then
    local function _24_(e)
      _G.assert((nil ~= e), "Missing argument e on fnl/ctags/main.fnl:148")
      return opts.scope_filter(e.value.scope)
    end
    finalItems = vim.tbl_filter(_24_, finalItems)
  else
  end
  local picker
  local function _26_(entry)
    _G.assert((nil ~= entry), "Missing argument entry on fnl/ctags/main.fnl:154")
    return entry
  end
  picker = pickers.new(opts, {prompt_title = "ctags", finder = finders.new_table({results = finalItems, entry_maker = _26_}), sorter = sorters.get_generic_fuzzy_sorter()})
  return picker:find()
end
_2amodule_2a["RunCtags"] = RunCtags
local function RunCtagsFile(initOpts)
  local defaults = {path = vim.fn.expand("%:p"), type = "f", show_scope = true, filetype = vim.bo.filetype}
  local opts = vim.tbl_deep_extend("force", defaults, vim.F.if_nil(initOpts, {}))
  return RunCtags(opts)
end
_2amodule_2a["RunCtagsFile"] = RunCtagsFile
local function RunCtagsPackage(initOpts)
  local defaults = {path = vim.fn.expand("%:p:h"), type = "f", show_scope = true, filetype = vim.bo.filetype, show_file = true}
  local opts = vim.tbl_deep_extend("force", defaults, vim.F.if_nil(initOpts, {}))
  return RunCtags(opts)
end
_2amodule_2a["RunCtagsPackage"] = RunCtagsPackage
local function RunCtagsRoot(initOpts)
  local defaults = {path = vim.fn.finddir(".git/..", (vim.fn.expand("%:p:h") .. ";")), type = "f", show_scope = true, show_file = true}
  local opts = vim.tbl_deep_extend("force", defaults, vim.F.if_nil(initOpts, {}))
  return RunCtags(opts)
end
_2amodule_2a["RunCtagsRoot"] = RunCtagsRoot
local function RunCtagsPackageCurWorldScope(initOpts)
  local defaults
  local function _27_(v)
    _G.assert((nil ~= v), "Missing argument v on fnl/ctags/main.fnl:189")
    return string.match(v, vim.call("expand", "<cword>"))
  end
  defaults = {scope_filter = _27_}
  local opts = vim.tbl_deep_extend("force", defaults, vim.F.if_nil(initOpts, {}))
  return RunCtagsPackage(opts)
end
_2amodule_2a["RunCtagsPackageCurWorldScope"] = RunCtagsPackageCurWorldScope
local function RunCtagsCmd(opts)
  return RunCtags(unpack(opts.fargs))
end
_2amodule_2a["RunCtagsCmd"] = RunCtagsCmd
local function init()
  vim.api.nvim_create_user_command("CtagsPackageCurWorldScope", RunCtagsPackageCurWorldScope, {nargs = "*", range = true, complete = "file"})
  vim.api.nvim_create_user_command("CtagsRoot", RunCtagsRoot, {nargs = "*", range = true, complete = "file"})
  vim.api.nvim_create_user_command("CtagsPackage", RunCtagsPackage, {nargs = "*", range = true, complete = "file"})
  vim.api.nvim_create_user_command("CtagsFile", RunCtagsFile, {nargs = "*", range = true, complete = "file"})
  return vim.api.nvim_create_user_command("CtagsCore", RunCtagsCmd, {nargs = "*", range = true, complete = "file"})
end
_2amodule_2a["init"] = init
return _2amodule_2a