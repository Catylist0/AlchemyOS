term.clear()
term.setCursorBlink(false)
term.setCursorPos(1, 1)

os.pullEvent = os.pullEventRaw

function hang(startupError, optionalErrText)
    if not optionalErrText then
        optionalErrText = "generic"
    end
    local s = "douse" i = 1
    print("Startup Error " .. tostring(startupError))
    while true do
        _,c = os.pullEvent("char")
        i = (c == s:sub(i, i)) and i + 1 or (c == "d" and 2 or 1)
        if i > #s then return error("Dousing Alchemy: " .. tostring(optionalErrText)) end
    end
end

local file = fs.open("/beginTheAlchemy.lua", "r")

if not file then
    hang(1, "initialization file not found")
end

local code = file.readAll()
file.close()

local fn = loadstring(code, "osExecute.lua")
if not fn then
    hang(2, "failed to load initialization code")
end

local ok, err = pcall(fn)
if not ok then
    if type(err) == "string" then
        hang(3, err)
    else
        hang(3, "unknown error: " .. tostring(err))
    end
end
