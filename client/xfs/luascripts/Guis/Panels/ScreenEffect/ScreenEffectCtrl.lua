-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ScreenEffect\\ScreenEffectCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local ScreenEffectCtrl = Class.LightClass("ScreenEffectCtrl", UICtrl)

ScreenEffectCtrl.messages = {
	[MessageName.PLAY_SCREEN_EFFECT] = {
		"playScreenEffect",
		false
	},
	[MessageName.STOP_SCREEN_EFFECT] = {
		"stopScreenEffect",
		false
	}
}

function ScreenEffectCtrl:ctor()
	UICtrl.ctor(self)

	self.waitingInfo = {}
	self.playingInfo = {}
end

function ScreenEffectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initUI(info)

	for res, _ in pairs(self.waitingInfo) do
		self.waitingInfo[res] = nil

		self:playScreenEffect(res)
	end

	self.waitingInfo = {}
end

function ScreenEffectCtrl:initUI(info)
	if info and info[1] then
		self.resName = info[1]
		self.waitingInfo[self.resName] = true
	end

	if info and info[2] and info[2] > 0 and info[1] then
		self.duration = info[2]
	end
end

function ScreenEffectCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.stopEffectTimer then
		self:stopScreenEffectRes(self.resName)
		self:killTimer(self.stopEffectTimer)

		self.stopEffectTimer = nil
	end
end

function ScreenEffectCtrl:playScreenEffect(resName)
	if self.playingInfo[resName] then
		return
	end

	if not self.view then
		self.waitingInfo[resName] = true

		pg.global.ui:open(UIConst.UI_ID_SCREEN_EFFECT)
	else
		self.waitingInfo[resName] = nil
		self.playingInfo[resName] = pg.global.resMgr:GetInstanceFromCacheByLua(resName, function(go, userData)
			self.playingInfo[resName] = go

			go.transform:SetParent(self.view.transform, false)

			if self.duration and self.resName and self.duration > 0 then
				self.stopEffectTimer = self:startTimer(function()
					self:stopScreenEffect(self.resName)
				end, self.duration)
			end
		end)
	end
end

function ScreenEffectCtrl:stopScreenEffectRes(resName)
	if self.waitingInfo[resName] then
		self.waitingInfo[resName] = nil
	end

	if self.playingInfo[resName] then
		if type(self.playingInfo[resName]) == "number" then
			pg.global.resMgr:TryCancelGOLoadAsyncTask(self.playingInfo[resName])
		else
			pg.global.resMgr:RemoveInstanceToCache(self.playingInfo[resName], true)
		end

		self.playingInfo[resName] = nil
	end
end

function ScreenEffectCtrl:stopScreenEffect(resName)
	self:stopScreenEffectRes(resName)

	if not next(self.waitingInfo) and not next(self.playingInfo) then
		pg.global.ui:close(UIConst.UI_ID_SCREEN_EFFECT)
	end
end

return ScreenEffectCtrl
