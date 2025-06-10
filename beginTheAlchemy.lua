local title = [[
    _    _      _                          TM
   / \  | | ___| |__   ___ _ __ ___  _   _ 
  / _ \ | |/ __| '_ \ / _ \ '_ ` _ \| | | |
 / ___ \| | (__| | | |  __/ | | | | | |_| |
/_/   \_\_|\___|_| |_|\___|_| |_| |_|\__, |
                                     |___/ 
A ComputerCraft Operating System.

By Cauldron Microsystems:
Subsidiary of Catylist Electrochemical

All rights reserved.
]]

local consoleWidth, consoleHeight = term.getSize()

if DevMode == nil then
    hang(3, "SystemVar 'DevMode' is not set or accessible.")
end

-- Better pseudo-entropy without HTTP
local t = os.time()
local c = os.clock()
local seed = math.floor((t * 1000) + (c * 100000)) % 2^31
math.randomseed(seed)

-- Optional: warm it up
for _ = 1, 3 do math.random() end

local function randomHash()
    return string.format("%08x", math.random(0, 0xFFFFFFFF))
end

SessionID = randomHash()

function log(msg)
    local logFile = "logs/" .. SessionID .. ".log"
    local f = fs.open(logFile, "a")
    if f then
        f.writeLine(textutils.formatTime(os.time(), true) .. " - " .. msg)
        if DevMode then print(msg) end
        f.close()
    else
        hang(4, "Failed to open log file: " .. logFile)
    end
end

local function startSession()
    if not fs.isDir("logs") then
        fs.makeDir("logs")
    end
    local logFile = "logs/" .. SessionID .. ".log"
    local f = fs.open(logFile, "w")
    f.close()
    log("Session started: " .. SessionID)
    log("Disk Space remaining: " .. fs.getFreeSpace("/") .. " bytes")
    log("Current Logs:")
    local logFiles = fs.list("logs")
    for _, file in ipairs(logFiles) do
        if file:match("^%d+%.log$") then
            if file == SessionID .. ".log" then
                log(" - " .. file .. " (current session)")
            else
                log(" - " .. file)
            end
        end
    end
end

function printLogs()
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
local barEq = string.rep("=", consoleWidth)
if DevMode then
    print(barEq)
    log(title)
    print(barEq)
    sleep(1)
else
    log(title)
end
log("Beginning Alchemy...")

local function enterAlchemy()
    sleep(3)
    hang(0, "ending")
end

local repo     = "https://raw.githubusercontent.com/Catylist0/AlchemyOS/main/"
local idFile   = "recipe.lua"
local tmpFile  = "__ids.lua"

-- Helper: create nested directories
local function ensureDir(path)
    local cur = ""
    for part in path:gmatch("([^/]+)") do
        cur = cur .. part
        if not fs.isDir(cur) then fs.makeDir(cur) end
        cur = cur .. "/"
    end
end

-- Load existing recipe if available
local existingRecipe = {}
if fs.exists("/recipe.lua") then
    local success, tbl = pcall(dofile, "/recipe.lua")
    if success and type(tbl) == "table" then
        existingRecipe = tbl
    else
        log("Failed to load existing recipe, defaulting to empty")
    end
end

local currentVersion = existingRecipe.version or "0.0.0"
if not existingRecipe.version then
    log("No current recipe version found, defaulting to 0.0.0")
end

Version = currentVersion  -- Set global Version variable

if not http then
    log("HTTP API is disabled")
    return enterAlchemy()
end

-- Fetch and parse remote recipe safely
local res = http.get(repo .. idFile) or error("Failed to fetch " .. idFile)
local f   = fs.open(tmpFile, "w")
f.write(res.readAll()); f.close(); res.close()

local ok, launchRecipe = pcall(dofile, tmpFile)
fs.delete(tmpFile)  -- always clean up

if not ok then
    error("Failed to parse " .. tmpFile)
end

local files         = launchRecipe.fileIdentities or error("No file identities found")
local latestVersion = launchRecipe.version or error("No version found")

if type(files) ~= "table" then error("Invalid file list") end

log("Local Version: " .. currentVersion)

local shouldUpdate = currentVersion ~= latestVersion
if shouldUpdate then log("New Version Detected: " .. tostring(latestVersion)) end

-- check if the version ends in a lowercase d
local isDevVersion = latestVersion:sub(-1) == "d"

if isDevVersion then
    log("Warning: This is a development version")
end

local function pullAlchemyUpdates()
    log("pulling updates...")
    for _, path in ipairs(files) do
        log("Fetching " .. path)
        local r = http.get(repo .. path)
        if r then
            local dir = fs.getDir(path)
            if dir ~= "" then ensureDir(dir) end
            local fh = fs.open(path, "w")
            fh.write(r.readAll())
            fh.close()
            r.close()
        else
            log("Failed: " .. path)
        end
    end
end

-- Download updates
if shouldUpdate or isDevVersion then
    pullAlchemyUpdates()
end

currentVersion = latestVersion
Version = currentVersion  -- Update global Version variable just in case

log("New Version: " .. tostring(currentVersion))

enterAlchemy()
