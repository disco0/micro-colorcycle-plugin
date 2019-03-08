--[[
     ███▄ ▄███▓ ██▓ ▄████▄   ██▀███   ▒█████
    ▓██▒▀█▀ ██▒▓██▒▒██▀ ▀█  ▓██ ▒ ██▒▒██▒  ██  █░      █    █   ▓████▄
    ▓██    ▓██░▒██▒▒▓█    ▄ ▓██ ░▄█ ▒▒██░  ██ ░██░    ▒██   █▓  ██▀ ▀█▓
    ▒██    ▒██ ░██░▒▓▓▄ ▄██▒▒██▀▀█▄  ▒██   ██ ░██░     ██  ▒██ ░██▄▄▄██
    ▒██▒   ░██▒░██░▒ ▓███▀ ░░██▓ ▒██▒░ ████▓▒░░██░░▒   ▓█  ░██ ░██   ██▒
    ░ ▒░   ░  ░░▓  ░ ░▒ ▒  ░░ ▒▓ ░▒▓░░ ▒░▒░▒░ ░▒████▒  █████▓▒▒▒▀█▄  ▀█░░
    ░  ░      ░ ▒ ░  ░  ▒     ░▒ ░ ▒░  ░ ▒ ▒░  ░ ░ ░▒░ ▒▓▒ ▒▒░ ▒ ░░▒  ▒ ░
│▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▏
│     micro-colorcycle-plugin.lua => Cycle through micro colorschemes         ▏
│                                                                             ▏
╞══════════════════════════════════════════════════════════════════════════]]--

--------------------------
--- VARS ------------------------------------------
----------------------------------------------------------------------------

VERSION = "0.2"
cwd     = WorkingDirectory()
isWin   = (OS == "windows")
tick    = 0

local os      = import("os")
local ioutil  = import("io/ioutil")
local fmt     = import("fmt")
local time    = import("time")

--------------------------
--- FUNC ------------------------------------------
----------------------------------------------------------------------------

 -- TODO: Finish writing code for getting posistion of current colorscheme
       -- so keeping the index isn't necessary
 -- TODO: Add reverse traversal of colorscheme list
function cyclecolorscheme()
    local list          = getColorschemes()
    local curr          = getCurrentColorscheme()
    local readout_name  = ""

    tick         = tick + 1
    i            = tick % #list + 1
    readout_name = list[i]
    cmd          = 'set colorscheme ' .. list[i]:gsub(".micro", "")

    HandleCommand(cmd)
    HandleCommand("show colorscheme")
end


function getCurrentColorscheme()
    local  name = GetOption('colorscheme')
    return name
end


function logCurrentColorscheme()
    local c = getCurrentColorscheme()
    message:LogAdd(c[#c])
end


function getColorschemes()
  --TODO: Store whether the colorscheme is from builtin or a local file path,
       -- or even full path info—to prioritize/preserve nonbuiltin colorschemes
  --- vars
    -- colorschemes = sm:concat(su):concat(sr:gsub(".micro", "")):unique:sort
    local sm = {}
    local sr = ListRuntimeFiles( "colorscheme" )     -- builtin colorschemes
    local su = scanDir(configDir .. '/colorschemes') -- cfg path colorschemes

  --- func
    for i = 1, #sr do sm[i]       =   sr[i]                      end
    for i = 1, #su do sm[#sm + 1] = ( su[i]:gsub(".micro", "") ) end
    colorschemes = getunique(sm)
    table.sort( colorschemes, function( a, b ) return a < b end )
    return colorschemes
end


function logColorschemes()
    local l = getColorschemes()
    messenger:AddLog( "\t" .. table.concat( l, "\n\t" ) )
end


function getunique(t)
    local t_ret  = {}
    local t_hash = {}
    for _, v in ipairs(t) do
        if not t_hash[v] then
            t_ret[#t_ret+1] = v
            t_hash[v]       = true
        end
    end
    return t_ret
end


function scanDir(directory)
	-- Gets a list of all the files in the current dir
	local list    = {}
	local readout = ioutil.ReadDir(directory)
	if readout == nil then
		messenger:Error("Error reading directory: ", directory)
	else
		local readout_name = ""
		-- Loop through all the files/directories in current dir
		for i = 1, #readout do
            -- Save the current dir/file name
            readout_name = readout[i]:Name()
            if isDir(readout_name) then         -- Check if dir
                -- Append slash to directories
                readout_name = readout_name .. "/"
		    end
            table.insert(list, readout_name)   -- Add to table of child items in dir
		end
	end
	return list
end


function isDir(path)
    local check_path = JoinPaths(cwd, path)

	local file_info = os.Stat(check_path)
	if file_info ~= nil then
		-- Returns the true/false of if the file is a directory
		return file_info:IsDir()
	else
		return nil
	end
end


function logger(msg, view)
    messenger:AddLog(("colorparty <%s>: %s"):
        format(view.Buf.GetName(view.Buf), msg))
end


function msg(msg, view)
    messenger:Message(("EditorConfig <%s>: %s"):
        format(view.Buf.GetName(view.Buf), msg))
end


function setSafely(key, value, view)
    if value == nil then    -- logger(("Ignore nil for %s"):format(key), view)
    else
        logger(("Set %s = %s"):format(key, value), view)
        SetLocalOption(key, value, view)
    end
end


function fixTable(t)
    meta = {__index = table}
    setmetatable(t, meta)
end


function getGlobalTable(t,i)
    local seen = {}
    stack      = {}
    indent     = "\t"
    fixTable(stack)
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
            --print(i .. v)
            stack:insert(i .. v)
            v=t[v]
            if type(v)=="table" and not seen[v] then
                _dump(v,i..indent)
            end
        end
    end
    _dump(t,i)
    return stack
end


function getGlobalPrintable(t,i)
    t = getGlobalTable(t,i)
    return t:concat("\n")
end


function logGlobals()
    HandleCommand("log")
    t = getGlobalPrintable(_G, "")
    messenger:AddLog( "Globals: \n" .. t  )
end

-- Main Command
MakeCommand( "cyclecolorscheme" , "colorparty.partytime"  )
-- Utility
MakeCommand( "logGlobals"       , "colorparty.logGlobals" )


AddRuntimeFile( "colorparty" , "help", "help/colorparty.md" )
