-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Training\\TrainingView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local TrainingView = Class.LightClass("TrainingView", UIView)

function TrainingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.root = self.objectReference:GetRefValue("root")
	self.downBtn = self.objectReference:GetRefValue("downBtn")
	self.upBtn = self.objectReference:GetRefValue("upBtn")
	self.petChoiceList = self.objectReference:GetRefValue("petChoiceList")
	self.openAiBtn = self.objectReference:GetRefValue("openAiBtn")
	self.closeAiBtn = self.objectReference:GetRefValue("closeAiBtn")
	self.exitBtn = self.objectReference:GetRefValue("exitBtn")
	self.resetBtn = self.objectReference:GetRefValue("resetBtn")
	self.openPuppetBtn = self.objectReference:GetRefValue("openPuppetBtn")
	self.closePuppetBtn = self.objectReference:GetRefValue("closePuppetBtn")
end

function TrainingView:initView()
	self.openAIState = true

	function self.openAiBtn.luaClick()
		self.openAIState = false

		self.root:TryChangePage("ChoiceOpenBtn", 0)
		pg.me:serverMsg("RPC_CS_StumpPuppetSwitch", self.openAIState)
	end

	function self.closeAiBtn.luaClick()
		self.openAIState = true

		self.root:TryChangePage("ChoiceOpenBtn", 1)
		pg.me:serverMsg("RPC_CS_StumpPuppetSwitch", self.openAIState)
	end

	function self.downBtn.luaClick()
		self.root:TryChangePage("ShowState", 1)
	end

	function self.upBtn.luaClick()
		self.root:TryChangePage("ShowState", 0)
	end
end

return TrainingView
