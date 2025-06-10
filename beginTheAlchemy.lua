local title = [[
    _    _      _                          TM
   / \  | | ___| |__   ___ _ __ ___  _   _ 
  / _ \ | |/ __| '_ \ / _ \ '_ ` _ \| | | |
 / ___ \| | (__| | | |  __/ | | | | | |_| |
/_/   \_\_|\___|_| |_|\___|_| |_| |_|\__, |
                                     |___/ 
A ComputerCraft Operating System.
]]

print("Beginning Alchemy...")

local repo = "https://raw.githubusercontent.com/Catylist0/AlchemyOS/main/"
local idFile = "recipe.lua"

-- Fetch and load file list
local res = http.get(repo .. idFile) or error("Failed to fetch " .. idFile)
local tmp = "__ids.lua"
local f = fs.open(tmp, "w") f.write(res.readAll()) f.close() res.close()
local launchRecipe = dofile(tmp)
local files = launchRecipe.fileIdentities or error("No file identities found in " .. idFile)
local latestVersion = launchRecipe.version or error("No version found in " .. idFile)
fs.delete(tmp)
if type(files) ~= "table" then error("Invalid file list") end

local existingRecipe = fs.exists("/recipe.lua") and dofile("/recipe.lua") or launchRecipe
local currentVersion = existingRecipe.version
if not existingRecipe then
    print("Recipe load fail")
end

if not currentVersion then 
    currentVersion = "0.0.0"
    print("Error, no current recipe version, falling back to 0.0.0")
end

local shouldUpdate = false
if currentVersion ~= latestVersion then shouldUpdate = true end

print("Local Version: " .. tostring(currentVersion))

print("New Version Detected: " .. tostring(shouldUpdate))
-- Download each file (rate-limited)
if shouldUpdate then
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
end

print("Done.")
sleep(3)
error("end")
