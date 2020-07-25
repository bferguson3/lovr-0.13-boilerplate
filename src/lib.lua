-- taken from LuaUsers
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function include(fileName)
    local m = lovr.filesystem.load(fileName)
    m()
end

-- define DEBUG object 
debug = {
    showFPS = false,
    logFPS = false,
    showFrameDelta = false
}

debug.init = function()
    debug.file = 'debug' .. os.time() .. '.log'
    lovr.filesystem.write(debug.file, '')
end

debug.print = function (tx) 
    lovr.filesystem.append(debug.file, tx .. '\n')
    print(tx)
end
  