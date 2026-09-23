-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\PhotographyStudioEditView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotographyStudioEditView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PhotographyStudioEditView = Class.LightClass("PhotographyStudioEditView", UIView)

function PhotographyStudioEditView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.animation = objectReference:GetRefValue("animation")
	self.btnInviteUButton = objectReference:GetRefValue("btnInviteUButton")
	self.btnRedoUButton = objectReference:GetRefValue("btnRedoUButton")
	self.joyStickArea = objectReference:GetRefValue("joyStickArea")
	self.boxSlider = objectReference:GetRefValue("boxSlider")
	self.btnJS = objectReference:GetRefValue("btnJS")
	self.joyStick = objectReference:GetRefValue("joyStick")
	self.btnUpUButton = objectReference:GetRefValue("btnUpUButton")
	self.btnDownUButton = objectReference:GetRefValue("btnDownUButton")
	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.keys = objectReference:GetRefValue("keys")
	self.cameraCtrlDragUpdateListener = objectReference:GetRefValue("cameraCtrlDragUpdateListener")
	self.btnMenuUButton = objectReference:GetRefValue("btnMenuUButton")
	self.btnPoseUButton = objectReference:GetRefValue("btnPoseUButton")
	self.btnRotatePhotoUButton = objectReference:GetRefValue("btnRotatePhotoUButton")
	self.cameraMenuPanelUComponent = objectReference:GetRefValue("cameraMenuPanelUComponent")
	self.bgClickUButton = objectReference:GetRefValue("bgClickUButton")
	self.center2Transform = objectReference:GetRefValue("center2Transform")
	self.rootWindowsRectTransform = objectReference:GetRefValue("rootWindowsRectTransform")
	self.changeLensAnimation = objectReference:GetRefValue("changeLensAnimation")
	self.mobileCameraCtrlUButton = objectReference:GetRefValue("mobileCameraCtrlUButton")
	self.titleUWidget = objectReference:GetRefValue("titleUWidget")
	self.keyBox3RectTransform = objectReference:GetRefValue("keyBox3RectTransform")
	self.followFrameUWidget = objectReference:GetRefValue("followFrameUWidget")
	self.center2UWidget = objectReference:GetRefValue("center2UWidget")
	self.takePhotoBtn = objectReference:GetRefValue("takePhotoBtn")
	self.operateMobileUWidget = objectReference:GetRefValue("operateMobileUWidget")
	self.cameraBtnsUWidget = objectReference:GetRefValue("cameraBtnsUWidget")
	self.textResetUBaseText = objectReference:GetRefValue("textResetUBaseText")
	self.safeBoxMobileUWidget = objectReference:GetRefValue("safeBoxMobileUWidget")
	self.btnBackMainUButton = objectReference:GetRefValue("btnBackMainUButton")
	self.backKeyHotkeyContent = objectReference:GetRefValue("backKeyHotkeyContent")
	self.keyLeftConsoleUWidget = objectReference:GetRefValue("keyLeftConsoleUWidget")
	self.btnUndoUButton = objectReference:GetRefValue("btnUndoUButton")
	self.btnSaveUButton = objectReference:GetRefValue("btnSaveUButton")
	self.zoomDec = objectReference:GetRefValue("zoomDec")
	self.zoomAdd = objectReference:GetRefValue("zoomAdd")
	self.zoom = objectReference:GetRefValue("zoom")
	self.inviteNumUBaseText = objectReference:GetRefValue("inviteNumUBaseText")
	self.btnRecycleUButton = objectReference:GetRefValue("btnRecycleUButton")
	self.btnOKUButton = objectReference:GetRefValue("btnOKUButton")
	self.btnMulEditUButton = objectReference:GetRefValue("btnMulEditUButton")
	self.txtMulEditUBaseText = objectReference:GetRefValue("txtMulEditUBaseText")
end

function PhotographyStudioEditView:registerObjects()
	return
end

function PhotographyStudioEditView:initView()
	return
end

return PhotographyStudioEditView
