return function(base_path)
  local paths = vim.fn.glob(base_path .. "nvimtool/**/*.lua", false, true)
  for _, path in ipairs(paths) do
    local name = path:gsub("^" .. base_path, "")
    name = name:gsub(".lua$", "")
    package.loaded[name] = nil
  end
end
