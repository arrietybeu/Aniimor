-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\Minimap\\MinimapGrabEggAreaComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AddressDataConst = require("Const.AddressDataConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local MinimapGrabEggAreaComponent = Class.LightClass("MinimapGrabEggAreaComponent", UIComponent)

MinimapGrabEggAreaComponent.messages = {
	[MessageName.GRAB_EGG_NOVICE_PROTECTION_CHANGED] = {
		"refreshNoviceMapFogVisual"
	}
}

local function shouldRevealAllMapFog(sceneId)
	local space = pg.space

	return space ~= nil and space.shouldRevealAllMapFog ~= nil and space:shouldRevealAllMapFog(sceneId)
end

function MinimapGrabEggAreaComponent:findObjects()
	self.appearAreaMarkData = {}
end

function MinimapGrabEggAreaComponent:init()
	self:refreshNoviceMapFogVisual()
end

function MinimapGrabEggAreaComponent:refreshNoviceMapFogVisual()
	if not shouldRevealAllMapFog(self.ctrl.sceneId) then
		self:restoreNoviceMapFogVisual()

		return
	end

	local generator = self.ctrl.fogMapFogGenerator
	local target = generator and NotNil(generator) and generator.gameObject or nil

	if not target or not NotNil(target) then
		self:restoreNoviceMapFogVisual()

		return
	end

	if self.noviceMapFogVisualTarget ~= target then
		self:restoreNoviceMapFogVisual()

		self.noviceMapFogVisualTarget = target
	end

	UIUtils.ScaleVisible(target, false)

	self.noviceMapFogVisualOverridden = true
end

function MinimapGrabEggAreaComponent:restoreNoviceMapFogVisual()
	if not self.noviceMapFogVisualOverridden then
		return
	end

	local target = self.noviceMapFogVisualTarget

	if target and NotNil(target) then
		UIUtils.ScaleVisible(target, true)
	end

	self.noviceMapFogVisualOverridden = nil
	self.noviceMapFogVisualTarget = nil
end

function MinimapGrabEggAreaComponent:resetForSceneReload()
	self:restoreNoviceMapFogVisual()
	self:destroyAllAppearArea()

	self.appearAreaMarkData = {}
	self._sceneId = nil
end

function MinimapGrabEggAreaComponent:instantiateAppearArea(id, areaData)
	if Time.secondCache >= areaData.endTimeStamp then
		return
	end

	if not self.appearAreaMarkData[id] then
		self.appearAreaMarkData[id] = {}
	else
		return
	end

	local layer = string.format("markerListTransformLayer%s", 0)

	self.appearAreaMarkData[id].taskId = self.view:addPrefabWithPathAsync(self.ctrl[layer], AddressDataConst.UI_MARK_GRAB_EGG_APPEAR, function(objInfo)
		self.appearAreaMarkData[id].taskObj = objInfo.gameObject

		self:loadResInner(objInfo.gameObject, id, areaData)
	end, true, true)
end

function MinimapGrabEggAreaComponent:destroyAppearArea(id)
	local data = self.appearAreaMarkData[id]

	if not data then
		return
	end

	if data.taskId then
		self.view:cancelUIAsyncTask(data.taskId)
	end

	if data.taskObj then
		if self.view:checkInstanceExists(data.taskObj) and NotNil(data.animation) then
			UIUtils.PlayAnimation(data.animation, "VX_MapMisc_GrabEgg_Appear_Out", function()
				self.view:destroyInstance(data.taskObj)
			end)
		else
			self.view:destroyInstance(data.taskObj)
		end
	end

	self.appearAreaMarkData[id] = nil
end

function MinimapGrabEggAreaComponent:destroyAllAppearArea()
	if not self.appearAreaMarkData then
		return
	end

	for _, data in pairs(self.appearAreaMarkData) do
		if data.taskId then
			self.view:cancelUIAsyncTask(data.taskId)
		end

		if data.taskObj then
			self.view:destroyInstance(data.taskObj)
		end
	end

	self.appearAreaMarkData = nil
end

function MinimapGrabEggAreaComponent:loadResInner(go, id, areaData)
	local objectReference = go:GetComponent("ObjectReference")
	local imgGlowUImage = objectReference:GetRefValue("imgGlowUImage")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local uIMapMiscGrabEggAppearAnimation = objectReference:GetRefValue("uIMapMiscGrabEggAppearAnimation")
	local recTrans = go:GetComponent("RectTransform")
	local mapX, mapY = pg.game.map:convertPos(areaData.pos.x, areaData.pos.z, self.ctrl.sceneId, true)

	recTrans.anchoredPosition = Vector2(mapX, mapY)
	self.appearAreaMarkData[id].animation = uIMapMiscGrabEggAppearAnimation
	self.appearAreaMarkData[id].endTimeStamp = areaData.endTimeStamp
	self.appearAreaMarkData[id].countDown = countDownUCountDown
	self.appearAreaMarkData[id].circleTrans = imgGlowUImage.transform
	self.appearAreaMarkData[id].radius = areaData.radius

	self:refreshCountDown(id)
	ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(areaData.content))

	go.transform.localScale = Vector3(UIConst.MAP_CONST.MINIMAP_ICON_SCALE_COE / self.ctrl.scaleFactor, UIConst.MAP_CONST.MINIMAP_ICON_SCALE_COE / self.ctrl.scaleFactor, 1)

	local radius = pg.game.map:calRadius(self.ctrl.sceneId, areaData.radius)
	local sizeDeltaNum = radius * (self.ctrl.scaleFactor / UIConst.MAP_CONST.MINIMAP_ICON_SCALE_COE) * 2

	imgGlowUImage.transform.sizeDelta = Vector2(sizeDeltaNum, sizeDeltaNum)
end

function MinimapGrabEggAreaComponent:refreshCountDown(id)
	if not self.appearAreaMarkData[id] then
		return
	end

	local data = self.appearAreaMarkData[id]

	if not data.endTimeStamp or not data.countDown then
		return
	end

	if Time.secondCache < data.endTimeStamp then
		data.countDown:Play(data.endTimeStamp - Time.secondCache)
	end
end

function MinimapGrabEggAreaComponent:adjustScale(currentZoom)
	local sceneId = self.ctrl.sceneId
	local scale = UIConst.MAP_CONST.MINIMAP_ICON_SCALE_COE / currentZoom
	local scaleReverse2 = 2 / scale

	if self._sceneId == sceneId then
		for _, data in pairs(self.appearAreaMarkData) do
			if data.scale ~= scale then
				if data.taskObj then
					data.taskObj.transform:SetLocalScaleEx(scale, scale, 1)
				end

				if NotNil(data.circleTrans) and data.radius then
					local radius = pg.game.map:calRadius(sceneId, data.radius)
					local sizeDeltaNum = radius * scaleReverse2

					data.circleTrans:SetSizeDeltaEx(sizeDeltaNum, sizeDeltaNum)
				end

				data.scale = scale
			end
		end
	else
		for _, data in pairs(self.appearAreaMarkData) do
			if data.taskObj then
				data.taskObj.transform:SetLocalScaleEx(scale, scale, 1)
			end

			if NotNil(data.circleTrans) and data.radius then
				local radius = pg.game.map:calRadius(sceneId, data.radius)
				local sizeDeltaNum = radius * scaleReverse2

				data.circleTrans:SetSizeDeltaEx(sizeDeltaNum, sizeDeltaNum)
			end
		end

		self._sceneId = sceneId
	end
end

function MinimapGrabEggAreaComponent:onDestroy()
	self:restoreNoviceMapFogVisual()
	self:destroyAllAppearArea()
end

return MinimapGrabEggAreaComponent
