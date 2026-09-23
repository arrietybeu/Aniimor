-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetInheritResult\\PetInheritResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetInheritResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetInheritResultView = Class.LightClass("PetInheritResultView", UIView)

function PetInheritResultView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.petHeadBeforeUComponent = objectReference:GetRefValue("petHeadBeforeUComponent")
	self.petHeadAfterUComponent = objectReference:GetRefValue("petHeadAfterUComponent")
	self.returnItemsListUList = objectReference:GetRefValue("returnItemsListUList")
	self.txtReturnUSDFText = objectReference:GetRefValue("txtReturnUSDFText")
	self.itemReturnUWidget = objectReference:GetRefValue("itemReturnUWidget")
end

function PetInheritResultView:registerObjects()
	return
end

function PetInheritResultView:initView()
	return
end

return PetInheritResultView
