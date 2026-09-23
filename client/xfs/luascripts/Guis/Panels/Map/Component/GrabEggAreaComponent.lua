-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\GrabEggAreaComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AddressDataConst = require("Const.AddressDataConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local GrabEggAreaComponent = Class.LightClass("GrabEggAreaComponent", UIComponent)

GrabEggAreaComponent.messages = {
	[MessageName.GRAB_EGG_NOVICE_PROTECTION_CHANGED] = {
		"refreshNoviceMapFogVisual"
	}
}

local function shouldRevealAllMapFog(sceneId)
	local space = pg.space

	return space ~= nil and space.shouldRevealAllMapFog ~= nil and space:shouldRevealAllMapFog(sceneId)
end

function GrabEggAreaComponent:findObjects()
	self.appearAreaMarkData = {}
end

function GrabEggAreaComponent:init()
	self:refreshNoviceMapFogVisual()
end

function GrabEggAreaComponent:refreshNoviceMapFogVisual()
	if not shouldRevealAllMapFog(self.ctrl.sceneId) then
		self:restoreNoviceMapFogVisual()

		return
	end

	local ctrl = self.ctrl
	local generator = ctrl and ctrl.mapFogGenerator
	local target = generator and NotNil(generator) and generator.gameObject or nil

	if target and not NotNil(target) then
		target = nil
	end

	if self.noviceMapFogVisualOverridden and self.noviceMapFogVisualTarget ~= target then
		self:restoreNoviceMapFogVisual()
	end

	if not self.noviceMapFogVisualOverridden then
		self.noviceMapFogVisualOverridden = true
		self.originalMapFogBlock = ctrl.mapFogBlock

		if target then
			self.noviceMapFogVisualTarget = target
		end
	end

	ctrl.mapFogBlock = false

	if target then
		UIUtils.ScaleVisible(target, false)
	end
end

function GrabEggAreaComponent:restoreNoviceMapFogVisual()
	if not self.noviceMapFogVisualOverridden then
		return
	end

	local target = self.noviceMapFogVisualTarget

	if target and NotNil(target) then
		UIUtils.ScaleVisible(target, true)
	end

	local ctrl = self.ctrl

	if ctrl then
		ctrl.mapFogBlock = self.originalMapFogBlock
	end

	self.noviceMapFogVisualOverridden = nil
	self.noviceMapFogVisualTarget = nil
	self.originalMapFogBlock = nil
end

function GrabEggAreaComponent:instantiateAppearArea(id, areaData)
	if Time.secondCache >= areaData.endTimeStamp then
		return
	end

	if not self.appearAreaMarkData[id] then
		self.appearAreaMarkData[id] = {}
	else
		return
	end

	local layer = string.format("markerListTransformLayer%s", 0)

	self.appearAreaMarkData[id].taskId = self.view:addPrefabWithPathAsync(self.view[layer], AddressDataConst.UI_MARK_GRAB_EGG_APPEAR, function(objInfo)
		self.appearAreaMarkData[id].taskObj = objInfo.gameObject

		self:loadResInner(objInfo.gameObject, id, areaData)
	end, true, true)
end

function GrabEggAreaComponent:destroyAppearArea(id)
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

function GrabEggAreaComponent:destroyAllAppearArea()
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

function GrabEggAreaComponent:loadResInner(go, id, areaData)
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

	if #self.view.mapLevelBreakdown == 4 and self.ctrl.curStage == #self.view.scaleBasicTable then
		go:SetActiveEx(false)
	else
		go:SetActiveEx(true)
		self:refreshCountDown(id)
	end

	ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(areaData.content))

	go.transform.localScale = Vector3(1 / self.ctrl.currentZoom, 1 / self.ctrl.currentZoom, 1)

	local radius = pg.game.map:calRadius(self.ctrl.sceneId, areaData.radius)
	local sizeDeltaNum = radius / (1 / self.ctrl.currentZoom) * 2

	imgGlowUImage.transform.sizeDelta = Vector2(sizeDeltaNum, sizeDeltaNum)
end

function GrabEggAreaComponent:refreshCountDown(id)
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

function GrabEggAreaComponent:adjustScale(currentZoom)
	if not currentZoom then
		return
	end

	local scale = 1 / currentZoom
	local scale2 = 1 / currentZoom * 2

	for _, data in pairs(self.appearAreaMarkData) do
		if data.taskObj then
			data.taskObj.transform:SetLocalScalEx(scale, scale, 1)
		end

		if NotNil(data.circleTrans) and data.radius then
			local r = pg.game.map:calRadius(self.ctrl.sceneId, data.radius)
			local sizeDeltaNum = r * scale2

			data.circleTrans:SetSizeDeltaEx(sizeDeltaNum, sizeDeltaNum)
		end
	end
end

function GrabEggAreaComponent:adjustActiveState(isActive)
	for id, data in pairs(self.appearAreaMarkData) do
		if data.taskObj then
			data.taskObj:SetActiveEx(isActive)

			if isActive then
				self:refreshCountDown(id)
			end
		end
	end
end

function GrabEggAreaComponent:onDestroy()
	self:restoreNoviceMapFogVisual()
	self:destroyAllAppearArea()
end

return GrabEggAreaComponent
