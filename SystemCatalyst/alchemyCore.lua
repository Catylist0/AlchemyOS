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

local function printMultiPage(text)
    local printer = peripheral.find("printer")
    if not printer then error("No printer found") end
    local w, h = printer.getPageSize()   -- width,height :contentReference[oaicite:0]{index=0}
    local lines = cc.strings.wrap(text, w) -- wrap text to page width :contentReference[oaicite:1]{index=1}
    for i = 1, #lines, h do
        printer.newPage()                -- start a new page :contentReference[oaicite:2]{index=2}
        for y = 1, h do
            local idx = i + y - 1
            if idx > #lines then break end
            printer.setCursorPos(1, y) -- position cursor on line y :contentReference[oaicite:3]{index=3}
            printer.write(lines[idx]) -- print the line :contentReference[oaicite:4]{index=4}
        end
        printer.endPage()        -- finish and output page :contentReference[oaicite:5]{index=5}
    end
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
    sleep(0.5)
    -- open the systemfile lastWillAndTestament.lua
    local lastWillPath = "SystemFiles/lastWillAndTestament.lua"
    if fs.exists(lastWillPath) then
        local lastWillFile = fs.open(lastWillPath, "r")
        local lastWillContent = lastWillFile.readAll()
        lastWillFile.close()
        printMultiPage(lastWillContent)
    else
        G.fn.log("No last will and testament found.")
    end
    sleep(10)
end

return aci
