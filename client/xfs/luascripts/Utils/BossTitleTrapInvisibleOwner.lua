-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\BossTitleTrapInvisibleOwner.lua

local BossTitleTrapInvisibleOwner = {}
local Utils = require("Common.Utils.Utils")
local BOSS_TITLE_TRAP_REASON = "trap"
local ownerMap = {}
local ownerCount = 0
local targetOwnerCount = {}

local function getTips()
	return pg and pg.global and pg.global.ui and pg.global.ui.tips
end

local function getBossTitleItem()
	local tips = getTips()

	if tips and tips.getBossTitleItem then
		return tips:getBossTitleItem()
	end
end

local function setBossTitleTrapVisible(visible, refreshBossTitleWhenVisible)
	local tips = getTips()

	if tips then
		tips:setBossTitleItemInvisibleReason(BOSS_TITLE_TRAP_REASON, visible)

		if visible and refreshBossTitleWhenVisible and tips.getBossTitleItem then
			local component = getBossTitleItem()

			if component and component.refreshBossTitle then
				component:refreshBossTitle()
			end
		end
	end
end

local function getTargetActorId(target)
	if not target or not target.actorId then
		return nil
	end

	if not Utils.isLabelBoss(target.label) and not Utils.isLabelElite(target.label) then
		return nil
	end

	return target.actorId
end

local function refreshBossTitleTrapVisibleForTarget(actorId)
	local component = getBossTitleItem()
	local curTarget = component and component.curTarget or nil

	if curTarget and curTarget.actorId == actorId then
		setBossTitleTrapVisible(not BossTitleTrapInvisibleOwner.isTargetHidden(actorId), false)
	end
end

function BossTitleTrapInvisibleOwner.acquire(owner, target)
	local actorId = getTargetActorId(target)

	if not owner or not actorId then
		return false
	end

	if not ownerMap[owner] then
		ownerMap[owner] = actorId
		ownerCount = ownerCount + 1
		targetOwnerCount[actorId] = (targetOwnerCount[actorId] or 0) + 1
	end

	refreshBossTitleTrapVisibleForTarget(actorId)

	return true
end

function BossTitleTrapInvisibleOwner.isTargetHidden(actorId)
	return actorId ~= nil and (targetOwnerCount[actorId] or 0) > 0
end

function BossTitleTrapInvisibleOwner.release(owner)
	if not owner or not ownerMap[owner] then
		return false
	end

	local actorId = ownerMap[owner]

	ownerMap[owner] = nil
	ownerCount = math.max(ownerCount - 1, 0)
	targetOwnerCount[actorId] = math.max((targetOwnerCount[actorId] or 1) - 1, 0)

	if targetOwnerCount[actorId] <= 0 then
		targetOwnerCount[actorId] = nil

		setBossTitleTrapVisible(true, true)
	else
		refreshBossTitleTrapVisibleForTarget(actorId)
	end

	return true
end

function BossTitleTrapInvisibleOwner.forceReleaseAll()
	ownerMap = {}
	ownerCount = 0
	targetOwnerCount = {}

	setBossTitleTrapVisible(true, false)
end

function BossTitleTrapInvisibleOwner.hasOwner(owner)
	return owner ~= nil and ownerMap[owner] ~= nil
end

return BossTitleTrapInvisibleOwner
