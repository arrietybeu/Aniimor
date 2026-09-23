-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\AIHelperLitUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("AIHelperLitUIComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local AiAssistantData = require("Data.ai_assistant_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local MessageName = require("Const.MessageName")
local AIHelperLitUIComponent = Class.LightClass("AIHelperLitUIComponent", HudBaseComponent)
local TRACK_EVENT_NAME = "aiHelperTrackTarget"

function AIHelperLitUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

function AIHelperLitUIComponent:onCtor(info)
	self.aiIdDict = {}

	self:tryShowAITipOnCreate()
end

function AIHelperLitUIComponent:initViewManual()
	self.aiHelperRoot = self.uWidget.content
	self.objectReference = self.aiHelperRoot:GetComponent("ObjectReference")
	self.btnTrackUButton = self.objectReference:GetRefValue("btnTrackUButton")
	self.iconTrackUImage = self.objectReference:GetRefValue("iconTrackUImage")
	self.txtContentUBaseText = self.objectReference:GetRefValue("txtContentUBaseText")
	self.aiAssistantUContainer = self.objectReference:GetRefValue("aiAssistantUContainer")
	self.tipsUButton = self.objectReference:GetRefValue("tipsUButton")
	self.keyHudHotKeyContent = self.objectReference:GetRefValue("keyHudHotKeyContent")
	self.clickTipsUWidget = self.objectReference:GetRefValue("clickTipsUWidget")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
	self.keyHotKeyContent2 = self.objectReference:GetRefValue("keyHotKeyContent")
	self.keyWordUButton = self.objectReference:GetRefValue("keyWordUButton")
	self.expandKeyHotKeyContent = self.objectReference:GetRefValue("expandKeyHotKeyContent")

	function self.btnTrackUButton.luaClick()
		self:onClickTrackBtn()
	end

	function self.tipsUButton.luaClick()
		self:onClickTipBtn()
	end

	self.trackBtnKeybinding = KeyBindingPro.GetOrAddKeyBindingByName(self.btnTrackUButton.gameObject, "doTrack")
	self.trackBtnKeybinding.keyBoardContent = self.keyHudHotKeyContent
	self.trackBtnKeybinding.isVirtual = true

	function self.trackBtnKeybinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.btnTrackUButton.luaClick()
		end
	end

	self.tipsBtnKeybinding = KeyBindingPro.GetOrAddKeyBindingByName(self.tipsUButton.gameObject, "doTrack")
	self.tipsBtnKeybinding.priority = 0
	self.trackBtnKeybinding.priority = -1
	self.tipsBtnKeybinding.keyBoardContent = self.keyHotKeyContent2
end

function AIHelperLitUIComponent:tryShowTrackTip()
	local curTime = os.time()

	if self.curAiId and (not self.tipsTime or curTime - self.tipsTime > 5) then
		self.tipsTime = curTime

		local cfgData = AiAssistantData[self.curAiId]

		if cfgData then
			self.clickTipsUWidget:SetActive(true)
			ClientTextUtils.setText(self.txtTipsUSDFText, pg.getLocalizationText(cfgData.feedback))
			self.clickTipsUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	else
		self.clickTipsUWidget:SetActive(false)
	end
end

function AIHelperLitUIComponent:tryShowUnTrackTip()
	local cfgData = AiAssistantData[self.curAiId]

	if not cfgData then
		return
	end

	ClientTextUtils.setText(self.txtTipsUSDFText, pg.getLocalizationText(cfgData.feedback_end))
	self.clickTipsUWidget:SetActive(true)
	self.clickTipsUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
end

function AIHelperLitUIComponent:onClickTrackBtn()
	if self.inTrack then
		self:cancelTrack()
	else
		self:doAIEvent()
	end
end

function AIHelperLitUIComponent:onClickTipBtn()
	self.aiHelperRoot:TryChangePage("Type", 1)

	self.tipsUButton.interactable = false

	self:doAIEvent()
end

function AIHelperLitUIComponent:clearShowTrackDelay()
	if self.closeTipTimer then
		self:killTimer(self.closeTipTimer)
	end

	self.closeTipTimer = nil
end

function AIHelperLitUIComponent:doAIEvent(id)
	local cfgData = AiAssistantData[self.curAiId]

	if not cfgData then
		pg.global.showBubbleMessageRaw(pg.getGameString("AI_CHAT_GOTO_FAIL"))

		return
	end

	if cfgData.event1 == TRACK_EVENT_NAME then
		self:doTrack(id)
		self:clearShowTrackDelay()

		self.closeTipTimer = self:startTimer(function()
			self:tryShowTrackTip()
		end, 0.2)
	else
		self.btnTrackUButton:TryChangePage("State", "Track")
		pg.me:doEventByData({
			cfgData.event1,
			{
				cfgData.value1 and cfgData.value1[1],
				{
					enable = true,
					img = cfgData.img,
					emo = cfgData.emo
				}
			}
		})
		pg.game.audio:playEvent("UI_NoviceGuide_DialogueAI_Track")
	end
end

function AIHelperLitUIComponent:doTrack(id)
	local cfgData = AiAssistantData[self.curAiId]

	if id then
		if id ~= self.curAiId then
			pg.global.showBubbleMessageRaw(pg.getGameString("AI_CHAT_GOTO_FAIL"))

			return
		end

		pg.global.ui:closeAllNormalPanel()
	end

	self.inTrack = true

	self.btnTrackUButton:TryChangePage("State", "Track")
	pg.me:doEventByData({
		cfgData.event1,
		{
			cfgData.value1 and cfgData.value1[1],
			{
				enable = true,
				img = cfgData.img,
				emo = cfgData.emo
			}
		}
	})
	pg.game.audio:playEvent("UI_NoviceGuide_DialogueAI_Track")
end

function AIHelperLitUIComponent:tryShowAITipOnCreate()
	local aIids = pg.me.AiHelperDetect and pg.me.AiHelperDetect.curAIIds or {}

	for aiId, _ in pairs(aIids) do
		self:insertAIHelperId(aiId)
	end
end

function AIHelperLitUIComponent:cancelTrack()
	if not self.inTrack then
		return
	end

	self.inTrack = false

	if self.btnTrackUButton then
		self.btnTrackUButton:TryChangePage("State", "Untrack")
	end

	local cfgData = AiAssistantData[self.curAiId]

	if cfgData then
		pg.me:doEventByData({
			cfgData.event1,
			{
				cfgData.value1 and cfgData.value1[1],
				{
					enable = false,
					img = cfgData.img,
					emo = cfgData.emo
				}
			}
		})
	end

	self:tryShowUnTrackTip()
	pg.game.audio:playEvent("UI_NoviceGuide_DialogueAI_Untrack")
end

function AIHelperLitUIComponent:showAITip(id)
	if id then
		if not self.uWidget:CheckURLLoaded() then
			if not self.loaded then
				self.loaded = true

				self.uWidget:LoadDefaultUrlManually(function(content)
					self:initViewManual()
					self:_showAITipImp(id)
				end)
			end
		else
			self:_showAITipImp(id)
		end
	end
end

function AIHelperLitUIComponent:_showAITipImp(id)
	self.curAiId = id

	local cfgData = AiAssistantData[id]

	self.tipsUButton.interactable = true

	local desc = pg.getLocalizationText(cfgData.chat)

	ClientTextUtils.setText(self.txtContentUBaseText, desc)

	if cfgData.event1 then
		pg.game.chat:recvSystemNotice(desc .. string.format(" <link=\"doAction\"><color=#5d90eb><u>%s</u></color></link>", pg.getGameString("AI_CHAT_GOTO")), "AI", function()
			self:doAIEvent(id)
		end, nil, "other")
	else
		pg.game.chat:recvSystemNotice(desc)
	end

	if pg.global.ui:runPlatformByMobile() then
		self.keyWordUButton:SetActive(false)
	elseif cfgData.action1 then
		self.trackBtnKeybinding.actionPath = cfgData.action1
		self.tipsBtnKeybinding.actionPath = cfgData.action1

		self.expandKeyHotKeyContent:SetHotKeyPaths(cfgData.action1)
		self.keyWordUButton:SetActive(true)
	else
		self.keyWordUButton:SetActive(false)
	end

	self.iconTrackUImage.url = cfgData.img
	self.aiAssistantUContainer.url = cfgData.emo

	self.aiHelperRoot:TryChangePage("Type", 0)
	self:show()
	self.aiHelperRoot:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	self.clickTipsUWidget:SetActive(false)
	self:startTimer(function()
		self.aiHelperRoot:TryChangePage("Type", 2)
		self:refreshAiTip()
	end, 5)
	facade:SendMessageCommand(MessageName.UI_AI_HELPER_LIT_SHOW, id)
end

function AIHelperLitUIComponent:insertAIHelperId(id)
	local cfgData = AiAssistantData[id]

	if not cfgData then
		return
	end

	if not pg.me:checkAiHelperEnterLimit(cfgData) then
		return
	end

	self.aiIdDict[id] = cfgData.priority

	if not self.curAiId then
		self:showAITip(id)
	end
end

function AIHelperLitUIComponent:refreshAiTipByEvent(info)
	local id = info.id
	local isInsert = info.isInsert

	if isInsert then
		local cfgData = AiAssistantData[id]

		if not cfgData or not pg.me:checkAiHelperEnterLimit(cfgData) then
			return
		end

		self:insertAIHelperId(id)
	else
		local cfgData = AiAssistantData[id]

		if cfgData.event1 == TRACK_EVENT_NAME and id == self.curAiId then
			self:cancelTrack()
		end

		self:removeAiHelperId(id)
	end
end

function AIHelperLitUIComponent:removeAiHelperId(id)
	self.aiIdDict[id] = nil

	self:refreshAiTip()
end

function AIHelperLitUIComponent:getNeedShowTipId()
	local id
	local priority = math.maxInt

	for aid, p in pairs(self.aiIdDict) do
		if p < priority then
			id = aid
			priority = p
		end
	end

	return id
end

function AIHelperLitUIComponent:refreshAiTip()
	local id = self:getNeedShowTipId()

	if id then
		if id ~= self.curAiId then
			self:showAITip(id)
		end
	else
		self:hide()
		self:cancelTrack()

		self.curAiId = nil
	end
end

return AIHelperLitUIComponent
