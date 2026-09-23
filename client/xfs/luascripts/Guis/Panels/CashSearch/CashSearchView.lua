-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashSearch\\CashSearchView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CashSearchView = Class.LightClass("CashSearchView", UIView)

function CashSearchView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.inputFieldUTMPInputField = objectReference:GetRefValue("inputFieldUTMPInputField")
	self.listUList = objectReference:GetRefValue("listUList")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtBaseSearch = objectReference:GetRefValue("txtBaseSearch")
	self.btnBGClose = objectReference:GetRefValue("btnBGClose")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.txtEmpty = objectReference:GetRefValue("txtEmpty")
	self.btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
end

function CashSearchView:registerObjects()
	return
end

function CashSearchView:setupSearchView()
	ClientTextUtils.setText(self.txtTitle, pg.getGameString("SHOP_SEARCH"))
	ClientTextUtils.setText(self.txtEmpty, pg.getGameString("SHOP_SEARCH_NONE"))
	ClientTextUtils.setText(self.txtBaseSearch, pg.getGameString("SHOP_ENTER"))
end

function CashSearchView:setListData(listData, showEmpty)
	if showEmpty then
		self.listUList.gameObject:SetActiveEx(false)

		if self.emptyUWidget then
			self.emptyUWidget:SetActive(true)
		end
	else
		self.listUList.gameObject:SetActiveEx(true)

		if self.emptyUWidget then
			self.emptyUWidget:SetActive(false)
		end

		self.listUList:SetList(listData)
	end
end

function CashSearchView:clearInput()
	if self.inputFieldUTMPInputField then
		self.inputFieldUTMPInputField.text = ""
	end
end

function CashSearchView:setInputText(text)
	if self.inputFieldUTMPInputField then
		self.inputFieldUTMPInputField.text = text or ""
	end
end

return CashSearchView
