-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientCaptureUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local SysConfigData = require("Data.sys_config_data")
local NoticeDef = require("Common.NoticeDef")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local PlayableConst = require("Common.Const.PlayableConst")
local AudioConst = require("Const.AudioConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local lume = require("Core.Common.lume")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local CaptureConst = require("Common.Const.CaptureConst")
local ItemData = require("Data.item_data")
local PetConfigData = require("Data.pet_config_data")
local Vector3 = Vector3
local Quaternion = Quaternion
local ClientCaptureUtils = {}

function ClientCaptureUtils.isBossCatchFreeBall(itemId)
	if not itemId then
		return false
	end

	itemId = tonumber(itemId)

	local isFreeBall = (PetConfigData and PetConfigData.bossCatchFreeBall or EMPTY_TABLE)[itemId]

	return isFreeBall and isFreeBall == 1
end

function ClientCaptureUtils.getDefaultBossCatchFreeBallId()
	local freeBallId

	for itemId, enabled in pairs(PetConfigData.bossCatchFreeBall or EMPTY_TABLE) do
		itemId = tonumber(itemId)

		if itemId and enabled and ItemData[itemId] and ClientCaptureUtils.checkBallCanThrow(itemId) and (not freeBallId or itemId < freeBallId) then
			freeBallId = itemId
		end
	end

	return freeBallId
end

function ClientCaptureUtils.checkBallItem(ballItemId, showMsg)
	if not ballItemId or ClientUtils.getItemCountById(ballItemId) <= 0 then
		if showMsg then
			pg.global.showBubbleMessage(NoticeDef.ITEM_LACK_CANT_THROW)

			if pg.me:checkEnterCatchMode() then
				pg.me:playTrivialUpperAnimation(PlayableConst.HoldBall_NoBall)
			end
		end

		return false
	end

	return true
end

function ClientCaptureUtils.isPaidBall(itemId)
	local castItemId = Utils.itemId2CastItemId(itemId)
	local castData = castItemId and castItemData[castItemId]

	return castData and castData.isSpecialSlot == 1 or false
end

function ClientCaptureUtils.getEquippedPaidBallItemIds()
	local itemIds = {}
	local eliteSlot = pg.me and pg.me.invEliteSlotBall

	if not eliteSlot then
		return itemIds
	end

	local count = lume.count(eliteSlot)

	for idx = 1, count do
		local itemId = eliteSlot[idx]

		if itemId and itemId ~= 0 and ItemData[itemId] and ClientCaptureUtils.isPaidBall(itemId) and ClientUtils.getItemCountById(itemId) > 0 then
			itemIds[#itemIds + 1] = itemId
		end
	end

	return itemIds
end

function ClientCaptureUtils.getFirstUsableNormalBallItemId()
	if not pg.me then
		return nil
	end

	for _, normalItemId in pairs(pg.me.invQuickSlotBall or EMPTY_TABLE) do
		if normalItemId ~= 0 and ItemData[normalItemId] and not ClientCaptureUtils.isPaidBall(normalItemId) and ClientCaptureUtils.checkBallCanThrow(normalItemId) and ClientUtils.getItemCountById(normalItemId) > 0 then
			return normalItemId
		end
	end

	return nil
end

function ClientCaptureUtils.hasUsableNormalBall()
	return ClientCaptureUtils.getFirstUsableNormalBallItemId() ~= nil
end

function ClientCaptureUtils.getEnterCatchModeItemId()
	local hudV2 = pg.global.ui and pg.global.ui.hudV2
	local itemId = hudV2 and hudV2:getCurSelectPropId()

	if not pg.me then
		return itemId
	end

	local isSpecialMode = ClientUtils.isInDouYinOfflineScene() or Utils.isPlayerInSpaceCatchRogueDungeon(pg.me)

	if isSpecialMode then
		return itemId
	end

	if itemId and ItemData[itemId] and not ClientCaptureUtils.isPaidBall(itemId) and ClientCaptureUtils.checkBallCanThrow(itemId) and ClientUtils.getItemCountById(itemId) > 0 then
		return itemId
	end

	local normalItemId = ClientCaptureUtils.getFirstUsableNormalBallItemId()

	if normalItemId then
		return normalItemId
	end

	local equippedPaidBallItemIds = ClientCaptureUtils.getEquippedPaidBallItemIds()

	return equippedPaidBallItemIds[1]
end

function ClientCaptureUtils.hasBall(showMsg, itemId)
	local isBossCatchUI = false

	if not itemId then
		if pg.global.ui:checkUIShow(UIConst.UI_ID_CATCHBOSS_NEW) then
			itemId = pg.global.ui.catchBossNew:getCurSelectPropId()
			isBossCatchUI = true
		elseif pg.global.ui:checkUIShow(UIConst.UI_ID_CATCHBOSS) then
			itemId = pg.global.ui.catchBoss:getCurSelectPropId()
			isBossCatchUI = true
		else
			itemId = pg.global.ui.hudV2:getCurSelectPropId()
		end
	end

	if isBossCatchUI and ClientCaptureUtils.isBossCatchFreeBall(itemId) then
		return true
	end

	if not ClientCaptureUtils.checkBallItem(itemId, showMsg) then
		return false
	end

	return true
end

function ClientCaptureUtils.getFromBehindCatchProb(player, hitEntity, itemId)
	local context = CatchProbContext.clientGet(hitEntity, itemId)

	return context.finalProb, context
end

function ClientCaptureUtils.catchUIColorRate(player, hitEntity, itemId)
	local context = CatchProbContext.clientGet(hitEntity, itemId)
	local rate = context.finalProb
	local result = ClientCaptureUtils.getColorPageByRate(rate)

	return result, context
end

function ClientCaptureUtils.getColorPageByRate(rate)
	if rate <= 0 then
		return 4
	elseif rate >= 1 then
		return 5
	else
		for idx, segRate in pairs(SysConfigData.CATCH_SUCCESS_COLOR_RATE) do
			if rate < segRate then
				return 4 - idx
			end
		end

		return 1
	end
end

function ClientCaptureUtils.getBossCatchPageByRate(rate)
	rate = rate or 0

	for idx, segRate in ipairs(SysConfigData.CATCH_SUCCESS_COLOR_RATE) do
		if rate < segRate then
			return 3 - idx
		end
	end

	return 0
end

function ClientCaptureUtils.getSfxByRate(rate)
	if rate >= 1 then
		return AudioConst.EVENT_CATCH_RATE_GRANTEED
	elseif rate <= 0 then
		return AudioConst.EVENT_CATCH_RATE_FAIL
	end

	local sep = SysConfigData.CATCH_SUCCESS_COLOR_RATE[2]

	if rate < sep then
		return AudioConst.EVENT_CATCH_RATE_LOW
	else
		return AudioConst.EVENT_CATCH_RATE_HIGH
	end
end

local proxy2Context = {
	BagItem = "ParabolaThrowContext",
	MagicBall = "MagicCatchContext",
	TrapBall = "TrapBallContext",
	FishingCaptureBall = "CameraThrowContext",
	CatchBall = "CameraThrowContext",
	BigBall = "DriveBallContext"
}

function ClientCaptureUtils.getThrowContext(player, itemId)
	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]
	local contextName = proxy2Context[ballData.proxy]

	return require("GameApp.Capture.Context." .. contextName).new(player, itemId)
end

function ClientCaptureUtils.getItemBossCatchValid(bossEntity)
	local freeBallId = ClientCaptureUtils.getDefaultBossCatchFreeBallId()

	if freeBallId then
		return freeBallId
	end

	local itemId = pg.global.ui.hudV2:getCurSelectPropId()
	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]

	if ballData and ballData.canQuickCaptureInHand and ClientUtils.getItemCountById(itemId) > 0 then
		return itemId
	end

	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, ItemConst.INV_TYPE_BALL) or {}
	local propList = {}

	for _, packSlot in bag:items() do
		local item = LuaUIUtils.getItemClientInfoById(packSlot.id)

		itemId = item.itemId

		if itemId ~= 0 and ItemData[itemId] then
			local count = ClientUtils.getItemCountById(itemId)
			local context = CatchProbContext.clientGet(bossEntity, itemId)
			local item_data = {
				itemId = itemId,
				icon = ItemData[itemId].icon,
				name = ItemData[itemId].itemName,
				count = count,
				prob = context.finalProb
			}

			castItemId = Utils.itemId2CastItemId(itemId)
			ballData = castItemData[castItemId]

			if count > 0 and ballData and ballData.canQuickCaptureInHand then
				propList[#propList + 1] = item_data
			end
		end
	end

	propList = lume.sort(propList, function(a, b)
		return a.prob > b.prob
	end)

	if #propList > 0 then
		return propList[1].itemId
	else
		return
	end
end

function ClientCaptureUtils.getBallFinalPos(entity, ballStartPos, ballHitPos, offset)
	local entityPos = entity:getPositionAgentPosition()
	local cacheV3 = Vector3.getFromCache()
	local entityPosXZ = Vector3.New(entityPos.x, 0, entityPos.z)
	local ballStartPosXZ = Vector3.New(ballStartPos.x, 0, ballStartPos.z)
	local ballHitPosXZ = Vector3.New(ballHitPos.x, 0, ballHitPos.z)

	cacheV3 = Vector3.CrossByCache(ballStartPosXZ - entityPosXZ, ballStartPosXZ - ballHitPosXZ, cacheV3)

	local rot
	local lor = false

	if cacheV3.y < 0 then
		rot = Quaternion.Euler(0, 60, 0)
		lor = true
	else
		rot = Quaternion.Euler(0, -60, 0)
		lor = false
	end

	local radius = entity.eModel.radius + 0.7
	local height = entity.eModel.height

	cacheV3 = entityPos + rot * (ballStartPos - entityPos):Normalize() * radius + Vector3(0, height, 0)

	if offset then
		cacheV3 = cacheV3 + offset
	end

	local finalPos = cacheV3:ForceClone()

	Vector3.returnToCache(cacheV3)

	return finalPos, lor
end

function ClientCaptureUtils.getParticleConfig(puppetEnt, ballEnt, catchBallFinalPos)
	local config = {}

	config.farDis = pgUtils.GetDissolveEffectDistance(puppetEnt.id, ballEnt.id, true, catchBallFinalPos)
	config.closeDis = pgUtils.GetDissolveEffectDistance(puppetEnt.id, ballEnt.id, false, catchBallFinalPos)
	config.startValue = config.closeDis
	config.endValue = 2 * config.farDis - config.closeDis
	config.border = config.farDis - config.closeDis
	config.failStartValue = (config.farDis - config.closeDis) * 0.2 + config.farDis

	return config
end

function ClientCaptureUtils.fillCatchBallHitConfig(config, ball)
	local ballHitPos = ball.ballHitPos
	local hitEntity = pg.getEntityByActorId(ball.hitEntityActorId)

	if ballHitPos and hitEntity and hitEntity.eModel and not config.FinalPos then
		local finalPos, lorR = ClientCaptureUtils.getBallFinalPos(hitEntity, ball.ballStartPos, ballHitPos, ball.finalPosOffset)
		local dissolveConfig = ClientCaptureUtils.getParticleConfig(hitEntity, ball, finalPos)

		config.BallStartPos = ball.ballStartPos
		config.HitPos = ballHitPos
		config.FinalPos = finalPos
		config.LorR = lorR
		config.StartValue = dissolveConfig.startValue
		config.EndValue = dissolveConfig.endValue
		config.Border = dissolveConfig.border
		config.FailStartValue = dissolveConfig.failStartValue
		config.PlayerActorId = ball.master.actorId
		config.HitEntActorId = ball.hitEntityActorId
		config.FinalProb = ball.finalProb
	end
end

local captureTimelineMap = {
	CatchBall = {
		[CaptureConst.SESSION_STATE_HIT] = {
			CaptureConst.CAPTURE_NORMAL_BALL_ABSORB_TIMELINE,
			CaptureConst.CAPTURE_NORMAL_BALL_STRUGGLE_TIMELINE
		},
		[CaptureConst.SESSION_STATE_SETTLED] = CaptureConst.CAPTURE_NORMAL_BALL_RESULT_TIMELINE
	},
	BigBall = {
		[CaptureConst.SESSION_STATE_HIT] = CaptureConst.CAPTURE_BIG_BALL_STRUGGLE_TIMELINE,
		[CaptureConst.SESSION_STATE_SETTLED] = CaptureConst.CAPTURE_BIG_BALL_RESULT_TIMELINE
	}
}

function ClientCaptureUtils.getCaptureTimelineId(proxy, sessionState, param)
	if param then
		local idx = unpack(param)

		return captureTimelineMap[proxy] and captureTimelineMap[proxy][sessionState] and captureTimelineMap[proxy][sessionState][idx] or -1
	else
		return captureTimelineMap[proxy] and captureTimelineMap[proxy][sessionState] or -1
	end
end

function ClientCaptureUtils.getCaptureTimelineShowIdx(prob)
	local funcId = 3066
	local w1, w2, w3, w4 = Utils.formulaSafeCall(-1, funcId, prob)
	local result = ClientCaptureUtils.getFloatWeightedRandomIndex({
		w1,
		w2,
		w3,
		w4
	})

	return result
end

function ClientCaptureUtils.getFloatWeightedRandomIndex(weights)
	local totalWeight = 0

	for _, w in ipairs(weights) do
		totalWeight = totalWeight + w
	end

	if totalWeight <= 0 then
		return 1
	end

	local rand = math.random() * totalWeight
	local currentSum = 0

	for i, w in ipairs(weights) do
		currentSum = currentSum + w

		if rand < currentSum then
			return i
		end
	end

	return #weights
end

function ClientCaptureUtils.getEvenlyDistributedPoints(center, radius, count)
	local points = {}

	if not center or not radius or not count or count <= 0 then
		return points
	end

	local step = 2 * math.pi / count

	for i = 0, count - 1 do
		local angle = step * i
		local x = center.x + radius * math.cos(angle)
		local z = center.z + radius * math.sin(angle)

		points[i + 1] = Vector3.New(x, center.y, z)
	end

	return points
end

function ClientCaptureUtils.checkBallCanThrow(itemId)
	if not itemId then
		return false
	end

	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]

	if not ballData then
		return false
	end

	if ballData.proxy == "FishingCaptureBall" then
		return false
	end

	return true
end

function ClientCaptureUtils.isBigBall(itemId)
	if not itemId then
		return false
	end

	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]

	return ballData ~= nil and ballData.proxy == "BigBall"
end

return ClientCaptureUtils
