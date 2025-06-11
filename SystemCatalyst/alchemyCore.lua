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

function G.fn.printMultiPage(text)
  local p = peripheral.find("printer")
  if not p then G.fn.log("printMultiPage: No printer attached") return false end
  if not pcall(p.newPage, p) then G.fn.log("printMultiPage: newPage failed") return false end

  local w, h = p.getPageSize()
  if type(w) ~= "number" or type(h) ~= "number" then
    G.fn.log("printMultiPage: invalid page size")
    pcall(p.endPage, p)
    return false
  end

  local lines = wrap(text, w)
  for i = 1, #lines, h do
    if i > 1 and not pcall(p.newPage, p) then
      G.fn.log("printMultiPage: newPage failed")
      break
    end
    for y = 1, h do
      local idx = i + y - 1
      if idx > #lines then break end
      pcall(p.setCursorPos, p, 1, y)
      pcall(p.write, p, lines[idx])
    end
    pcall(p.endPage, p)
  end

  return true
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
    local lastWillPath = "SystemFiles/lastWillAndTestament.txt"
    if fs.exists(lastWillPath) then
        local lastWillFile = fs.open(lastWillPath, "r")
        local lastWillContent = lastWillFile.readAll()
        lastWillFile.close()
        G.fn.printMultiPage(lastWillContent)
    else
        G.fn.log("No last will and testament found.")
    end
    sleep(10)
end

return aci
