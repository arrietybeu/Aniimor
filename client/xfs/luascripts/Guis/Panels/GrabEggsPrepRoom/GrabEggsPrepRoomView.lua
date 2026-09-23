-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsPrepRoom\\GrabEggsPrepRoomView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsPrepRoomView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsPrepRoomView = Class.LightClass("GrabEggsPrepRoomView", UIView)

function GrabEggsPrepRoomView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBack = objectReference:GetRefValue("btnBack")
	self.exitBtnName = objectReference:GetRefValue("exitBtnName")
	self.mapOc = objectReference:GetRefValue("mapOc")
	self.centerItem1 = objectReference:GetRefValue("centerItem1")
	self.centerItem2 = objectReference:GetRefValue("centerItem2")
	self.centerItem3 = objectReference:GetRefValue("centerItem3")
	self.chatUContainer = objectReference:GetRefValue("chatUContainer")
	self.funcUContainer = objectReference:GetRefValue("funcUContainer")
	self.btnStore = objectReference:GetRefValue("btnStore")
	self.btnEquip = objectReference:GetRefValue("btnEquip")
	self.consoleBar = objectReference:GetRefValue("consoleBar")
	self.panelTeam = objectReference:GetRefValue("panelTeam")
	self.uiCardList = {
		self.centerItem1,
		self.centerItem2,
		self.centerItem3
	}
end

function GrabEggsPrepRoomView:registerObjects()
	self.mapUWidget = self.mapOc.gameObject:GetComponent("UWidget")
	self.picUImage = self.mapOc:GetRefValue("picUImage")
	self.mapName = self.mapOc:GetRefValue("mapName")
	self.iconWeather = self.mapOc:GetRefValue("iconWeather")
	self.btnModeSwitch = self.mapOc:GetRefValue("btnModeSwitch")
	self.txtModeName = self.mapOc:GetRefValue("txtModeName")
	self.funOc = self.funcUContainer.content:GetComponent("ObjectReference")
	self.funUWidget = self.funcUContainer.content:GetComponent("UWidget")
	self.btnConfirm = self.funOc:GetRefValue("btnConfirm")
	self.btnCancel = self.funOc:GetRefValue("btnCancel")
	self.countDown = self.funOc:GetRefValue("countDown")
	self.btnExitTeam = self.funOc:GetRefValue("btnExitTeam")
	self.btnInvite = self.funOc:GetRefValue("btnInvite")
	self.txtTips = self.funOc:GetRefValue("txtTips")
	self.checkInfo = self.funOc:GetRefValue("checkInfo")
	self.btnCheck = self.funOc:GetRefValue("btnCheck")
	self.txtCheck = self.funOc:GetRefValue("txtCheck")

	local btnModeSwitchOc = self.btnModeSwitch.transform:GetComponent("ObjectReference")

	self.btnModeSwitchKeyContent = btnModeSwitchOc:GetRefValue("keyHotKeyContent")
end

function GrabEggsPrepRoomView:initView()
	return
end

return GrabEggsPrepRoomView
