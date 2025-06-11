local alchemyCore = {}

local aci = alchemyCore

local G = require "SystemCatalyst.globals"

G.fn = G.fn or {}

local function printReleaseSplash()
    G.fn.log("Detected Monitors: " .. #G.Monitors)
    local endOfBracket = tostring("[" .. G.SessionID .. "]==")
    local endOfLowerBracket = tostring("[" .. G.Version .. "]==")
    local splash = function()
        local consoleWidth, consoleHeight = term.getSize()
        term.clear()
        term.setCursorPos(1, (consoleHeight / 2) - 6)
        local barEqTop = tostring(string.rep("=", consoleWidth - #endOfBracket) .. endOfBracket)
        local barEqBottom = tostring(string.rep("=", consoleWidth - #endOfLowerBracket) .. endOfLowerBracket)
        print(barEqTop)
        print(tostring(G.TitleSplashBare))
        print(barEqBottom)
    end

    term.redirect(term.native())
    splash()
    for _, monitor in ipairs(G.Monitors) do
        term.redirect(monitor)
        splash()
    end
    term.redirect(term.native())
end

function aci.enter()
    G.fn.log("Entering Alchemy Core...")
    G.fn.log("Alchemy " .. tostring(G.Version))
    printReleaseSplash()
    sleep(1)
    term.redirect(term.native())
    term.clear()
    term.setCursorPos(1, 1)
    G.printLogs()
end

return aci
