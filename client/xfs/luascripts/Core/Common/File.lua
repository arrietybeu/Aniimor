-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\File.lua

local lfs = require("lfs")
local platform = require("Core.Common.Platform")
local stringEx = require("Core.Framework.String")
local File = {}

function File.walkDir(path, files, postfix)
	assert(lfs.attributes(path, "mode") == "directory")

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path .. "/" .. file
			local attr = lfs.attributes(f)

			if attr.mode == "directory" then
				File.walkDir(f, files, postfix)
			elseif attr.mode == "file" and (postfix == nil or string.sub(f, -string.len(postfix)) == postfix) then
				table.insert(files, f)
			end
		end
	end
end

function File.walkDirRecent(path, files, postfix, cutoffTime)
	assert(lfs.attributes(path, "mode") == "directory")

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path .. "/" .. file
			local attr = lfs.attributes(f)

			if attr.mode == "directory" then
				File.walkDirRecent(f, files, postfix, cutoffTime)
			elseif attr.mode == "file" and (postfix == nil or string.sub(f, -string.len(postfix)) == postfix) and cutoffTime <= attr.modification then
				table.insert(files, f)
			end
		end
	end
end

function File.joinPath(root, cur)
	local newRoot = root
	local newCur = cur

	if not stringEx.endswith(root, "/") and not stringEx.endswith(root, "\\") then
		newRoot = newRoot .. "/"
	end

	if not stringEx.endswith(cur, "/") and not stringEx.endswith(cur, "\\") then
		newCur = newCur .. "/"
	end

	return newRoot .. newCur
end

function File.writePath(path, content, compress)
	local fileWrite, err = io.open(path, "w+")

	fileWrite:write(content)
	fileWrite:close()
end

function File.readFile(path)
	local f = assert(io.open(path, "r"))
	local s = f:read("*a")

	f:close()

	return s
end

return File
