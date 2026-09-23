-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestNpcEventChain\\QuestNpcEventChainView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestNpcEventChainView = Class.LightClass("QuestNpcEventChainView", UIView)

function QuestNpcEventChainView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootAnimation = objectReference:GetRefValue("rootAnimation")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.textTipsUSDFText = objectReference:GetRefValue("textTipsUSDFText")
	self.textInfoUSDFText = objectReference:GetRefValue("textInfoUSDFText")
	self.clueBubble1UButton = objectReference:GetRefValue("clueBubble1UButton")
	self.clueBubble2UButton = objectReference:GetRefValue("clueBubble2UButton")
	self.clueBubble3UButton = objectReference:GetRefValue("clueBubble3UButton")
	self.clueBubble4UButton = objectReference:GetRefValue("clueBubble4UButton")
	self.dialogueTitleText = objectReference:GetRefValue("dialogueTitleText")
	self.dialogueText = objectReference:GetRefValue("dialogueText")
	self.dialogueSimpleUWidget = objectReference:GetRefValue("dialogueSimpleUWidget")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.mainTitleText = objectReference:GetRefValue("mainTitleText")
	self.dialogueBtn = objectReference:GetRefValue("dialogueBtn")
	self.hintUWidget = self.dialogueSimpleUWidget.transform:Find("Panel/Hint"):GetComponent("UWidget")
	self.belogginginUWidget = self.dialogueSimpleUWidget.transform:Find("Panel/Beloggingin"):GetComponent("UWidget")
end

function QuestNpcEventChainView:registerObjects()
	return
end

function QuestNpcEventChainView:initView()
	return
end

local chainComs = {}

function QuestNpcEventChainView:getTabItemComs(btn)
	if chainComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		chainComs[btn] = {}
		chainComs[btn].button = btn
		chainComs[btn].ani = objectReference:GetRefValue("rootAnimation")
		chainComs[btn].title = objectReference:GetRefValue("textTtileUSDFText")
		chainComs[btn].container = objectReference:GetRefValue("containerUContainer")
		chainComs[btn].image = objectReference:GetRefValue("imageClueIconUImage")
		chainComs[btn].chainText = objectReference:GetRefValue("textClueContentUSDFText")
	end

	return chainComs[btn]
end

function QuestNpcEventChainView:onDestroy()
	for k in next, chainComs do
		chainComs[k] = nil
	end
end

return QuestNpcEventChainView
