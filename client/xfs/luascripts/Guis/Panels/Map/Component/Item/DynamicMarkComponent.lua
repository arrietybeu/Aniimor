-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\Item\\DynamicMarkComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MapMarkResourceData = require("Data.map_mark_resource_data")
local MapUtils = require("Guis.Utils.MapUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local DynamicMarkComponent = Class.LightClass("DynamicMarkComponent", UIComponent)

function DynamicMarkComponent:findObjects()
	return
end

function DynamicMarkComponent:init()
	return
end

function DynamicMarkComponent:destroy()
	return
end

function DynamicMarkComponent:renderDynamicMarkIcon(table, spawnerId, spawnerTable, objInfo)
	table.recTrans.localScale = Vector3(1 / self.ctrl.currentZoom, 1 / self.ctrl.currentZoom, 1)

	local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.ctrl.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]
	local imgPath = defaultRes.icon
	local locationImgPath = imgPath
	local dynamicInfo = MapUtils.parseDynamicMarkStatus(spawnerId)

	if not dynamicInfo then
		return
	end

	table.resTaskIds = {}
	table.resObjs = {}

	for order, info in pairs(dynamicInfo) do
		local resPath = info.res

		table.resTaskIds[#table.resTaskIds + 1] = self.view:addPrefabWithPathAsync(table.btnRectTransform, resPath, function(obj1)
			self:renderPart(obj1, info)

			table.resObjs[#table.resObjs + 1] = obj1.gameObject
		end, false, false, 0)
	end

	if self.ctrl:shouldShowMarkOnLoad(table.scale, spawnerId) then
		objInfo.gameObject:SetActiveEx(true)
	end

	return imgPath, locationImgPath
end

function DynamicMarkComponent:adjustZoom(spawnerId, markCacheData)
	error("MinimapDynamicMarkComponent:adjustZoom not implement yet")
end

function DynamicMarkComponent:renderPart(partObj, partInfo)
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

function DynamicMarkComponent:getBubbleIcon(spawnerId)
	local extraInfo = MapUtils.getDynamicMarkSimpleIcon(spawnerId)

	if not extraInfo then
		return
	end

	return extraInfo[1]
end

function DynamicMarkComponent:renderLocationPanelInfo(spawnerId, objRef)
	local extraInfo = MapUtils.parseFirstDynamicMarkStatusExtraInfo(spawnerId)

	if not extraInfo then
		return
	end

	local iconImg = objRef:GetRefValue("iconImg")
	local titleTxt = objRef:GetRefValue("titleTxt")
	local previewImgImg = objRef:GetRefValue("previewImgImg")
	local scrollRectUScrollRect = objRef:GetRefValue("scrollRectUScrollRect")

	if not string.isNilOrEmpty(extraInfo[1]) then
		iconImg.url = extraInfo[1]
	end

	if not string.isNilOrEmpty(extraInfo[2]) then
		ClientTextUtils.setText(titleTxt, pg.getGameString(extraInfo[2]))
	end

	if not string.isNilOrEmpty(extraInfo[3]) then
		previewImgImg.url = extraInfo[3]
	end

	if not string.isNilOrEmpty(extraInfo[4]) then
		local objectReference = scrollRectUScrollRect.content.transform:GetComponent("ObjectReference")
		local descriptionUSDFText = objectReference:GetRefValue("descriptionUSDFText")

		ClientTextUtils.setText(descriptionUSDFText, pg.getGameString(extraInfo[4]))
	end
end

function DynamicMarkComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return DynamicMarkComponent
