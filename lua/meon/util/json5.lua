local M = {}

function M.decode(content)
  -- Remove // comments only outside of strings
  local result, in_string, i = {}, false, 1
  while i <= #content do
    local c = content:sub(i, i)
    if c == '"' and content:sub(i - 1, i - 1) ~= "\\" then
      in_string = not in_string
      table.insert(result, c)
    elseif not in_string and content:sub(i, i + 1) == "//" then
      while i <= #content and content:sub(i, i) ~= "\n" do
        i = i + 1
      end
    else
      table.insert(result, c)
    end
    i = i + 1
  end
  content = table.concat(result)
  -- Remove trailing commas
  while content:find(",(%s*[%]%}])") do
    content = content:gsub(",(%s*[%]%}])", "%1")
  end
  return vim.json.decode(content)
end

return M
