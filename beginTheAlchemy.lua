local repo = "https://raw.githubusercontent.com/Catylist0/AlchemyOS/main/"
local idFile = "recipe.lua"
local downloadLimit = 10
local downloadCount = 0

-- ============================
--   GITHUB RAW RATE-LIMIT SAFE INITIALIZER
--   Limits file downloads per run to avoid 429s
-- ============================

-- Fetch and load file list
local res = http.get(repo .. idFile) or error("Failed to fetch " .. idFile)
local tmp = "__ids.lua"
local f = fs.open(tmp, "w") f.write(res.readAll()) f.close() res.close()
local launchRecipe = dofile(tmp)
local files = launchRecipe.fileIdentities or error("No file identities found in " .. idFile)
local latestVersion = launchRecipe.version or error("No version found in " .. idFile)
fs.delete(tmp)
if type(files) ~= "table" then error("Invalid file list") end

local existingRecipe = fs.open("/recipe.lua", "r") or launchRecipe
local currentVersion = existingRecipe.currentVersion or "0.0.0"

local shouldUpdate = false
if currentVersion ~= latestVersion then shouldUpdate = true end

print("New Version Detected: " .. shouldUpdate)
-- Download each file (rate-limited)
if shouldUpdate then
    for _, path in ipairs(files) do
        if downloadCount < downloadLimit then
            local url = repo .. path
            print("Fetching " .. path)
            local r = http.get(url)
            if r then
                if fs.getDir(path) ~= "" then fs.makeDir(fs.getDir(path)) end
                local fh = fs.open(path, "w")
                fh.write(r.readAll())
                fh.close()
                r.close()
                downloadCount = downloadCount + 1
            else
                print("Failed: " .. path)
            end
        else
            print("Rate limit reached. Skipping: " .. path)
        end
    end
end

print("Done.")
sleep(3)
error("end")
