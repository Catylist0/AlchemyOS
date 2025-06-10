local repo = "https://raw.githubusercontent.com/Catylist0/AlchemyOS/main/"
local idFile = "fileIdentities.lua"

-- Fetch and load file list
local res = http.get(repo .. idFile) or error("Failed to fetch " .. idFile)
local tmp = "__ids.lua"
local f = fs.open(tmp, "w")
f.write(res.readAll())
f.close()
res.close()
local files = dofile(tmp)
fs.delete(tmp)
if type(files) ~= "table" then error("Invalid file list") end

-- Download each file
for _, path in ipairs(files) do
    local url = repo .. path
    print("Fetching " .. path)
    local r = http.get(url)
    if r then
        if fs.getDir(path) ~= "" then fs.makeDir(fs.getDir(path)) end
        local fh = fs.open(path, "w")
        fh.write(r.readAll())
        fh.close()
        r.close()
    else
        print("Failed: " .. path)
    end
end

print("Done.")
sleep(3)
error("end")