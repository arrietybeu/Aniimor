-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Help\\HelpView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HelpView = Class.LightClass("HelpView", UIView)

function HelpView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.panelObj = self.objectReference:GetRefValue("panelObj")
	self.closeBtn = self.objectReference:GetRefValue("closeBtn")
	self.helpInfoPanel = self.objectReference:GetRefValue("helpInfoPanel")
	self.searchInputField = self.objectReference:GetRefValue("searchInputField")
	self.trashBtn = self.objectReference:GetRefValue("trashBtn")
	self.titlePanel = self.objectReference:GetRefValue("titlePanel")
	self.titleText = self.objectReference:GetRefValue("titleText")
	self.titleNum = self.objectReference:GetRefValue("titleNum")
	self.optionList = self.objectReference:GetRefValue("optionList")
	self.contextPanel = self.objectReference:GetRefValue("contextPanel")
	self.contextImg = self.objectReference:GetRefValue("contextImg")
	self.redirectBtn = self.objectReference:GetRefValue("redirectBtn")
	self.contextNameText = self.objectReference:GetRefValue("contextNameText")
	self.scrollRectUScrollRect = self.objectReference:GetRefValue("scrollRectUScrollRect")
	self.prevBtn = self.objectReference:GetRefValue("prevBtn")
	self.prevBtnDisabledImg = self.objectReference:GetRefValue("prevBtnDisabledImg")
	self.nextBtn = self.objectReference:GetRefValue("nextBtn")
	self.nextBtnDisabledImg = self.objectReference:GetRefValue("nextBtnDisabledImg")
	self.pagePointList = self.objectReference:GetRefValue("pagePointList")
	self.emptySearchText = self.objectReference:GetRefValue("emptySearchText")
	self.root = self.objectReference:GetRefValue("root")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
	self.tabBarObjectCom = self.objectReference:GetRefValue("tabBarObjectCom")
	self.closeBtnUSDFText = self.objectReference:GetRefValue("closeBtnUSDFText")
	self.listTabUList = self.objectReference:GetRefValue("listTabUList")

	local objectReference = self.transform:GetComponent("ObjectReference")

	self.videoPlayer = objectReference:GetRefValue("videoPlayer")
	self.titleUSDFText = self.objectReference:GetRefValue("titleUSDFText")
	self.btnRedirectUSDFText = self.objectReference:GetRefValue("btnRedirectUSDFText")

	local inputOC = self.searchInputField:GetComponent("ObjectReference")

	self.inputDeleteBtn = inputOC:GetRefValue("btnDeleteUButton")
end

function HelpView:registerObjects()
	return
end

function HelpView:initView()
	return
end

function HelpView:setHelpInfo(info)
	if info == nil then
		return
	end

	if info.pic then
		LuaUIUtils.setUIViewVisible(self.contextImg, true)
		LuaUIUtils.setUIViewVisible(self.videoPlayer, false)

		self.contextImg.url = info.pic
	elseif info.video then
		LuaUIUtils.setUIViewVisible(self.contextImg, false)
		LuaUIUtils.setUIViewVisible(self.videoPlayer, true)

		self.videoPlayer.videoLoop = true
		self.videoPlayer.resID = info.video
	end

	if info.text then
		ClientTextUtils.setText(self.scrollRectUScrollRect.content, pg.getLocalizationText(info.text))
	end

	local showRedirectBtn = info.openUi or ToBool(info.course)

	if showRedirectBtn then
		LuaUIUtils.setUIViewVisible(self.redirectBtn, true)
	else
		LuaUIUtils.setUIViewVisible(self.redirectBtn, false)
	end
end

function HelpView:setListTab(visible, index)
	LuaUIUtils.setUIViewVisible(self.listTabUList, visible)

	if not visible then
		return
	end

	self.listTabUList:SelectItem(index)
end

return HelpView
