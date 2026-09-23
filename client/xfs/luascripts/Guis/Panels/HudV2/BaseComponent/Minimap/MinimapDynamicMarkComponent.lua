-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\Minimap\\MinimapDynamicMarkComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MapUtils = require("Guis.Utils.MapUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local MinimapDynamicMarkComponent = Class.LightClass("MinimapDynamicMarkComponent", UIComponent)

function MinimapDynamicMarkComponent:findObjects()
	return
end

function MinimapDynamicMarkComponent:init()
	return
end

function MinimapDynamicMarkComponent:renderDynamicMarkIcon(cache, spawnerId, spawnerTable, objInfo, isTrack)
	local dynamicInfo = MapUtils.parseDynamicMarkStatus(spawnerId)

	if not dynamicInfo then
		return
	end

	cache.resTaskIds = {}
	cache.resObjs = {}

	for order, info in pairs(dynamicInfo) do
		local resPath = info.res

		cache.resTaskIds[#cache.resTaskIds + 1] = self.view:addPrefabWithPathAsync(cache.root.btnRectTransform, resPath, function(obj1)
			self:renderPart(obj1, info, isTrack)

			cache.resObjs[#cache.resObjs + 1] = obj1.gameObject
		end, false, true)
	end

	objInfo.gameObject:SetActiveEx(true)
end

function MinimapDynamicMarkComponent:adjustZoom(spawnerId, markCacheData)
	return
end

function MinimapDynamicMarkComponent:renderPart(partObj, partInfo, isTrack)
	if partInfo.partId == 1 then
		partObj.gameObject:GetComponent("UImage").url = partInfo.params[1]
	elseif partInfo.partId == 2 then
		local objectReference = partObj.gameObject:GetComponent("ObjectReference")
		local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
		local root = objectReference:GetRefValue("root")

		ClientTextUtils.setText(textNameUSDFText, pg.getGameString(partInfo.params[1]))
		root:TryChangePage("state", partInfo.params[2])
		root:TryChangePage("PVP", partInfo.params[3])
	elseif partInfo.partId == 3 then
		local objectReference = partObj.gameObject:GetComponent("ObjectReference")
		local root = objectReference:GetRefValue("root")
		local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

		root:TryChangePage("State", partInfo.params[1])

		if partInfo.params[1] and partInfo.params[1] == 1 and partInfo.params[2] == "server" and partInfo.serverParams then
			local endTimeStamp = partInfo.serverParams.timeStamp

			if endTimeStamp then
				local curTimeStamp = Time.secondCache

				if curTimeStamp < endTimeStamp then
					function countDownUCountDown.luaFinished()
						root:TryChangePage("State", 2)
					end

					countDownUCountDown:Play(endTimeStamp - curTimeStamp)
				end
			end
		end
	end
end

function MinimapDynamicMarkComponent:destroy()
	return
end

function MinimapDynamicMarkComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

function MinimapDynamicMarkComponent:onDynamicMarkStatusChanged(info)
	self.ctrl:refreshSpawner(self.ctrl.sceneId, info.markId)
end

return MinimapDynamicMarkComponent
