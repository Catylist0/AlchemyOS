local title = [[
    _    _      _                          TM
   / \  | | ___| |__   ___ _ __ ___  _   _ 
  / _ \ | |/ __| '_ \ / _ \ '_ ` _ \| | | |
 / ___ \| | (__| | | |  __/ | | | | | |_| |
/_/   \_\_|\___|_| |_|\___|_| |_| |_|\__, |
                                     |___/ 
A ComputerCraft Operating System.
]]

math.randomseed(os.clock() * 100000)

local function randomHash()
    return string.format("%x", math.random(0, 0xFFFFFFFF))
end

SessionID = randomHash()

function log(msg)
    -- append the log message to logs/<SessionID>.log
    local logFile = "logs/" .. SessionID .. ".log"
    local f = fs.open(logFile, "a")
    if f then
        f.writeLine(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. msg)
        f.close()
    else
        hang(4, "Failed to open log file: " .. logFile)
    end
end

local function startSession()
    -- check if logs directory exists, if not create it
    if not fs.isDir("logs") then
        fs.makeDir("logs")
    end
    -- create a blank log file for this session
    local logFile = "logs/" .. SessionID .. ".log"
    local f = fs.open(logFile, "w")
    log("Session started: " .. SessionID)
end

function printLogs()
    -- print the contents of the log file to the terminal
    local logFile = "logs/" .. SessionID .. ".log"
    if fs.exists(logFile) then
        local f = fs.open(logFile, "r")
        if f then
            term.clear()
            term.setCursorPos(1, 1)
            print(f.readAll())
            f.close()
        else
            print("Failed to open log file: " .. logFile)
        end
    else
        print("No log file found for this session.")
    end
end

startSession()

log(title)

log("Beginning Alchemy...")

local repo = "https://raw.githubusercontent.com/Catylist0/AlchemyOS/main/"
local idFile = "recipe.lua"
local tmpFile = "__ids.lua"

-- Fetch remote recipe
local res = http.get(repo .. idFile) or error("Failed to fetch " .. idFile)
local f = fs.open(tmpFile, "w")
f.write(res.readAll())
f.close()
res.close()

local launchRecipe = dofile(tmpFile)
fs.delete(tmpFile)

local files = launchRecipe.fileIdentities or error("No file identities found")
local latestVersion = launchRecipe.version or error("No version found")

if type(files) ~= "table" then error("Invalid file list") end

-- Load existing recipe if available
local existingRecipe = fs.exists("/recipe.lua") and dofile("/recipe.lua") or {}
local currentVersion = existingRecipe.version or "0.0.0"

if not existingRecipe.version then
    log("No current recipe version found, defaulting to 0.0.0")
end

log("Local Version: " .. currentVersion)

local shouldUpdate = currentVersion ~= latestVersion
log("New Version Detected: " .. tostring(shouldUpdate))

-- Download updates
if shouldUpdate then
    for _, path in ipairs(files) do
        log("Fetching " .. path)
        local r = http.get(repo .. path)
        if r then
            local dir = fs.getDir(path)
            if dir ~= "" then fs.makeDir(dir) end
            local fh = fs.open(path, "w")
            fh.write(r.readAll())
            fh.close()
            r.close()
        else
            log("Failed: " .. path)
        end
    end
end

sleep(3)
error("end")
