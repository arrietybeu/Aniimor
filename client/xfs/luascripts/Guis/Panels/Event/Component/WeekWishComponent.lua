-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\WeekWishComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("WeekWishComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local GameEventData = require("Data.game_event_data")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ActivityPetVoteData = require("Data.activity_pet_vote_data")
local WeekWishComponent = Class.LightClass("WeekWishComponent", EventContainerComponent)

function WeekWishComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.rootWidget = self.objectReference:GetRefValue("rootWidget")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.txtBeginTipsUBaseText = self.objectReference:GetRefValue("txtBeginTipsUBaseText")
	self.txtPrayersTipsUBaseText = self.objectReference:GetRefValue("txtPrayersTipsUBaseText")
	self.txtEggAppearUBaseText = self.objectReference:GetRefValue("txtEggAppearUBaseText")
	self.btnEggUButton = self.objectReference:GetRefValue("btnEggUButton")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
end

function WeekWishComponent:addListener()
	function self.listPetUList.luaRenderItem(button, index, data)
		self:onRenderPrayersItem(button, index, data)
	end

	function self.btnEggUButton.luaClick()
		local eventId = ActivityPetVoteData[self.eventPhase].event

		if not eventId then
			logger:error("WeekWishComponent:onBtnGoClick eventId is nil curActivityId is:%s ", self.eventId)

			return
		end

		pg.global.showConfirmMsgRaw(pg.getGameString("PET_RESEARCH_TEXT1"), pg.getGameString("MAP_QUICK_TELEPORT_TIP_1"), function()
			pg.me:doEvent(eventId)
		end, nil)
	end
end

function WeekWishComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)
	pg.me:pullActivityVotePetData(self.eventPhase, self.eventType)
end

function WeekWishComponent:onEnterPlayEvent()
	pg.game.audio:playEvent("SFX_UI_ImoWish_MoveIn")
end

function WeekWishComponent:refreshPage()
	local eventData = GameEventData[self.eventId]

	if not eventData then
		return
	end

	local wishInfo = self.model:getWeekWishInfo(self.eventPhase)

	if not wishInfo then
		logger:error("WeekWishComponent:refreshPage can not getWeekWishInfo curWeekWishId is:%s", self.eventPhase)

		return
	end

	local now, voteStartDayTime, voteEndDayTime, eventStartDayTime, eventEndDayTime, state = unpack(wishInfo)

	self.rootWidget:TryChangePage("State", state)

	local weekWishData = ActivityPetVoteData[self.eventPhase]
	local themeType = weekWishData.type

	self.rootWidget:TryChangePage("Theme", themeType)

	self._curState = state

	local countDownTime
	local isWish = state <= self.model.WeekWishPageState.Prayers

	if isWish then
		countDownTime = voteEndDayTime

		ClientTextUtils.setText(self.txtPrayersTipsUBaseText, pg.getGameString("WEEKEND_PRAY_TIP2"))
	else
		countDownTime = eventEndDayTime

		ClientTextUtils.setText(self.txtPrayersTipsUBaseText, pg.getGameString("WEEKEND_PRAY_TIP4"))
	end

	local countDownActive = self._curState ~= self.model.WeekWishPageState.EggGet

	self:setEventTitle(self.eventTitleUContainer, countDownActive and countDownTime or nil, nil, isWish and pg.getGameString("EVENT_TIME_TIP_2") or pg.getGameString("EVENT_TIME_TIP_3"))
	self.listPetUList:SetList(self.model:getWeekWishPetList(self.eventPhase))
	ClientTextUtils.setText(self.txtBeginTipsUBaseText, pg.getGameString("WEEKEND_PRAY_TIP1"))
	ClientTextUtils.setText(self.txtEggAppearUBaseText, pg.getGameString("WEEKEND_PRAY_TIP3"))

	if state == self.model.WeekWishPageState.EggAppear then
		local isShow = self.model:isWeekWishEggRewardCanGet(self.eventPhase)

		pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_WEEK_WISH_REWARD, self.btnEggUButton, isShow == true, RedDotConst.RedDotStyle.POINT)
	end
end

function WeekWishComponent:onBtnWishClick(templateId)
	if pg.me then
		local title = pg.getFormatText(pg.getGameString("EVENT_WEEK_PRAY_PLAYER_TIPS_TITLE"), pg.me.playerName or "")

		pg.global.showConfirmMsgRaw(title, pg.getGameString("EVENT_WEEK_PRAY_PLAYER_TIPS_CONTENT"), function()
			pg.me:reqActivityVotePet(self.eventId, self.eventPhase, templateId)
		end, nil)
	end
end

function WeekWishComponent:onRenderPrayersItem(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgPetUImage = objectReference:GetRefValue("imgPetUImage")
	local txtPetNameUBaseText = objectReference:GetRefValue("txtPetNameUBaseText")
	local txtFormUBaseText = objectReference:GetRefValue("txtFormUBaseText")
	local iconCareer = objectReference:GetRefValue("iconCareer")
	local txtCareer = objectReference:GetRefValue("txtCareer")
	local btnDetailsUButton = objectReference:GetRefValue("btnDetailsUButton")
	local btnPrayersUButton = objectReference:GetRefValue("btnPrayersUButton")
	local txtTipsUBaseText = objectReference:GetRefValue("txtTipsUBaseText")
	local txtPercentUBaseText = objectReference:GetRefValue("txtPercentUBaseText")
	local txtChoosePercent = objectReference:GetRefValue("txtChoosePercent")
	local state

	state = self._curState == self.model.WeekWishPageState.Begin and "Normal" or pg.me.activityVotePet[self.eventPhase] == data.templateId and "Choose" or "Prayers"

	button:TryChangePage("Prayers", state)

	imgPetUImage.url = data.iconName

	ClientTextUtils.setText(txtPetNameUBaseText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(txtFormUBaseText, data.formName)

	iconCareer.url = data.petFunctionIcon

	ClientTextUtils.setText(txtCareer, pg.getLocalizationText(data.petFunctionText))

	function btnDetailsUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
			templateId = data.templateId
		})
	end

	function btnPrayersUButton.luaClick()
		self:onBtnWishClick(data.templateId)
	end

	if self._curState ~= self.model.WeekWishPageState.Begin then
		local cnt, sum = self.model:getWeekWishPetVoteInfo(self.eventPhase, data.templateId)
		local votePercent = cnt ~= nil and math.floor(cnt / sum * 100) or 0

		ClientTextUtils.setText(txtTipsUBaseText, string.format(pg.getGameString("EVENT_WEEK_PRAY_PLAYER_RATIO"), votePercent))

		if pg.me.activityVotePet[self.eventPhase] then
			ClientTextUtils.setText(txtPercentUBaseText, string.format("%s%%", "20"))
			ClientTextUtils.setText(txtChoosePercent, string.format("%s%%", "60"))
		else
			ClientTextUtils.setText(txtPercentUBaseText, string.format("%s%%", "33"))
		end
	end
end

function WeekWishComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return WeekWishComponent
