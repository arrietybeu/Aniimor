-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceArkScreenComponent.lua

local class = require("Core.Framework.Class")
local SandboxConst = require("Common.Const.SandboxConst")
local ClientSpaceArkScreenComponent = class.Component("ClientSpaceArkScreenComponent")

function ClientSpaceArkScreenComponent:ctor()
	return
end

function ClientSpaceArkScreenComponent:start()
	return
end

function ClientSpaceArkScreenComponent:on_arkScreenInfoMap_changed(oldValue, newValue, screenId)
	return
end

function ClientSpaceArkScreenComponent:RPC_SC_SyncArkScreenInfo(screenInfo)
	if not pg.me or not pg.me.arkScreenInfoMap then
		return
	end

	for screenId, info in pairs(screenInfo) do
		pg.me.arkScreenInfoMap[screenId] = info

		if self._screenRefreshCallback then
			for callback, _ in pairs(self._screenRefreshCallback) do
				callback(screenId, info.contentId)
			end
		end
	end
end

function ClientSpaceArkScreenComponent:registerScreenRefreshCallback(callback)
	if not self._screenRefreshCallback then
		self._screenRefreshCallback = {}
	end

	self._screenRefreshCallback[callback] = true
end

function ClientSpaceArkScreenComponent:removeScreenRefreshCallback(callback)
	if self._screenRefreshCallback then
		self._screenRefreshCallback[callback] = nil
	end
end

return ClientSpaceArkScreenComponent
