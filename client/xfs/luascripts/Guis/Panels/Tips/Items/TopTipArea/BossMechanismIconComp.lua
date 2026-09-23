-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossMechanismIconComp.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("BossMechanismIconComp")
local BossMechanismIconComp = Class.LightClass("BossMechanismIconComp")

function BossMechanismIconComp:ctor(owner)
	self.owner = owner
	self.pendingMap = nil
	self.dataCache = nil
	self.iconInit = false
	self.iconType = nil
	self.iconMax = nil
	self.lastNum = nil
	self.rootWidget = nil
	self.txtNum = nil
	self.slider = nil
	self.vxRefresh = nil
end

function BossMechanismIconComp:onBind(objectReference)
	self.loadVersion = (self.loadVersion or 0) + 1
	self.bossPropertyUContainer = objectReference:GetRefValue("bossPropertyUContainer")
end

function BossMechanismIconComp:setPendingMap(map)
	self.pendingMap = map
end

function BossMechanismIconComp:refresh()
	local owner = self.owner
	local map = self.pendingMap or {}
	local curActorId = owner.curTarget and owner.curTarget.actorId or nil
	local data = curActorId and map[curActorId] or nil
	local cache = self.dataCache

	if not data then
		if cache then
			self:destroy()

			self.dataCache = nil
		end

		return
	end

	if data.assetId == nil or data.type == nil or data.max == -1 or data.cur == -1 then
		return
	end

	if not cache or cache.actorId ~= data.actorId then
		self.dataCache = {
			stage = false,
			actorId = data.actorId,
			type = data.type
		}

		self:init(data.assetId, data.type, data.max)

		return
	end

	if not self.iconInit then
		return
	end

	local typeChanged = cache.type ~= data.type

	if typeChanged then
		self.iconType = data.type

		self:applyTypeVisibility()

		cache.type = data.type
	end

	if typeChanged or cache.cur ~= data.cur or cache.max ~= data.max then
		self:setProgress(data.cur, data.max)

		cache.cur = data.cur
		cache.max = data.max
	end

	if data.pendingFlash then
		self:flash()

		data.pendingFlash = false
	end

	if cache.stage ~= data.stage then
		if data.stage then
			self:showVX()
		else
			self:hideVX()
		end

		cache.stage = data.stage
	end
end

function BossMechanismIconComp:init(assetId, iconType, max)
	self.iconType = iconType
	self.iconMax = max

	if self.iconInit then
		self:destroy()
	end

	local container = self.bossPropertyUContainer

	self.loadVersion = (self.loadVersion or 0) + 1

	local loadVersion = self.loadVersion

	container:SetUrlWithCallback(assetId, function(content)
		if self.loadVersion ~= loadVersion or self.bossPropertyUContainer ~= container then
			return
		end

		if not content then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("BossMechanismIconComp: Asset %s not exist", assetId)
			end

			return
		end

		local objectReference = content.transform:GetComponent("ObjectReference")

		self.rootWidget = content
		self.txtNum = objectReference:GetRefValue("txtNum")
		self.slider = objectReference:GetRefValue("sliderUSlider")

		local temp = objectReference:GetRefValue("vXRefreshUContainer")

		temp.gameObject:SetActiveEx(true)

		self.vxRefresh = temp.content:GetComponent("Animation")
		self.iconInit = true

		self:applyTypeVisibility()
		self:refresh()
	end)
end

function BossMechanismIconComp:applyTypeVisibility()
	if NotNil(self.slider) then
		self.slider.gameObject:SetActiveEx(self.iconType == UIConst.BossMechanismIconType.Slider or self.iconType == UIConst.BossMechanismIconType.MinMax)
	end

	if NotNil(self.txtNum) then
		self.txtNum.gameObject:SetActiveEx(self.iconType == UIConst.BossMechanismIconType.MinMax)
	end
end

function BossMechanismIconComp:destroy(clearData)
	self.loadVersion = (self.loadVersion or 0) + 1

	if self.bossPropertyUContainer and NotNil(self.bossPropertyUContainer) then
		self.bossPropertyUContainer:DestroyContent()
	end

	self.rootWidget = nil
	self.txtNum = nil
	self.slider = nil
	self.vxRefresh = nil
	self.lastNum = nil
	self.iconInit = false

	if clearData then
		self.pendingMap = nil
		self.dataCache = nil
	end
end

function BossMechanismIconComp:showVX()
	self.vxRefresh:Play()
	self.rootWidget:TryChangePage("Stage", 1)
end

function BossMechanismIconComp:hideVX()
	self.vxRefresh:Play()
	self.rootWidget:TryChangePage("Stage", 0)
end

function BossMechanismIconComp:setProgress(num, max)
	self.iconMax = max

	if self.iconType == UIConst.BossMechanismIconType.Slider or self.iconType == UIConst.BossMechanismIconType.MinMax then
		self.slider.value = num / max
	end

	if self.iconType == UIConst.BossMechanismIconType.MinMax then
		ClientTextUtils.setText(self.txtNum, string.format("%s/%s", num, max))
	end

	if self.lastNum ~= nil and self.lastNum ~= num and num == 0 then
		self.vxRefresh:Play()
	end

	self.lastNum = num
end

function BossMechanismIconComp:flash()
	self.rootWidget:TryChangePage("AddLight", 0)
	self.rootWidget:TryChangePage("AddLight", 1)
end

return BossMechanismIconComp
