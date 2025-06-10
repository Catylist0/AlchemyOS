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
        local _, c = os.pullEvent("char")
        if c == s:sub(i, i) then
            i = i + 1
        elseif c == "d" then
            i = 2
        else
            i = 1
        end
        if i > #s and DevMode then
            return error("Dousing Alchemy: " .. tostring(optionalErrText))
        end
    end
end

-- Load and run the main initialization script in the current environment
local ok, err = pcall(dofile, "/beginTheAlchemy.lua")
if not ok then
    local msg = (type(err) == "string") and err or tostring(err)
    hang(1, "Startup Error: " .. msg)
end
