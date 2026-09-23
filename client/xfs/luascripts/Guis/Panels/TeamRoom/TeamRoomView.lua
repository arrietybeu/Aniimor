-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\TeamRoomView.lua

local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIView = require("Guis.UIView")
local TeamRoomView = Class.LightClass("TeamRoomView", UIView)

function TeamRoomView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnReleaseUButton = self.objectReference:GetRefValue("btnReleaseUButton")
	self.consoleBarTransform = self.objectReference:GetRefValue("consoleBarTransform")
	self.recommendEleList = self.objectReference:GetRefValue("recommendEleList")
	self.dungeonName1UBaseText = self.objectReference:GetRefValue("dungeonName1UBaseText")
	self.uIPbTeamRoomUComponent = self.objectReference:GetRefValue("uIPbTeamRoomUComponent")
	self.skillListUList = self.objectReference:GetRefValue("skillListUList")
	self.elementUWidget = self.objectReference:GetRefValue("elementUWidget")
	self.skillUWidget = self.objectReference:GetRefValue("skillUWidget")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.challengeTipUBaseText = self.objectReference:GetRefValue("challengeTipUBaseText")
	self.stateNameUSDFText = self.objectReference:GetRefValue("stateNameUSDFText")
	self.countDownUCountDown = self.objectReference:GetRefValue("countDownUCountDown")
	self.dugNameUSDFText = self.objectReference:GetRefValue("dugNameUSDFText")
	self.btnCancelMatchUButton = self.objectReference:GetRefValue("btnCancelMatchUButton")
	self.btnReleaseUButton2 = self.objectReference:GetRefValue("btnReleaseUButton2")
	self.layoutRecommendUWidget = self.objectReference:GetRefValue("layoutRecommendUWidget")
	self.teamRoomFrameUContainer = self.objectReference:GetRefValue("teamRoomFrameUContainer")
	self.teamRoomFourUContainer = self.objectReference:GetRefValue("teamRoomFourUContainer")
	self.teamRoomThreeUContainer = self.objectReference:GetRefValue("teamRoomThreeUContainer")
	self.grabEggsUContainer = self.objectReference:GetRefValue("grabEggsUContainer")
end

function TeamRoomView:registerObjects()
	self.btnConfirmUText = self.btnConfirmUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.btnCancelUText = self.btnCancelUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.btnCancelMatchUText = self.btnCancelMatchUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
end

function TeamRoomView:initView()
	ClientTextUtils.setText(self.btnCancelMatchUText, pg.getGameString("CANCEL_MATCHING"))
end

function TeamRoomView:loadTeamMemberContainer(memberCount, callback)
	local useFour = memberCount == 4

	self.teamRoomFourUContainer:SetActive(useFour)
	self.teamRoomThreeUContainer:SetActive(not useFour)

	self.loadingMemberContainerCount = memberCount

	local container = useFour and self.teamRoomFourUContainer or self.teamRoomThreeUContainer

	container:LoadDefaultUrlManually(function(content)
		local objectReference = content:GetComponent("ObjectReference")

		self.loadingMemberContainerCount = nil
		self.memberContainerCount = memberCount
		self.panelTeam = content:GetComponent("UWidget")

		for i = 1, 4 do
			self["playerUButton" .. i] = i <= memberCount and objectReference:GetRefValue("playerUButton" .. i) or nil
		end

		if callback then
			callback()
		end
	end)
end

function TeamRoomView:getTeamMemberButtons()
	if self.memberContainerCount == 3 then
		return {
			self.playerUButton2,
			self.playerUButton1,
			self.playerUButton3
		}
	end

	return {
		self.playerUButton2,
		self.playerUButton3,
		self.playerUButton1,
		self.playerUButton4
	}
end

return TeamRoomView
