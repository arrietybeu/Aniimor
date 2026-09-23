-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestNaturalChoice\\QuestNaturalChoiceCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local QuestNaturalChoiceCtrl = Class.LightClass("QuestNaturalChoiceCtrl", UICtrl)
local DialogueGraphCommonConst = require("Common.Const.DialogueGraphCommonConst")
local NaturalChoiceText = {
	{
		title = "QUEST_NATURAL_CHOICE_TXT_1",
		choice = {
			{
				"QUEST_NATURAL_CHOICE_TXT_1a"
			},
			{
				"QUEST_NATURAL_CHOICE_TXT_1b"
			}
		}
	},
	{
		title = "QUEST_NATURAL_CHOICE_TXT_2",
		choice = {
			{
				"QUEST_NATURAL_CHOICE_TXT_2a"
			},
			{
				"QUEST_NATURAL_CHOICE_TXT_2b"
			}
		}
	},
	{
		title = "QUEST_NATURAL_CHOICE_TXT_3",
		choice = {
			{
				"QUEST_NATURAL_CHOICE_TXT_3a"
			},
			{
				"QUEST_NATURAL_CHOICE_TXT_3b"
			}
		}
	},
	{
		title = "QUEST_NATURAL_CHOICE_TXT_4",
		choice = {
			{
				"QUEST_NATURAL_CHOICE_TXT_4a"
			},
			{
				"QUEST_NATURAL_CHOICE_TXT_4b"
			}
		}
	}
}

function QuestNaturalChoiceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function QuestNaturalChoiceCtrl:addListener()
	function self.view.listOptionUList.luaRenderItem(button, index, data)
		local objectReference = button.transform:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
		local widgetAnimation = objectReference:GetRefValue("widgetAnimation")

		ClientTextUtils.setText(txtNameUBaseText, ClientTextUtils.getGameString(data[1]))

		button.interactable = true

		function button.luaClick()
			local score = index == 0 and 1 or -1

			button.isSelected = true

			if self.scheduleRPC then
				-- block empty
			else
				pg.me:updateTwinPetChoiceScore(score)
			end

			UIUtils.PlayAnimation(widgetAnimation, "VX_Node_Nature_Option_Press")
			self:startTimer(function()
				UIUtils.PlayAnimation(self.view.rootAnimation, "VX_3D_NatureQuestion_Out", function()
					self:dismiss()
				end)
			end, 0.5)

			button.interactable = false
		end
	end
end

function QuestNaturalChoiceCtrl:onShow()
	return
end

function QuestNaturalChoiceCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info ~= nil then
		self.index = info.index or 1
		self.scheduleRPC = info.scheduleRPC
	end

	self:showPanel(info)
end

function QuestNaturalChoiceCtrl:showPanel()
	local textConfig = NaturalChoiceText[self.index]

	ClientTextUtils.setText(self.view.txtTitleUBaseText, ClientTextUtils.getGameString(textConfig.title))
	self.view.listOptionUList:SetList(textConfig.choice)
end

function QuestNaturalChoiceCtrl:onHide()
	return
end

function QuestNaturalChoiceCtrl:clearUpdateTimer()
	return
end

function QuestNaturalChoiceCtrl:checkFadeOutHud()
	return true
end

function QuestNaturalChoiceCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

return QuestNaturalChoiceCtrl
