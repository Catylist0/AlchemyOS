term.clear()
term.setCursorBlink(false)
term.setCursorPos(1, 1)

DevMode = true

os.pullEvent = os.pullEventRaw

function hang(code, optionalErrText)
    if not optionalErrText then
        optionalErrText = "generic"
    end
    local s = "douse" i = 1
    local formattedCode = string.format("%02d", code)
    print("Error Code: " .. formattedCode)
    while true do
        _,c = os.pullEvent("char")
        i = (c == s:sub(i, i)) and i + 1 or (c == "d" and 2 or 1)
        if i > #s and DevMode then return error("Dousing Alchemy: " .. tostring(optionalErrText)) end
    end
end

local file = fs.open("/beginTheAlchemy.lua", "r")

if not file then
    hang(1, "Startup Error: initialization file not found")
end

local code = file.readAll()
file.close()

local fn = loadstring(code, "beginTheAlchemy.lua")
if not fn then
    hang(2, "Startup Error: failed to load initialization code")
end

local ok, err = pcall(fn)
if not ok then
    if type(err) == "string" then
        hang(3, "Startup Error: " .. err)
    else
        hang(3, "Startup Error: unknown error: " .. tostring(err))
    end
end
