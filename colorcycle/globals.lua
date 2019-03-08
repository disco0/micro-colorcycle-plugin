-- globals.lua
-- show all global variables
globals = function()
    indent = "  "

    fixTable = function (t)
    meta = {__index = table}
    setmetatable(t, meta)
    end

    getTable = function(t,i)
        local seen  = {}   
        local function _dump(t,i)
            seen[t] = true
            local s = {}
            local n = 0
            
            for k in pairs(t) do
                n=n+1 s[n]=k
            end
            table.sort(s)
            for k,v in ipairs(s) do
            -- stack:insert(i .. cnt .. ") " .. v)
                stack:insert(i .. v)
                v=t[v]
                if type(v)=="table" and not seen[v] then
                    _dump(v,i..indent)
                end
            end
        end
        stack = {}
        fixTable(stack) 
        _dump(t,i)
        return stack
    end

    getPrintable = function (t,i)
        t = getTable(t,i)
        concat("\n")
    end
end