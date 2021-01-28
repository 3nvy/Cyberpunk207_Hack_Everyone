local Utils = {}

function fileExists(filename)
    local f=io.open(filename,"r") if (f~=nil) then io.close(f) return true else return false end
end

function Utils.GetPath(modName, fileName)
    if fileExists("bin/x64/plugins/cyber_engine_tweaks/mods/"..modName.."/init.lua") then 
		return "bin/x64/plugins/cyber_engine_tweaks/mods/"..modName.."/"..fileName
	elseif fileExists("x64/plugins/cyber_engine_tweaks/mods/"..modName.."/init.lua") then 
		return "x64/plugins/cyber_engine_tweaks/mods/"..modName.."/"..fileName
	elseif fileExists("plugins/cyber_engine_tweaks/mods/"..modName.."/init.lua") then 
		return "plugins/cyber_engine_tweaks/mods/"..modName.."/"..fileName
	elseif fileExists("cyber_engine_tweaks/mods/"..modName.."/init.lua") then 
		return "cyber_engine_tweaks/mods/"..modName.."/"..fileName
	elseif fileExists("mods/"..modName.."/init.lua") then 
		return "mods/"..modName.."/"..fileName
	elseif fileExists(modName.."/init.lua") then 
		return modName.."/"..fileName
	elseif fileExists("init.lua") then 
		return fileName
	end
end

function Utils.LoadConfig(modName, fileName)
    local file = io.open(Utils.GetPath(modName, fileName), "rb")
	if not file then return false end

    local content = file:read "*a" -- *a or *all reads the whole file
	io.close(file)

    return content
end

function Utils.SaveConfig(modName, fileName, data)
	local file = io.open(Utils.GetPath(modName, fileName), "w")

	if file == nil then return false end

	file:write(data)

	io.close(file)
	
	return true
end

function Utils.Log(debugEnabled, modName, message)
	if debugEnabled then
		print("["..modName.."] "..message)
	end
end


return Utils