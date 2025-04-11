local M = {}

function M.file_exists(path)
  return vim.loop.fs_stat(path) ~= nil
end

function M.write_json_file(path, tbl)
  local file = io.open(path, "w")
  if not file then
    vim.notify("❌ Failed to open " .. path .. " for writing", vim.log.levels.ERROR)
    return false
  end

  file:write(M.encode_json(tbl, 0))
  file:close()
  return true
end

function M.encode_json(tbl, indent)
  indent = indent or 0
  local indent_str = string.rep("  ", indent + 1)
  local lines = {"{"}
  local i, n = 0, 0
  for _ in pairs(tbl) do n = n + 1 end

  for k, v in pairs(tbl) do
    i = i + 1
    local key = string.format('"%s"', tostring(k))
    local val
    if type(v) == "string" then
      val = string.format("%q", v)
    elseif type(v) == "number" or type(v) == "boolean" then
      val = tostring(v)
    elseif type(v) == "table" then
      val = vim.fn.json_encode(v)
    else
      val = "null"
    end

    local comma = (i < n) and "," or ""
    table.insert(lines, string.format('%s%s: %s%s', indent_str, key, val, comma))
  end

  table.insert(lines, string.rep("  ", indent) .. "}")
  return table.concat(lines, "\n")
end

function M.ensure_config(path, default_table)
  if M.file_exists(path) then
    vim.notify("🟢 Config exists at " .. path, vim.log.levels.DEBUG)
    return
  end

  if M.write_json_file(path, default_table) then
    vim.notify("✅ Created config: " .. path, vim.log.levels.INFO)
  end
end

return M
