-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncCameraModeUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncCameraModeUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncCameraModeUIComponent = Class.LightClass("PhotoFuncCameraModeUIComponent", UIComponent)
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

PhotoFuncCameraModeUIComponent.CameraModeIds = {
	WideAngle = 1,
	FreeCamera = 0,
	FishEye = 2
}
PhotoFuncCameraModeUIComponent.CameraModes = {
	{
		label = "PHOTO_FREE_CAMERA",
		checkShow = "isShowCameraMode",
		cameraModeId = PhotoFuncCameraModeUIComponent.CameraModeIds.FreeCamera
	},
	{
		label = "PHOTO_WIDE_ANGLE",
		checkShow = "isShowCameraMode",
		cameraModeId = PhotoFuncCameraModeUIComponent.CameraModeIds.WideAngle
	},
	{
		label = "PHOTO_FISH_EYE_CAMERA",
		checkShow = "isShowCameraMode",
		cameraModeId = PhotoFuncCameraModeUIComponent.CameraModeIds.FishEye
	}
}
PhotoFuncCameraModeUIComponent.CameraModeParamIds = {
	hiddenSelfPlayer = 1,
	ReferenceLine = 0,
	hiddenSelfPet = 2
}
PhotoFuncCameraModeUIComponent.CameraModeParams = {
	{
		label = "PHOTO_GRID",
		paramId = PhotoFuncCameraModeUIComponent.CameraModeParamIds.ReferenceLine
	},
	{
		label = "PHOTO_MC",
		paramId = PhotoFuncCameraModeUIComponent.CameraModeParamIds.hiddenSelfPlayer
	},
	{
		label = "PHOTO_ANIIMO",
		paramId = PhotoFuncCameraModeUIComponent.CameraModeParamIds.hiddenSelfPet
	}
}

function PhotoFuncCameraModeUIComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
end

function PhotoFuncCameraModeUIComponent:findObjects()
	self.photoCameraZoomUpdateCurve = pg.global.cameraMgr.vcManager:GetPhotoCameraZoomUpdateCurve()
	self.photoCameraZoomUpdateCurveWildAngle = pg.global.cameraMgr.vcManager:GetPhotoCameraZoomUpdateCurveWideAngle()
	self.photoCameraZoomUpdateCurveFishEye = pg.global.cameraMgr.vcManager:GetPhotoCameraZoomUpdateCurveFishEye()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.scrollRectUScrollRect = self.objectReference:GetRefValue("scrollRectUScrollRect")

	local objectReference = self.scrollRectUScrollRect.content.transform:GetComponent("ObjectReference")

	self.cameraModeUList = objectReference:GetRefValue("cameraModeUList")
	self.cameraModeParamUList = objectReference:GetRefValue("cameraModeParamUList")
end

function PhotoFuncCameraModeUIComponent:initView()
	self:initPhotoCameraMode()
end

function PhotoFuncCameraModeUIComponent:onRefreshPhotoType()
	if not self.ctrl:isShowCameraMode() then
		return
	end
end

function PhotoFuncCameraModeUIComponent:onDestroy()
	for _, data in ipairs(self.CameraModeParams) do
		data.selected = false
	end

	self:showSelfPet()
	self:showSelfPlayer()
	UIComponent.onDestroy(self)
end

function PhotoFuncCameraModeUIComponent:initPhotoCameraMode()
	self.funcOpenByParamId = {}

	self.model:setCameraMode(self.CameraModeIds.FreeCamera)
	self.view.referenceLineUWidget:SetActive(false)

	function self.cameraModeUList.luaRenderItem(button, index, data)
		button:TryChangePage("CameraMode", data.cameraModeId)

		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.label))
		button:SetActive(self.ctrl:isShowCameraMode())
	end

	function self.cameraModeUList.luaClick(button, data)
		self.model:setCameraMode(data.cameraModeId)
		self:setFov(self.view.zoom.value)
		self.ctrl:showParamTip(1, pg.getGameString("PHOTO_LENS"), pg.getGameString(data.label))
	end

	function self.cameraModeParamUList.luaRenderItem(button, index, data)
		button:TryChangePage("CameraModeParam", data.paramId)
	end

	function self.cameraModeParamUList.luaClick(button, data)
		self:handleCameraModeParamClick(data)

		local paramStr

		if data.paramId == self.CameraModeParamIds.ReferenceLine then
			paramStr = self.funcOpenByParamId[data.paramId] and pg.getGameString("PHOTO_SHOW") or pg.getGameString("PHOTO_HIDE")
		elseif data.paramId == self.CameraModeParamIds.hiddenSelfPlayer then
			paramStr = self.funcOpenByParamId[data.paramId] and pg.getGameString("PHOTO_HIDE") or pg.getGameString("PHOTO_SHOW")
		elseif data.paramId == self.CameraModeParamIds.hiddenSelfPet then
			paramStr = self.funcOpenByParamId[data.paramId] and pg.getGameString("PHOTO_HIDE") or pg.getGameString("PHOTO_SHOW")
		end

		self.ctrl:showParamTip(1, pg.getGameString(data.label), paramStr)
	end

	for _, data in ipairs(self.CameraModeParams) do
		if data.selected then
			self:handleCameraModeParamClick(data)
		end
	end

	self:applyPreset(self.preset)
end

function PhotoFuncCameraModeUIComponent:refreshUI()
	self.cameraModeUList:SetList(self.CameraModes)
	self.cameraModeParamUList:SetList(self.CameraModeParams)

	if not self.haveRefreshed then
		self.haveRefreshed = true
	end

	local mode = self.model:getCameraMode()

	if mode == self.CameraModeIds.FreeCamera then
		self.cameraModeUList:SelectItem(0)
	elseif mode == self.CameraModeIds.WideAngle then
		self.cameraModeUList:SelectItem(1)
	elseif mode == self.CameraModeIds.FishEye then
		self.cameraModeUList:SelectItem(2)
	else
		self.cameraModeUList:SelectItem(0)
	end
end

function PhotoFuncCameraModeUIComponent:applyPreset(preset)
	if preset and preset.photoCameraMode then
		if type(preset.photoCameraMode) == "userdata" then
			self.model:setCameraMode(preset.photoCameraMode:GetHashCode())
		else
			self.model:setCameraMode(tonumber(preset.photoCameraMode))
		end
	end

	self:setFov(self.view.zoom.value)
end

function PhotoFuncCameraModeUIComponent:saveToPreset(preset)
	preset.photoCameraMode = self.model:getCameraMode()
end

function PhotoFuncCameraModeUIComponent:refreshPhotoCameraMode()
	self.cameraModeUList:SetList(self.CameraModes)
	self.cameraModeParamUList:SetList(self.CameraModeParams)
end

function PhotoFuncCameraModeUIComponent:handleCameraModeParamClick(data)
	self.funcOpenByParamId[data.paramId] = not self.funcOpenByParamId[data.paramId]

	if data.paramId == self.CameraModeParamIds.ReferenceLine then
		self.showReferenceLine = not self.showReferenceLine

		self.view.referenceLineUWidget:SetActive(self.funcOpenByParamId[data.paramId])
	elseif data.paramId == self.CameraModeParamIds.hiddenSelfPlayer then
		if self.funcOpenByParamId[data.paramId] then
			self:hiddenSelfPlayer()
		else
			self:showSelfPlayer()
		end
	elseif data.paramId == self.CameraModeParamIds.hiddenSelfPet then
		if self.funcOpenByParamId[data.paramId] then
			self:hiddenSelfPet()
		else
			self:showSelfPet()
		end
	end
end

function PhotoFuncCameraModeUIComponent:hiddenSelfPlayer()
	if pg.me then
		pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, false)
	end
end

function PhotoFuncCameraModeUIComponent:showSelfPlayer()
	if pg.me then
		pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, true)
	end
end

function PhotoFuncCameraModeUIComponent:hiddenSelfPet()
	self.ctrl:setPetVisible(false)
end

function PhotoFuncCameraModeUIComponent:showSelfPet()
	self.ctrl:setPetVisible(true)
end

function PhotoFuncCameraModeUIComponent:setFov(value)
	local cameraMode = self.model:getCameraMode()

	pg.game.camera.photoCameraMode.cameraMode:EnableFishEye(cameraMode == self.CameraModeIds.FishEye)

	if cameraMode == self.CameraModeIds.FreeCamera then
		value = self.photoCameraZoomUpdateCurve:Evaluate(value)
	elseif cameraMode == self.CameraModeIds.WideAngle then
		value = self.photoCameraZoomUpdateCurveWildAngle:Evaluate(value)
	elseif cameraMode == self.CameraModeIds.FishEye then
		value = self.photoCameraZoomUpdateCurveFishEye:Evaluate(value)
	end

	pg.game.camera.photoCameraMode:zoom(value)
end

function PhotoFuncCameraModeUIComponent:refreshFishEyeEffect(photoType)
	if photoType == "Follow" then
		pg.game.camera.photoCameraMode.cameraMode:EnableFishEye(false)
	else
		local cameraMode = self.model:getCameraMode()

		pg.game.camera.photoCameraMode.cameraMode:EnableFishEye(cameraMode == self.CameraModeIds.FishEye)
	end
end

return PhotoFuncCameraModeUIComponent
