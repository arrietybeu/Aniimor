-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Spectate\\SpectateView.lua

local logger = require("Core.Log.LoggerManager").getLogger("SpectateView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SpectateView = Class.LightClass("SpectateView", UIView)

function SpectateView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.spectateMemberTxt = self.objectReference:GetRefValue("spectateMemberTxt")
	self.memberPosImg = self.objectReference:GetRefValue("posImg")
	self.memberName = self.objectReference:GetRefValue("txtName")
	self.keyListUList = self.objectReference:GetRefValue("keyListUList")
	self.teamPanelUContainer = self.objectReference:GetRefValue("teamPanelUContainer")
	self.btnPrev = self.objectReference:GetRefValue("BtnPrev")
	self.btnNext = self.objectReference:GetRefValue("BtnNext")
	self.btnChat = self.objectReference:GetRefValue("BtnChat")
	self.btnChatPC = self.objectReference:GetRefValue("BtnChatPC")
end

function SpectateView:registerObjects()
	return
end

function SpectateView:initView()
	return
end

function SpectateView:createCameraDragListener()
	local go = CS.UnityEngine.GameObject("SpectateCameraDrag", typeof(CS.UnityEngine.RectTransform))

	go:SetActiveEx(false)

	go.layer = self.gameObject.layer

	local rect = go.transform

	rect:SetParent(self.transform, false)
	rect:SetAsFirstSibling()

	rect.anchorMin = Vector2.zero
	rect.anchorMax = Vector2.one
	rect.offsetMin = Vector2.zero
	rect.offsetMax = Vector2.zero

	go:AddComponent(typeof(CS.XGUI.URayBox))

	self.cameraDragListener = go:AddComponent(typeof(CS.FunPlus.WorldX.GUIS.Panels.Utils.DragUpdateListener))

	return self.cameraDragListener
end

return SpectateView
