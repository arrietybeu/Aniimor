-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogBaptizeTip\\PetTransmogBaptizeTipCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogBaptizeTipCtrl = Class.LightClass("PetTransmogBaptizeTipCtrl", UICtrl)

PetTransmogBaptizeTipCtrl.messages = {}

function PetTransmogBaptizeTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setContext(info and info.petId or nil, info and info.holeIndex or nil)
end

function PetTransmogBaptizeTipCtrl:addListener()
	if self.view.rootCmp then
		function self.view.rootCmp.luaCloseAction()
			self:close()
		end
	end
end

function PetTransmogBaptizeTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.iData = info

	self.model:setContext(info and info.petId or nil, info and info.holeIndex or nil)
end

function PetTransmogBaptizeTipCtrl:onShow()
	self:refreshView()

	if self.view.rootCmp then
		self.view.rootCmp:SetAutoVertical(false, true)
		self.view.rootCmp:SetVerAlignment(CS.XGUI.EVerticalAlignment.Top)
		self.view.rootCmp:OpenPopup(self.iData and self.iData.targetRect)
	end
end

function PetTransmogBaptizeTipCtrl:refreshView()
	if not self.view then
		return
	end

	local petId = self.model:getPetId()
	local holeIndex = self.model:getHoleIndex()

	if not petId or not holeIndex then
		return
	end

	ClientTextUtils.setText(self.view.titleUSDFText, PetTransmogUtils.getHoleName(petId, holeIndex))

	local tipKey = PetTransmogUtils.Tips[holeIndex]

	ClientTextUtils.setText(self.view.desUSDFText, tipKey and pg.getGameString(tipKey) or "")

	if self.view.rootCmp then
		local scheme = PetTransmogUtils.getCurrentDisplayScheme(petId)

		self.view.rootCmp:TryChangePage("Quality", PetTransmogUtils.getHoleQuality(scheme, holeIndex))
	end
end

return PetTransmogBaptizeTipCtrl
