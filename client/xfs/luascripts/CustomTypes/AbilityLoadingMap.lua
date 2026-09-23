-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\AbilityLoadingMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local AbilityLoadingInfo = require("CustomTypes.AbilityLoadingInfo")
local Time = require("Core.Common.Time")
local AbilityLoadingMap = class.LiteClass("AbilityLoadingMap", CustomDict)

function AbilityLoadingMap:onEnterSpace(owner)
	local abilityMgr = pg.global.abilityMgr
	local now = Time.secondCache

	for abilityId, _ in pairs(owner.abilityMap) do
		local abilityTemplateData = abilityMgr:getAbilityTemplate(abilityId)

		if abilityTemplateData.maxLoadedCnt and abilityTemplateData.loadingCd then
			local abilityLoadingInfo = AbilityLoadingInfo({
				cd = abilityTemplateData.loadingCd,
				lastTime = now,
				cnt = abilityTemplateData.maxLoadedCnt,
				maxCnt = abilityTemplateData.maxLoadedCnt
			})

			self[abilityId] = abilityLoadingInfo
		end
	end

	self.nextLoadingTime = math.maxFloat

	self:loading(owner)
end

function AbilityLoadingMap:onAddAbility(abilityId)
	local abilityMgr = pg.global.abilityMgr
	local now = Time.secondCache
	local abilityTemplateData = abilityMgr:getAbilityTemplate(abilityId)

	if abilityTemplateData.maxLoadedCnt and abilityTemplateData.loadingCd then
		local abilityLoadingInfo = AbilityLoadingInfo({
			cd = abilityTemplateData.loadingCd,
			lastTime = now,
			cnt = abilityTemplateData.maxLoadedCnt,
			maxCnt = abilityTemplateData.maxLoadedCnt
		})

		self[abilityId] = abilityLoadingInfo
	end
end

function AbilityLoadingMap:loading(owner)
	if not owner.space then
		return
	end

	if not owner.abilityMap[self.nextLoadingAbilityId] then
		self.nextLoadingTime = math.maxFloat
	end

	local nextLoadingTime = self.nextLoadingTime
	local now = Time.secondCache
	local nextLoadingAbilityId

	for abilityId, abilityLoadingInfo in pairs(self) do
		if (type(abilityLoadingInfo) == "table" or type(abilityLoadingInfo) == "userdata") and abilityLoadingInfo.cnt < abilityLoadingInfo.maxCnt then
			local time = abilityLoadingInfo.lastTime + abilityLoadingInfo.cd

			if time < nextLoadingTime then
				nextLoadingTime = time
				nextLoadingAbilityId = abilityId
			end
		end
	end

	local delay = math.max(0, nextLoadingTime - now)

	if nextLoadingAbilityId then
		if self.timerId ~= 0 then
			owner:removeTimer(self.timerId)
		end

		self.nextLoadingTime = nextLoadingTime
		self.nextLoadingAbilityId = nextLoadingAbilityId
		self.timerId = owner:addTimer(delay, function()
			self.timerId = 0

			local abilityLoadingInfo = self[self.nextLoadingAbilityId]

			self[self.nextLoadingAbilityId].lastTime = Time.secondCache
			abilityLoadingInfo.cnt = math.min(abilityLoadingInfo.cnt + 1, abilityLoadingInfo.maxCnt)
			self.nextLoadingTime = math.maxFloat

			self:loading(owner)
		end)
	end
end

function AbilityLoadingMap:onAbilityStart(abilityId, owner)
	local abilityLoadingInfo = self[abilityId]

	if abilityLoadingInfo then
		abilityLoadingInfo.cnt = abilityLoadingInfo.cnt - 1

		if abilityLoadingInfo.cnt + 1 == abilityLoadingInfo.maxCnt then
			abilityLoadingInfo.lastTime = Time.secondCache
		end

		self:loading(owner)
	end
end

function AbilityLoadingMap:addLoadedCnt(abilityId, addCnt)
	local abilityLoadingInfo = self[abilityId]

	if not abilityLoadingInfo then
		return
	end

	abilityLoadingInfo.cnt = math.min(abilityLoadingInfo.cnt + addCnt, abilityLoadingInfo.maxCnt)
end

return AbilityLoadingMap
