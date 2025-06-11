local alchemyCore = {}

local aci = alchemyCore

local function printReleaseSplash()
    log("Detected Monitors: " .. #Monitors)
    local endOfBracket = tostring("["..SessionID.."]==")
    local endOfLowerBracket = tostring("["..Version.."]====")
    local splash = function()
        local consoleWidth, consoleHeight = term.getSize()
        term.clear()
        term.setCursorPos(1, (consoleHeight / 2) - 6)
        local barEq = string.rep("=", consoleWidth)
        local barEqTop = tostring(string.rep("=", consoleWidth - #endOfBracket) .. endOfBracket)
        local barEqBottom = tostring(string.rep("=", consoleWidth - #endOfLowerBracket) .. endOfLowerBracket)
        print(barEqTop)
        log(TitleSplashBare)
        print(barEqBottom)
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
    local ok, err = pcall(printReleaseSplash())
    if not ok then
        log("Error during splash: " .. tostring(err))
        print("Error during splash: " .. tostring(err))
    end
    sleep(3)
    os.shutdown()
end

return aci