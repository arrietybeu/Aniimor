-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookScorePopup\\HomeBookScorePopupCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local Vector2 = CS.UnityEngine.Vector2
local HomeBookScorePopupCtrl = Class.LightClass("HomeBookScorePopupCtrl", UICtrl)
local SCORE_DURATION = 0.6

function HomeBookScorePopupCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("HOME_BOOK_CUR_RECORD_DATA"))
end

function HomeBookScorePopupCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		if self.isAnimating then
			self:skipAnimation()
		else
			self:closeAndOpenReward()
		end
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderEntry(button, data)

		if index >= #self.entries - 1 then
			self.itemAnimationDone = true

			if self.isAnimating then
				self:startScoreAnimation()
			end
		end

		button.interactable = false
	end
end

function HomeBookScorePopupCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.oldScore = info.oldScore or 0
	self.newScore = info.newScore or self.oldScore
	self.scoreDelta = self.newScore - self.oldScore
	self.entries = info.entries or {}
	self.closeCallback = info.onClose
	self.scoreAnimationDone = false
	self.itemAnimationDone = false
	self.isAnimating = true

	ClientTextUtils.setText(self.view.txtScoreTitleUSDFText, pg.getGameString("HOME_BOOK_CUR_SCORE"))
	ClientTextUtils.setText(self.view.txtScoreNumUSDFText, self.oldScore)
	ClientTextUtils.setText(self.view.txtAddUSDFText, string.format("+%d", self.scoreDelta))
	self:resetAddText(false)
	self:refreshGrade(self.oldScore)
	self:startItemAnimation()
end

function HomeBookScorePopupCtrl:refreshGrade(score)
	local gradeConfig = HomeBookDataUtils.getCurGradeConfig(score)

	if gradeConfig then
		self.view.iconCampUImage.url = gradeConfig.gradeIcon or ""

		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getLocalizationText(gradeConfig.title))
	else
		self.view.iconCampUImage.url = nil

		ClientTextUtils.setText(self.view.txtTitleUSDFText, "")
	end
end

function HomeBookScorePopupCtrl:refreshConsoleBarState(info)
	if not self.view then
		return
	end

	local pageCapacity = self.view.listUList:GetPageCapacity()
	local needSlide = pageCapacity > 0 and pageCapacity < self.view.listUList.itemCount

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomeCollectionScore_Slide", needSlide)
end

function HomeBookScorePopupCtrl:startScoreAnimation()
	self:refreshGrade(self.newScore)

	if self.scoreDelta == 0 then
		ClientTextUtils.setText(self.view.txtScoreNumUSDFText, self.newScore)

		self.scoreAnimationDone = true

		self:checkAnimationDone()

		return
	end

	self:resetAddText(false)

	local elapsed = 0

	self.scoreTimer = self:startTimer(function()
		elapsed = elapsed + Time.unscaledDeltaTime

		local progress = elapsed / SCORE_DURATION

		if progress > 1 then
			progress = 1
		end

		local score = self.oldScore + (self.newScore - self.oldScore) * progress

		ClientTextUtils.setText(self.view.txtScoreNumUSDFText, math.floor(score))

		if progress >= 1 then
			self:stopScoreTimer()
			ClientTextUtils.setText(self.view.txtScoreNumUSDFText, self.newScore)
			self:resetAddText(true)

			self.scoreAnimationDone = true

			self:checkAnimationDone()
			self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end, 0, true)
end

function HomeBookScorePopupCtrl:startItemAnimation()
	if #self.entries == 0 then
		self.itemAnimationDone = true

		self:startScoreAnimation()

		return
	end

	self.view.listUList:SetList(self.entries)
end

function HomeBookScorePopupCtrl:renderEntry(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	local txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")

	iconPropUImage.url = data.icon or ""

	ClientTextUtils.setText(txtAddUSDFText, string.format("+%d", data.addGrade or 0))
	button:TryChangePage("Quality", data.quality or 1)
	button:TryChangePage("Unlock", 0)

	button.luaClick = nil
end

function HomeBookScorePopupCtrl:skipAnimation()
	if not self.isAnimating then
		return
	end

	self:stopScoreTimer()
	ClientTextUtils.setText(self.view.txtScoreNumUSDFText, self.newScore)
	self:resetAddText(true)
	self:refreshGrade(self.newScore)

	self.scoreAnimationDone = true
	self.itemAnimationDone = true

	self:checkAnimationDone()
	self.view.listUList:SetEnableCustomInterval(false)
	self.view.listUList:SetList(self.entries)
end

function HomeBookScorePopupCtrl:resetAddText(active)
	self.view.addRectTransform.gameObject:SetActiveEx(active)
end

function HomeBookScorePopupCtrl:checkAnimationDone()
	if self.scoreAnimationDone and self.itemAnimationDone then
		self.isAnimating = false
	end
end

function HomeBookScorePopupCtrl:stopScoreTimer()
	if self.scoreTimer then
		self:killTimer(self.scoreTimer)

		self.scoreTimer = nil
	end
end

function HomeBookScorePopupCtrl:closeAndOpenReward()
	local callback = self.closeCallback

	self.closeCallback = nil

	self:closePanel()

	if callback then
		callback()
	end
end

function HomeBookScorePopupCtrl:onClose()
	if self.isAnimating then
		self:skipAnimation()

		return
	end

	self:closeAndOpenReward()
end

function HomeBookScorePopupCtrl:onDestroy()
	self:stopScoreTimer()
	UICtrl.onDestroy(self)
end

return HomeBookScorePopupCtrl
