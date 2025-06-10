term.clear()
term.setCursorPos(1, 1)
term.setCursorBlink(false)

local monitors = { peripheral.find("monitor") }

if #monitors > 0 then
    print(monitors[1])
    term.redirect(peripheral.wrap(monitors[1]))
end

DevMode = true -- Set to true to enable developer mode features

if DevMode then
    print("Starting AlchemyOS Dev Environment...")
end

Version = "not loaded yet..."

os.pullEvent = os.pullEventRaw

local hangingToTop = false

function hang(code, optionalErrText)
    if not optionalErrText then
        optionalErrText = "generic"
    end
    local s = "douse" i = 1
    local formattedCode = string.format("%03d", code)
    if hangingToTop then
        print("SubError of: ")
        error("DousingUp")
    end
    while true do
        local _, c = os.pullEvent("char")
        if c == s:sub(i, i) then
            i = i + 1
        elseif c == "d" then
            i = 2
        else
            i = 1
        end
        if ((i > #s) or hangingToTop) and DevMode and not hangingToTop then
            print("Version: " .. tostring(Version))
            hangingToTop = true
            error("Dousing Alchemy: " .. tostring(optionalErrText))
        end
    end
end

local OsDirectory = "SystemCatalyst"

-- Load and run the main initialization script in our own globals
local chunk, loadErr = loadfile(OsDirectory .. "/beginTheAlchemy.lua")
if not chunk then
    hang(1, "Startup Error loading beginTheAlchemy.lua: "..tostring(loadErr))
end

-- remove any file from the root that is present in the OsDirectory
local function purgeFalseCatalystFiles()
    local files = fs.list("/")
    for _, file in ipairs(files) do
        if fs.exists(fs.combine(OsDirectory, file)) then
            fs.delete(file)
            if DevMode then print("Warning Purged false catalyst file: " .. file) end
        end
    end
end

purgeFalseCatalystFiles()

-- Lua 5.1: copy our environment (_G) into the chunk
setfenv(chunk, getfenv())

-- run it
local ok, runErr = pcall(chunk)
if not ok then
    local msg = (type(runErr) == "string") and runErr or tostring(runErr)
    hang(2, "Startup Error: "..msg)
end

