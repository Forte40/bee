if not http then
  print("No access to web")
  return
end

local branch = "master"

local files = {
  {
    name = "bee",
    url = "https://raw.github.com/Forte40/bee/"..branch.."/bee.lua"
  }
}

for _, file in ipairs(files) do
  local path
  if file.folder and not fs.exists(file.folder) then
    fs.makeDir(file.folder)
    path = fs.combine(file.folder, file.name)
    io.write("Installing '" .. file.name .. "' to " .. file.folder .. " ...")
  else
    path = file.name
    io.write("Installing '" .. file.name .. "' ...")
  end
  if fs.exists(path) then
    io.write(" overwriting ...")
  end
  local request = http.get(file.url)
  if request then
    local response = request.getResponseCode()
    if response == 200 then
      local f = fs.open(path, "w")
      f.write(request.readAll())
      f.close()
      print(" done")
    else
      print(" bad HTTP response code " .. response)
    end
  else
    print(" no request handle")
  end
  os.sleep(0.1)
end
print("Finished")
