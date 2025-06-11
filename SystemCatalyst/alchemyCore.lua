local alchemyCore = {}

local aci = alchemyCore

local function printReleaseSplash()
    log("Detected Monitors: " .. #Monitors)
    local endOfBracket = tostring("["..SessionID.."]==")
    local splash = function()
        local consoleWidth, consoleHeight = term.getSize()
        term.clear()
        term.setCursorPos(1, (consoleHeight / 2) - 6)
        local barEq = string.rep("=", consoleWidth)
        local barEqTop = tostring(string.rep("=", consoleWidth - #endOfBracket) .. endOfBracket)
        print(barEqTop)
        log(title)
        print(barEq)
    end

    term.redirect(term.native())
    splash()
    for _, monitor in ipairs(Monitors) do
        term.redirect(monitor)
        splash()
    end
end

function aci.enter()
    print("PEOPLE OF EARTH REJOICE!!!!")
    log("Entering Alchemy Core...")
    log("Alchemy ".. Version)
    printReleaseSplash()
    sleep(1)
    hang(0, "end")
end

return aci