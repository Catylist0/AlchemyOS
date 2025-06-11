term.clear()
term.setCursorPos(1, 1)
term.setCursorBlink(false)

local G
local ok, err = pcall(function()
    G = require("SystemCatalyst.globals")
end)

if not ok then
    print("Fallingback to default globals due to error: " .. tostring(err))
    sleep(1)
    fs.makeDir("SystemCatalyst")
    local f = fs.open("SystemCatalyst/globals.lua", "w")
    f.write(
    "return { DevMode = false, Version = \"not loaded yet...\", OsDirectory = \"SystemCatalyst\", Monitors = { peripheral.find(\"monitor\") }, fn = {} }")
    f.close()
    G = require("SystemCatalyst.globals")
    print("Default globals loaded.")
end

G.OsDirectory = "SystemCatalyst"

G.Monitors = { peripheral.find("monitor") }

G.DevMode = false -- Set to true to enable developer mode features

G.fn = {}

if G.DevMode then
    print("Starting AlchemyOS Dev Environment...")
end

G.Version = "not loaded yet..."

os.pullEvent = os.pullEventRaw

local hangingToTop = false

G.fn.log = false

function G.hang(code, optionalErrText)
    if log then
        log("Dousing Alchemy: Program hanging at code " .. tostring(code) .. " - " .. tostring(optionalErrText))
    else
        print("Dousing Alchemy: Program hanging at code " .. tostring(code) .. " - " .. tostring(optionalErrText))
    end
    if not optionalErrText then
        optionalErrText = "generic"
    end
    local s = "douse"
    local i = 1
    local formattedCode = string.format("%03d", code)
    if hangingToTop then
        print("SubError of: ")
        error("DousingUp")
    end
    local douseTime = os.clock() + 3 -- + seconds to douse
    while douseTime < os.clock() do
        local _, c = os.pullEvent("char")
        if c == s:sub(i, i) then
            i = i + 1
        elseif c == "d" then
            i = 2
        else
            i = 1
        end
        if i > #s then
            if G.DevMode and not hangingToTop then
                print("Version: " .. tostring(Version))
                hangingToTop = true
                error("Dousing Alchemy: " .. tostring(optionalErrText))
            elseif not G.DevMode then
                term.clear()
                term.setCursorPos(1, 1)
                G.fn.log("Rebooting...")
                os.reboot("Dousing Alchemy.. ")
            end
        end
    end
    G.fn.log("Rebooting...")
    os.reboot()
end

-- Load and run the main initialization script in our own globals
local chunk, loadErr = loadfile(G.OsDirectory .. "/beginTheAlchemy.lua")
if not chunk then
    G.hang(1, "Startup Error loading beginTheAlchemy.lua: " .. tostring(loadErr))
end

-- remove any file from the root that is present in the OsDirectory
local function purgeFalseCatalystFiles()
    local files = fs.list("/")
    for _, file in ipairs(files) do
        if fs.exists(fs.combine(G.OsDirectory, file)) then
            fs.delete(file)
            if G.DevMode then print("Warning Purged false catalyst file: " .. file) end
        end
    end
end

purgeFalseCatalystFiles()

local success, runErr = pcall(function()
    require(G.OsDirectory .. ".beginTheAlchemy")
end)

if not success then
    local msg = (type(runErr) == "string") and runErr or tostring(runErr)
    G.hang(2, "Startup Error: " .. msg)
end
