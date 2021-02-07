local Utils = {}

function Utils.LoadConfig(modName, fileName)
    local file = io.open(fileName, "rb")
	if not file then return false end

    local content = file:read "*a" -- *a or *all reads the whole file
	io.close(file)

    return content
end

function Utils.SaveConfig(modName, fileName, data)
	local file = io.open(fileName, "w")

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