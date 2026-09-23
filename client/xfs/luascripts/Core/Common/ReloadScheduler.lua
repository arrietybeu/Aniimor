-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\ReloadScheduler.lua

local reload = require("Core.Framework.Reload")
local LoggerManager = require("Core.Log.LoggerManager")
local EntityFactory = require("Core.Common.EntityFactory")
local class = require("Core.Framework.Class")
local Switch = require("Core.Common.Switch")
local ReloadScheduler = class.Class("ReloadScheduler")
local _LOGGER = LoggerManager.getLogger("Reload")

function ReloadScheduler:ctor()
	self.preReloadHook = nil
	self.postReloadHook = nil
	self.exceptionHook = nil
end

function ReloadScheduler:setPreReloadHook(preReloadHook)
	self.preReloadHook = preReloadHook
end

function ReloadScheduler:setPostReloadHook(postReloadHook)
	self.postReloadHook = postReloadHook
end

function ReloadScheduler:setReloadExceptionHook(reloadExceptionHook)
	self.exceptionHook = reloadExceptionHook
end

function ReloadScheduler:startReload(reloadType, files, impFiles, delKeyModels, debug)
	if self.preReloadHook then
		_LOGGER:info("ReloadScheduler pre reload")
		self.preReloadHook(reloadType)
	end

	_LOGGER:info("ReloadScheduler start")

	reload.postfix = ""

	if debug then
		reload.print = print
	end

	reload.initEnv({
		loggerGenerateFunc = LoggerManager.getLogger,
		isRpcMethodFunc = EntityFactory.isRpcMethod
	})
	class.setReload(true, reloadType == "data")

	pg.isReloading = true

	local r = {}

	for _, file in ipairs(files) do
		file = string.gsub(file, "/", ".")

		_LOGGER:info("start reload file %s", file)
		table.insert(r, string.sub(file, 1, string.len(file) - 4))
	end

	local ok, result = reload.reload(r, impFiles, delKeyModels)

	if not ok then
		_LOGGER:error("ReloadScheduler failed: %s", result)

		if self.exceptionHook then
			self.exceptionHook(result)
		end
	end

	if pg.component == "client" and not Switch.ReadLuaData and (reloadType == "all" or reloadType == "data") then
		local BddDataMgr = require("Core.Framework.BddDataMgr")

		BddDataMgr.GetInstance():init()
	end

	class.setReload(false, reloadType == "data")

	pg.isReloading = nil

	if self.postReloadHook then
		_LOGGER:info("ReloadScheduler post reload")

		if ok then
			self.postReloadHook(reloadType, result)
		else
			self.postReloadHook(reloadType)
		end
	end

	_LOGGER:info("ReloadScheduler end")
end

function ReloadScheduler.reloadRecentFiles()
	local ReloadFilter = require("Common.ReloadFilter")
	local File = require("Core.Common.File")
	local cutoffTime = pg.lastReloadTime
	local currentPath

	currentPath = pg.component == "client" and LUA_ROOT_PATH or require("Core.Server.GameServerRepo").srcPath

	local files = {}

	File.walkDirRecent(currentPath, files, "lua", cutoffTime)

	local res = {}

	for _, v in ipairs(files) do
		local filePath = string.gsub(v, string.format("%s/", currentPath), "")
		local needIgnore = false

		for _, rule in pairs(ReloadFilter.ignoreModules) do
			if string.find(filePath, rule) then
				needIgnore = true

				break
			end
		end

		if not needIgnore then
			table.insert(res, filePath)
			_LOGGER:info("reloadRecentFiles reload: %s", filePath)
		end
	end

	if #res == 0 then
		_LOGGER:info("reloadRecentFiles: no files modified since last reload")

		return
	end

	_LOGGER:info("reloadRecentFiles: found %d modified files since last reload", #res)

	local CommonRepo = require("Core.Common.CommonRepo")

	CommonRepo.reloadScheduler:startReload("recent", res, ReloadFilter.impFiles, ReloadFilter.deleteKeyModels, false)

	pg.lastReloadTime = os.time()
end

return ReloadScheduler
