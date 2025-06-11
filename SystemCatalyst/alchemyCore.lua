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

local function wrap(text, width)
  local lines = {}
  for paragraph in text:gmatch("([^\n]*)\n?") do
    if paragraph == "" then
      table.insert(lines, "")
    else
      local current = ""
      for word in paragraph:gmatch("%S+") do
        if #current == 0 then
          if #word <= width then
            current = word
          else
            for i=1,#word,width do
              table.insert(lines, word:sub(i, i+width-1))
            end
            current = ""
          end
        else
          if #current + 1 + #word <= width then
            current = current .. " " .. word
          else
            table.insert(lines, current)
            if #word <= width then
              current = word
            else
              for i=1,#word,width do
                table.insert(lines, word:sub(i, i+width-1))
              end
              current = ""
            end
          end
        end
      end
      if #current > 0 then table.insert(lines, current) end
    end
  end
  return lines
end

local function printMultiPage(text)
  local printer = peripheral.find("printer") or error("No printer attached")
  printer.newPage()
  local w, h = printer.getPageSize()
  local lines = wrap(text, w)
  for i = 1, #lines, h do
    if i > 1 then printer.newPage() end
    for y = 1, h do
      local idx = i + y - 1
      if idx > #lines then break end
      printer.setCursorPos(1, y)
      printer.write(lines[idx])
    end
    printer.endPage()
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
