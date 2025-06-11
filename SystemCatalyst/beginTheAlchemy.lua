local title = [[
    _    _      _                          TM
   / \  | | ___| |__   ___ _ __ ___  _   _
  / _ \ | |/ __| '_ \ / _ \ '_ ` _ \| | | |
 / ___ \| | (__| | | |  __/ | | | | | |_| |
/_/   \_\_|\___|_| |_|\___|_| |_| |_|\__, |
                                     |___/
A ComputerCraft Operating System.

By Catylist MicroElectric
Subsidiary of Catylist Electrochemical

All rights reserved.
]]
local G = require("SystemCatalyst.globals")
G.TitleSplashBare = title

local consoleWidth, consoleHeight = term.getSize()

if G.DevMode == nil then
    G.hang(3, "SystemVar 'DevMode' is not set or accessible.")
end

-- Better pseudo-entropy without HTTP
local t = os.time()
local c = os.clock()
local seed = math.floor((t * 1000) + (c * 100000)) % 2 ^ 31
math.randomseed(seed)

-- Optional: warm it up
for _ = 1, 3 do math.random() end

local function randomHash()
    return string.format("%08x", math.random(0, 0xFFFFFFFF))
end

G.SessionID = randomHash()

local endOfBracket = tostring("[" .. G.SessionID .. "]==")

function G.fn.log(msg)
    local logFile = "logs/" .. G.SessionID .. ".log"
    local f = fs.open(logFile, "a")
    if f then
        f.writeLine(textutils.formatTime(os.time(), true) .. " - " .. msg)
        if G.DevMode then print(msg) end
        f.close()
    else
        G.hang(4, "Failed to open log file: " .. logFile)
    end
end

local filesCounted = 0

-- Recursively get total size (in bytes) of a directory
local function getDirSize(path)
    local total = 0
    for _, name in ipairs(fs.list(path)) do
        local full = fs.combine(path, name)
        if fs.isDir(full) then
            total = total + getDirSize(full)
        else
            total = total + fs.getSize(full)
            G.fn.log("Size of " .. full .. ": " .. fs.getSize(full) .. " bytes")
            filesCounted = filesCounted + 1
        end
    end
    return total
end

-- Returns size of "/" in kilobytes, skipping /rom
local function getRootSizeKB()
    filesCounted = 0
    local totalBytes = 0
    for _, name in ipairs(fs.list("/")) do
        if name ~= "rom" then
            local full = fs.combine("/", name)
            if fs.isDir(full) then
                totalBytes = totalBytes + getDirSize(full)
            else
                totalBytes = totalBytes + fs.getSize(full)
                G.fn.log("Size of " .. full .. ": " .. fs.getSize(full) .. " bytes")
                filesCounted = filesCounted + 1
            end
        end
    end
    G.fn.log("Total size of Root: " .. totalBytes .. " bytes " .. "(" .. filesCounted .. " files)")
    return math.floor(totalBytes / 1024)
end

local function startSession()
    if not fs.isDir("logs") then
        fs.makeDir("logs")
    end
    local logFile = "logs/" .. G.SessionID .. ".log"
    local f = fs.open(logFile, "w")
    f.close()
    G.fn.log("Session started: " .. G.SessionID)
    local freeSpaceKB = math.floor(fs.getFreeSpace("/") / 1024)
    local osSizeKB = getRootSizeKB()
    local totalKB = freeSpaceKB + osSizeKB
    local percentFree = math.floor(freeSpaceKB / totalKB * 100)
    G.fn.log("Disk Space remaining: " .. freeSpaceKB .. " KB (" .. percentFree .. "% of disk free)")
    G.fn.log("ALchemy Size: " .. osSizeKB .. " KB")
    local logFiles = fs.list("logs")
    G.fn.log("Current Logs (" .. #logFiles .. "):")
    for _, file in ipairs(logFiles) do
        if file:match("^[0-9a-f]+%.log$") then
            if file == G.SessionID .. ".log" then
                G.fn.log(" - " .. file .. " (current session)")
            else
                G.fn.log(" - " .. file)
            end
        end
    end
end

function G.printLogs()
    local logFile = "logs/" .. G.SessionID .. ".log"
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

local function clearLogFolder()
    if fs.isDir("logs") then
        local logFiles = fs.list("logs")
        for _, file in ipairs(logFiles) do
            -- exlude current session log
            if file == G.SessionID .. ".log" then

            elseif file:match("^[0-9a-f]+%.log$") then
                fs.delete(fs.combine("logs", file))
            end
        end
        G.fn.log("All logs cleared.")
    else
        G.fn.log("No logs directory found.")
    end
end

startSession()

if G.DevMode then
    G.fn.log("Detected Monitors: " .. #Monitors)
    if #Monitors > 0 then
        G.fn.log("Redirecting to monitor: " .. tostring(Monitors[1]))
        term.redirect(Monitors[1])
        consoleWidth, consoleHeight = term.getSize(Monitors[1])
    end
    term.clear()
    term.setCursorPos(1, (consoleHeight / 2) - 6)
    local barEq = string.rep("=", consoleWidth)
    local barEqTop = tostring(string.rep("=", consoleWidth - #endOfBracket) .. endOfBracket)
    print(barEqTop)
    G.fn.log(title)
    print(barEq)
    if #Monitors > 0 then
        term.redirect(term.native())
        G.fn.log("Redirected back to terminal.")
    end
else
    G.fn.log(title)
end
G.fn.log("Beginning Alchemy...")

local function logAllGlobals()
    G.fn.log("Logging top Level Globals:")
    local function formatGlobalPrint(k, v)
        if type(v) == "table" then
            G.fn.log("G: "..string.format("%s: { ... }", k))
        elseif type(v) == "function" then
            G.fn.log("G: "..string.format("%s: function()", k))
        elseif type(v) == "string" then
            G.fn.log("G: "..string.format("%s: \"%s\"", k, v))
        else
            G.fn.log("G: "..string.format("%s: %s", k, tostring(v)))
        end
    end
    for k, v in pairs(G) do
        formatGlobalPrint(k, v)
    end
    G.fn.log("global functions:")
    for k, v in pairs(G.fn) do
        formatGlobalPrint(k, v)
    end
end

local function cullSystemCatalyst()
    local recognizedCatalystFiles = {}
    for _, file in ipairs(G.Recipe.fileIdentities or {}) do
        local filename = string.match(file, "([^/]+)$")
        if filename then
            recognizedCatalystFiles[filename] = true
        end
    end
    local filesInCatalyst = fs.list("SystemCatalyst")
    for _, file in ipairs(filesInCatalyst) do
        if not recognizedCatalystFiles[file] then
            local fullPath = fs.combine("SystemCatalyst", file)
            if G.Recipe.localOnlyFiles[fullPath] then
                G.fn.log("Skipping local-only file: " .. file)
                goto continue
            end
            if fs.isDir(fullPath) then
                fs.delete(fullPath) -- delete directory and contents
                G.fn.log("Deleted unrecognized directory: " .. fullPath)
            else
                fs.delete(fullPath) -- delete file
                G.fn.log("Deleted unrecognized file: " .. fullPath)
            end
            ::continue::
        end
    end
end

local function enterAlchemy()
    logAllGlobals()
    clearLogFolder()
    cullSystemCatalyst()
    local alchemyCore = require "SystemCatalyst.alchemyCore"
    if type(alchemyCore) ~= "table" or not alchemyCore.enter then
        G.fn.log("Failed to load alchemyCore module")
        return G.hang(5, "Failed to load alchemyCore module")
    end
    alchemyCore.enter()
    G.fn.log("FATAL ERROR: Alchemy Core Crashed!")
    sleep(1)
    os.shutdown("Dousing Alchemy: Alchemy Core Crashed!")
end

local repo    = "https://raw.githubusercontent.com/Catylist0/AlchemyOS/main/"
local idFile  = "recipe.lua"
local tmpFile = "__ids.lua"

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
        G.fn.log("Failed to load existing recipe, defaulting to empty")
    end
end

local currentVersion = existingRecipe.version or "0.0.0"
if not existingRecipe.version then
    G.fn.log("No current recipe version found, defaulting to 0.0.0")
end

G.Version = currentVersion -- Set global Version variable
G.Recipe = existingRecipe -- Store the existing recipe globally

if not http then
    G.fn.log("HTTP API is disabled")
    return enterAlchemy()
end

-- Fetch and parse remote recipe safely
local res = http.get(repo .. idFile) or error("Failed to fetch " .. idFile)
local f   = fs.open(tmpFile, "w")
f.write(res.readAll()); f.close(); res.close()

local ok, launchRecipe = pcall(dofile, tmpFile)
fs.delete(tmpFile) -- always clean up

if not ok then
    error("Failed to parse " .. tmpFile)
end

G.Recipe = launchRecipe -- New recipe is now the global recipe

local files         = launchRecipe.fileIdentities or error("No file identities found")
local latestVersion = launchRecipe.version or error("No version found")

if type(files) ~= "table" then error("Invalid file list") end

G.fn.log("Local Version: " .. currentVersion)

local shouldUpdate = currentVersion ~= latestVersion
if shouldUpdate then G.fn.log("New Version Detected: " .. tostring(latestVersion)) end

-- check if the version ends in a lowercase d
local isDevVersion = latestVersion:sub(-1) == "d"

if isDevVersion then
    G.fn.log("Warning: This is a development version")
end

local function pullAlchemyUpdates()
    G.fn.log("pulling updates...")
    --print("updating...")
    for _, path in ipairs(files) do
        G.fn.log("Fetching " .. path)
        local r = http.get(repo .. path)
        if r then
            local dir = fs.getDir(path)
            if dir ~= "" then ensureDir(dir) end
            local fh = fs.open(path, "w")
            fh.write(r.readAll())
            fh.close()
            r.close()
        else
            G.fn.log("Failed: " .. path)
        end
    end
end

-- Download updates
if shouldUpdate or isDevVersion then
    pullAlchemyUpdates()
end

currentVersion = latestVersion
G.Version = currentVersion -- Update global Version variable just in case

G.fn.log("New Version: " .. tostring(currentVersion))

enterAlchemy()
