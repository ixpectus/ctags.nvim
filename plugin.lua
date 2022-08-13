local has_telescope, _ = pcall(require, "telescope")
if not has_telescope then
  print("telescope not found")
  return
end

local finders = require("telescope.finders")
local control = require("plenary.async.control")
local pickers = require("telescope.pickers")
local cmd = {
  "ctags",
  "-R",
  "-n",
  "--fields=k",
  "--go-kinds=f",
  "-f-",
  "/home/ixpectus/repos/avitoRepos/job/service-job-assistant/pkg/chatter"
}
local cmdLs = {
  "ls",
  "/home/ixpectus"
}

file = io.open("./out", "w+")
function entryMaker(line)
  local value = {}
  file:write(line .. "\n")
  value.name, value.filename, value.line, value.type = string.match(line, "(.-)\t(.-)\t(%d+).-\t(.*)")
  file:write(vim.inspect(value) .. "\n")
end
local opts = {}
opts.bufnr = vim.fn.bufnr()
opts.entry_maker = entryMaker
local fnr = finders.new_oneshot_job(cmd, opts)
function process(result)
  -- print(1)
  -- print(result.value)
  -- local s = table.concat(result, "\n")
  -- print(s)
  -- file:write(result.value .. "\n")
  -- file:close()
end
function processClose(result)
  file:close()
end
local a = require("plenary.async")
a.run(
  function()
    fnr(_, process, processClose)
  end,
  function()
  end
)
