local alchemyCore = {}

local aci = alchemyCore

local G = require "SystemCatalyst.globals"

local function printReleaseSplash()
    G.log("Detected Monitors: " .. #G.Monitors)
    local endOfBracket = tostring("["..G.SessionID.."]==")
    local endOfLowerBracket = tostring("["..G.Version.."]====")
    local splash = function()
        local consoleWidth, consoleHeight = term.getSize()
        term.clear()
        term.setCursorPos(1, (consoleHeight / 2) - 6)
        local barEqTop = tostring(string.rep("=", consoleWidth - #endOfBracket) .. endOfBracket)
        local barEqBottom = tostring(string.rep("=", consoleWidth - #endOfLowerBracket) .. endOfLowerBracket)
        print(barEqTop)
        G.log(_G.TitleSplashBare)
        print(barEqBottom)
    end

    term.redirect(term.native())
    splash()
    for _, monitor in ipairs(G.Monitors) do
        term.redirect(monitor)
        splash()
    end
end

function aci.enter()
    print("PEOPLE OF EARTH REJOICE!!!!")
    G.log("Entering Alchemy Core...")
    G.log("Alchemy ".. G.Version)
    sleep(1)
    printReleaseSplash()
    sleep(3)
    os.shutdown()
end

return aci