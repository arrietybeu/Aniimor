-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\TestManager.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local EntityManager = require("Core.Common.EntityManager")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local TimerManager = require("Core.Timer.TimerManager")
local dm = require("Common.DebugManager")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local OpDef = require("Common.OpDef")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local DungeonConst = require("Common.Const.DungeonConst")
local PetData = require("Data.pet_data")
local AbilityConst = require("Common.Const.AbilityConst")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local env = {
	isInTelnetConsole = true
}

setmetatable(env, {
	__index = _G
})
setfenv(1, env)

local TEST_CHARACTER_RAND_ITEM = dm.isTesting("character_rand_item")
local TEST_PROP_ENHANCE_ITEM = dm.isTesting("prop_enhance_item")
local TEST_PROP_NAME_CHANGE = dm.isTesting("prop_name_change")
local TEST_CLIENT_TRIGGER_CHANGE = dm.isTesting("client_trigger_change")
local TEST_TEAM_INVITE = dm.isTesting("team_invite")
local TEST_HOMELAND_PET = dm.isTesting("homeland_pet")
local TEST_SPACE_SPAWNER = dm.isTesting("space_spawner")
local TEST_PROP_PREVIEW = dm.isTesting("prop_preview")
local TEST_REMOTE_SYNC = dm.isTesting("remote_sync")
local TEST_SOCIAL = dm.isTesting("social")
local TEST_CATCH_ROGUE = dm.isTesting("catch_rogue")
local TEST_BOSS_CATCH = dm.isTesting("boss_catch")
local TEST_PHOTO_PRESET = dm.isTesting("photo_preset")
local TEST_ROBEGG_CATCH = dm.isTesting("robegg_catch")
local TEST_HOME_MANAGE = dm.isTesting("home_manage")
local TEST_HOME_CAMP = dm.isTesting("home_camp")
local TEST_USER_DATA = dm.isTesting("user_data")
local TEST_FISHING_CAPTURE = dm.isTesting("fishing_capture")
local TEST_TIPS_TIMELINE = dm.isTesting("tips_timeline")
local TEST_SOUL_EGG_TIPS = dm.isTesting("soul_egg_tips")
local TestManager = {}

if TEST_CHARACTER_RAND_ITEM then
	local itemId = 510000

	function TestManager.get_data()
		local res = {}
		local player = dm.player(1)

		for _, petId in ipairs(player.petPrepareList) do
			local petInfo = player:getPetInfo(petId)

			if petInfo then
				local validCharacterList = Utils.getValidCharacterList(petInfo, true)

				res[petId] = {
					repr = petInfo:repr(),
					characterInfo = petInfo.characterInfo:getRawTable(),
					validCharacterList = validCharacterList
				}
			end
		end

		return res
	end

	function TestManager.get_item()
		local player = dm.player(1)

		return player:getItemCountById(itemId)
	end

	function TestManager.use_item(petId)
		local player = dm.player(1)

		petId = petId or player.petPrepareList[1]

		return player:RPC_CS_UseItemById(itemId, 1, {
			petId = petId
		})
	end
end

if TEST_PROP_ENHANCE_ITEM then
	local itemId = 151000
	local NoticeDef = require("Common.NoticeDef")
	local ItemUseCheckUtils = require("Common.Utils.ItemUseCheckUtils")

	function TestManager.get_data()
		local player = dm.player(1)
		local res = {}

		local function ret_repr(ret, err)
			return string.format("ret:%s, err:%s", ret, NoticeDef.getRepr(err))
		end

		for _, petId in ipairs(player.petPrepareList) do
			local petInfo = player:getPetInfo(petId)
			local configData = petInfo and petInfo:getConfigData()

			if petInfo and configData then
				local checkRet1, checkErr1 = ItemUseCheckUtils.check_propertyEnhance(petInfo)
				local checkRet2, checkErr2 = ItemUseCheckUtils.check_propertyEnhance(petInfo, true)
				local checkRet3, checkErr3 = ItemUseCheckUtils.check_propertyEnhance(petInfo, true, true)

				res[petId] = {
					repr = petInfo:repr(),
					prop = petInfo.basePropertyList:dump(),
					recommendAttr = Utils.deepCopyTable(configData.recommend_attr),
					checkRet1 = ret_repr(checkRet1, checkErr1),
					checkRet2 = ret_repr(checkRet2, checkErr2),
					checkRet3 = ret_repr(checkRet3, checkErr3)
				}
			end
		end

		return res
	end

	function TestManager.get_item()
		local player = dm.player(1)

		return player:getItemCountById(itemId)
	end

	function TestManager.use_item(petId)
		local player = dm.player(1)

		petId = petId or player.petPrepareList[1]

		return player:RPC_CS_UseItemById(itemId, 1, {
			petId = petId
		})
	end
end

if TEST_PROP_NAME_CHANGE then
	function TestManager.get_data()
		local constBaseAttrs = {
			"species_hp_max_v",
			"species_atk_v",
			"species_def_v",
			"species_ep_regen_force_v",
			"species_def_mag_v",
			"species_atk_mag_v"
		}
		local constBaseAttrFinal = {
			"hp_max_v",
			"atk_v",
			"def_v",
			"ep_regen_force_v",
			"def_mag_v",
			"atk_mag_v"
		}
		local baseAttrs, baseAttrFinal, baseAttrFixedRate = {}, {}, {}

		for i = 1, Const.BASE_PROPERTY_CNT do
			baseAttrs[i] = Utils.getPropSpeciesAttrName(i)
			baseAttrFinal[i] = Utils.getPropFinalAttrName(i)
		end

		return {
			baseAttrEqual = Utils.isTableEqual(baseAttrs, constBaseAttrs),
			baseAttrFinalEqual = Utils.isTableEqual(baseAttrFinal, constBaseAttrFinal)
		}
	end
end

if TEST_CLIENT_TRIGGER_CHANGE then
	local TriggerMapData = require("Data.trigger_map_data")
	local TriggerConst = require("Common.Const.TriggerConst")
	local TriggerUtils = require("Common.Utils.TriggerUtils")

	function TestManager.get_data()
		local res = {}

		for trigger, _ in pairs(TriggerMapData) do
			local old = TriggerUtils.TRIGGER_CONDITION_FUNC_CLIENT_ONLY[trigger]
			local new = TriggerConst.CLIENT_TRIGGER_TARGET[trigger] and TriggerUtils.usePresetConditionValue(trigger)

			if not old ~= not new then
				res[trigger] = {
					old = old,
					new = new
				}
			end
		end

		return res
	end
end

if TEST_TEAM_INVITE then
	local function getLeader(leaderUid)
		local leader = dm.getPlayerByUid(leaderUid)

		if leader == nil then
			for _, playerId in ipairs(dm.player()) do
				local player = pg.getEntity(playerId)

				if player:isTeamLeader() then
					leader = player

					break
				end
			end
		end

		if leader == nil then
			return "leader not found"
		end

		return leader
	end

	function TestManager.create_team(leaderUid, num, memberUids)
		num = num or 4
		memberUids = memberUids or {}

		local playerIds = dm.player()

		if num > #playerIds then
			return string.format("playerCount:%d < num:%d", #playerIds, num)
		end

		local leader = dm.getPlayerByUid(leaderUid)

		if leader == nil then
			leader = dm.player(1)
		end

		lume.remove(playerIds, leader.id)

		local members = {}

		for i = 1, num - 1 do
			local uid = memberUids[i]

			if uid then
				local player = dm.getPlayerByUid(uid)

				if player then
					lume.remove(playerIds, player.id)
					table.insert(members, player)
				end
			else
				local player = pg.getEntity(playerIds[1])

				if player then
					lume.remove(playerIds, player.id)
					table.insert(members, player)
				end
			end
		end

		leader:createTeam()
		TimerManager.addTimer(1, function()
			for _, member in ipairs(members) do
				leader:inviteTeamMember(member.uid)
				TimerManager.addTimer(1, function()
					member:RPC_CS_AcceptTeamInvite(leader.uid, true)
				end)
			end
		end)

		return lume.concat({
			leader.uid
		}, lume.map(members, "uid"))
	end

	function TestManager.add_member(leaderUid, memberUid)
		local leader = getLeader(leaderUid)

		assert(leader, "leader not found")

		local member = dm.getPlayerByUid(memberUid)

		assert(member, "member not found")
		leader:inviteTeamMember(member.uid)
		TimerManager.addTimer(1, function()
			member:RPC_CS_AcceptTeamInvite(leader.uid, true)
		end)
	end

	function TestManager.del_member(leaderUid, memberUid)
		local leader = getLeader(leaderUid)

		assert(leader, "leader not found")

		local member = dm.getPlayerByUid(memberUid)

		assert(member, "member not found")
		leader:kickTeamMember(member.uid)
	end

	function TestManager.destroy_team(leaderUid)
		local leader = getLeader(leaderUid)

		assert(leader, "leader not found")
		leader:disbandTeam()
	end

	function TestManager.enter_world(leaderUid, memberUid)
		local leader = getLeader(leaderUid)

		if leader == nil then
			return "leader not found"
		end

		if memberUid then
			local member = dm.getPlayerByUid(memberUid)

			assert(member, "member not found")
			leader:inviteSinglePlayer(member.uid)
			TimerManager.addTimer(1, function()
				member:RPC_CS_HandleEnterWorldInvite(leader.uid, true)
			end)
		else
			leader:inviteMultiPlayer()
			TimerManager.addTimer(1, function()
				for uid, _ in pairs(leader.teamInfo.membersInfo) do
					local player = dm.getPlayerByUid(uid)

					player:RPC_CS_AcceptGatherTeammate(leader.uid, true)
				end
			end)
		end
	end

	function TestManager.apply_team(leaderUid, memberUid)
		local leader = getLeader(leaderUid)

		assert(leader, "leader not found")

		local member = dm.getPlayerByUid(memberUid)

		assert(member, "member not found")
		member:RPC_CS_RequestJoinTeam(leader.uid)
	end

	function TestManager.apply_world(leaderUid, memberUid)
		local leader = getLeader(leaderUid)

		assert(leader, "leader not found")

		local member = dm.getPlayerByUid(memberUid)

		assert(member, "member not found")
		member:RPC_CS_RequestEnterWorld(leader.uid)
	end
end

if TEST_HOMELAND_PET then
	local HomelandConfigData = require("Data.homeland_config_data")
	local player = dm.player(1)

	function TestManager.get_data(maxCount)
		maxCount = maxCount or HomelandConfigData.maxPetCount

		local petInHome = {}
		local petCanPut, petCanPutIds = {}, {}
		local petEntity = {}

		for petId, petInfo in pairs(player.pets) do
			if player:isPetPutInHomeland(petInfo) then
				petInHome[#petInHome + 1] = petInfo:repr()

				local entity = pg.getEntity(petId)

				petEntity[#petEntity + 1] = entity and entity:repr() or "nil"
			else
				petCanPut[#petCanPut + 1] = petInfo:repr()
				petCanPutIds[#petCanPutIds + 1] = petId
			end
		end

		petCanPut = lume.first(petCanPut, maxCount)
		petCanPutIds = lume.first(petCanPutIds, maxCount)

		return {
			isUnlock = player.isHomelandUnlock,
			isInSelfHome = player:isInSelfHomeland(),
			maxPetCount = HomelandConfigData.maxPetCount,
			curPetList = player.pets:dumpCur(),
			petInHome = lume.tonumstrkey(petInHome, 3),
			petEntity = lume.tonumstrkey(petEntity, 3),
			petCanPut = lume.tonumstrkey(petCanPut, 3),
			petCanPutIds = petCanPutIds
		}
	end

	function TestManager.put_pet(petId)
		return player:RPC_CS_AddHomelandPet(petId, Const.HOMELAND_AREA_TYPE.PRODUCE, -1)
	end

	function TestManager.put_all(count)
		count = count or HomelandConfigData.maxPetCount

		local res = TestManager.get_data()
		local curCount = #res.petInHome
		local maxCount = math.min(count, #res.petCanPutIds)

		for i = curCount + 1, maxCount do
			local petId = res.petCanPutIds[i]

			player:RPC_CS_AddHomelandPet(petId, Const.HOMELAND_AREA_TYPE.PRODUCE, -1)
		end
	end

	function TestManager.remove_pet(petId)
		local areaId, homeSlotIndex

		if player.space and player.space.petBoxMap then
			areaId, homeSlotIndex = player.space.petBoxMap:getPetIndex(petId)
		end

		return player:RPC_CS_RemoveHomelandPet(petId, areaId or Const.HOMELAND_AREA_TYPE.PRODUCE, homeSlotIndex or -1, -1, -1)
	end

	function TestManager.remove_all()
		for petId, _ in pairs(player.pets) do
			local areaId, homeSlotIndex

			if player.space and player.space.petBoxMap then
				areaId, homeSlotIndex = player.space.petBoxMap:getPetIndex(petId)
			end

			player:RPC_CS_RemoveHomelandPet(petId, areaId or Const.HOMELAND_AREA_TYPE.PRODUCE, homeSlotIndex or -1, -1, -1)
		end
	end

	function TestManager.refresh_entity()
		player.space:refreshHomelandPetEntities(true)
	end

	function TestManager.modify_formation(petId, isBattle, index)
		if isBattle then
			index = index or player.curPetFormationIndex
		else
			index = 1
		end

		local formationInfo = player.prepareFormationList[index]

		if not formationInfo then
			return string.format("formationInfo not found, index:%d", index)
		end

		local petInfo = player.pets[petId]

		if not petInfo then
			return string.format("petInfo not found, petId:%s", petId)
		end

		if isBattle then
			local newList = formationInfo.formation:getRawTable()

			if not lume.find(newList, petId) then
				if #newList >= Const.PET_PREPARE_NUM_LIMIT then
					newList[#newList] = petId
				else
					newList[#newList + 1] = petId
				end
			else
				lume.remove(newList, petId)
			end

			return player:RPC_CS_ModifyPrepareFormation(index, newList, true)
		else
			local newList = formationInfo.exploreFormation:getRawTable()

			if not lume.find(newList, petId) then
				local pdd = PetData[petInfo.templateId]

				for abilityIndex, abilityName in pairs(AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME) do
					if pdd[abilityName] then
						newList[abilityIndex] = petId
					end
				end
			else
				for abilityIndex, _ in pairs(AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME) do
					if newList[abilityIndex] == petId then
						newList[abilityIndex] = ""
					end
				end
			end

			return player:RPC_CS_ModifyPrepareFormation(index, newList, false)
		end
	end
end

if TEST_SPACE_SPAWNER then
	local SceneUtils = require("Common.Utils.SceneUtils")
	local player = dm.player(1)
	local space = player.space

	function TestManager.get_entity(staticId)
		local sceneEntityData = SceneUtils.getSceneEntityData(space.sceneId, space.id)
		local sedd = sceneEntityData and sceneEntityData[staticId]
		local ent = space:getEntityByStaticId(staticId)

		return {
			sedd = sedd or "nil",
			ent = ent and ent:repr() or "nil",
			pos = ent and ent:getPosition() or sedd and Vector3.Clone(sedd.position) or "nil"
		}
	end

	function TestManager.goto_entity(staticId)
		local res = TestManager.get_entity(staticId)

		if res.pos == "nil" then
			return "failed"
		end

		player:setPosition(res.pos)
	end

	function TestManager.create_entity(staticId, curPosition)
		local res = TestManager.get_entity(staticId)

		if res.sedd == "nil" then
			return "failed"
		end

		local props = Utils.deepCopyTable(res.sedd) or {}

		props.templateId = props.idInType
		props.staticId = staticId
		props.spaceId = space.id

		local rot = props.rotation

		props.rotation = Quaternion(rot[1], rot[2], rot[3], rot[4])

		local position = props.position

		props.position = Vector3.New(position[1], position[2], position[3])

		if ToBool(curPosition) then
			props.position = player:getPosition()
		end

		props.lastSurvivalTime = 0

		local entType = props.subType
		local theEntity = space:createEntity(entType, props, props.position, props.rotation)

		if not theEntity then
			return "failed to create entity"
		end

		return theEntity:repr()
	end
end

if TEST_PROP_PREVIEW then
	local petEntity = dm.pet(1)
	local petInfo

	local function getPetInfo(targetId)
		if type(targetId) == "number" then
			petEntity = pg.getEntityByActorId(targetId)
			petInfo = petEntity and petEntity.petInfo
		elseif type(targetId) == "string" then
			petEntity = pg.getEntity(targetId)
			petInfo = petEntity and petEntity.petInfo or dm.player(1).pets[targetId]
		end

		assert(petInfo, "petInfo not found")

		return petInfo
	end

	function TestManager.get_max(targetId)
		getPetInfo(targetId)

		local player = petInfo.getOwnerPlayer and petInfo:getOwnerPlayer() or nil
		local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(player, petInfo)
		local cur = Utils.genBasePropertyDisplayDict(petInfo.basePropertyList, attributeMap)
		local max = Utils.genBasePropertyPreview(petInfo, Const.PROP_PREVIEW_MAX_LEVEL)

		return {
			cur = cur,
			max = max,
			actorId = petEntity and petEntity.actorId or "nil"
		}
	end

	function TestManager.get_exchange(targetId, lvUpMap)
		lvUpMap = lvUpMap or {
			nil,
			2,
			2
		}

		getPetInfo(targetId)

		local player = petInfo.getOwnerPlayer and petInfo:getOwnerPlayer() or nil
		local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(player, petInfo)
		local cur = Utils.genBasePropertyDisplayDict(petInfo.basePropertyList, attributeMap)
		local old = Utils.genBasePropertyPreview(petInfo, Const.PROP_PREVIEW_EXCHANGE, {
			lvUpMap
		})

		return {
			cur = cur,
			old = old,
			actorId = petEntity and petEntity.actorId or "nil"
		}
	end
end

if TEST_REMOTE_SYNC then
	function TestManager.update_sync_to(syncerUid, listenerUid, isAdd)
		local syncerPlayer = dm.getPlayerByUid(syncerUid)

		if not syncerPlayer then
			return string.format("syncer not found, uid:%s", syncerUid)
		end

		listenerUid = tostring(listenerUid)

		local res = {
			syncerPlayer:repr()
		}

		syncerPlayer:updateSyncRemoteUid(listenerUid, isAdd)

		for _, petEnt in pairs(syncerPlayer.petUnits) do
			petEnt:updateSyncRemoteUid(listenerUid, isAdd)

			res[#res + 1] = petEnt:repr()
		end

		return lume.tonumstrkey(res, 3)
	end

	function TestManager.sync_to(syncerUid, listenerUid)
		return TestManager.update_sync_to(syncerUid, listenerUid, true)
	end

	function TestManager.unsync_to(syncerUid, listenerUid)
		return TestManager.update_sync_to(syncerUid, listenerUid, false)
	end

	function TestManager.sync(uid1, uid2)
		return {
			[string.format("%s->%s", uid1, uid2)] = TestManager.sync_to(uid1, uid2),
			[string.format("%s->%s", uid2, uid1)] = TestManager.sync_to(uid2, uid1)
		}
	end

	function TestManager.unsync(uid1, uid2)
		return {
			[string.format("%s->%s", uid1, uid2)] = TestManager.unsync_to(uid1, uid2),
			[string.format("%s->%s", uid2, uid1)] = TestManager.unsync_to(uid2, uid1)
		}
	end
end

if TEST_SOCIAL then
	local SocialConst = require("Common.Const.SocialConst")
	local CommonSwitch = require("Common.CommonSwitch")
	local NoticeDef = require("Common.NoticeDef")
	local TxnConst = require("GameServer.TxnConst")

	local function makeSocialId(socialType, uid1, uid2)
		local uids = {
			tostring(uid1),
			tostring(uid2)
		}

		table.sort(uids)

		return tostring(socialType) .. "_" .. table.concat(uids, "_")
	end

	local function getPlayer(uid, index)
		local player

		if uid then
			player = dm.getPlayerByUid(tostring(uid))
		elseif index then
			player = dm.player(index)
		end

		return player
	end

	local function getSocial(socialId)
		local ok, social

		if socialId then
			ok, social = pcall(dm.social, tostring(socialId))

			return ok and social or nil
		end

		local data = dm.test_manager_data

		if data and data.socialId then
			ok, social = pcall(dm.social, data.socialId)

			return ok and social or nil
		end

		ok, social = pcall(dm.social, 1)

		return ok and social or nil
	end

	local function getTxnList(player)
		if not player or not player.listTxnInfos then
			return {}
		end

		local list = {}

		for _, txnType in ipairs({
			TxnConst.TXN_TYPE_SOCIAL_PET_BREED,
			TxnConst.TXN_TYPE_SOCIAL_PET_EXCHANGE
		}) do
			for _, item in ipairs(player:listTxnInfos(txnType)) do
				local info = item.txnInfo

				list[#list + 1] = {
					txnId = item.txnId,
					txnType = info.txnType,
					txnStatus = info.txnStatus,
					socialId = info.txnData and info.txnData.socialId,
					decision = info.txnData and info.txnData.decision,
					peerPrepared = info.txnData and info.txnData.peerPrepared,
					stepMap = info.txnData and info.txnData.stepMap
				}
			end
		end

		return list
	end

	local function getPetSummary(player, petId)
		if not player then
			return "player not found"
		end

		local petInfo = petId and player.pets[tostring(petId)]

		if not petInfo then
			return petId and "pet not found" or nil
		end

		return {
			id = petInfo.id,
			uuid = petInfo.uuid,
			templateId = petInfo.templateId,
			level = petInfo.level,
			gender = petInfo.gender,
			breedCount = petInfo.breedCount,
			exchangeTs = player:getPetExchangeTs(petInfo),
			socialTxnLockId = petInfo.socialTxnLockId,
			socialTxnLockType = petInfo.socialTxnLockType
		}
	end

	local function getPetBrief(player, petId)
		if not player then
			return "player not found"
		end

		local petInfo = petId and player.pets[tostring(petId)]

		if not petInfo then
			return petId and {
				present = false,
				id = tostring(petId)
			} or nil
		end

		return {
			present = true,
			id = petInfo.id,
			templateId = petInfo.templateId,
			breedCount = petInfo.breedCount,
			lockId = petInfo.socialTxnLockId,
			lockType = petInfo.socialTxnLockType
		}
	end

	local function getTxnBriefList(player)
		local list = getTxnList(player)

		return next(list) and list or nil
	end

	local function setContext(ctx)
		dm.test_manager_data = ctx

		return {
			socialType = ctx.socialType,
			socialId = ctx.socialId,
			invitorUid = ctx.invitorUid,
			inviteeUid = ctx.inviteeUid,
			srcPetId = ctx.srcPetId,
			dstPetId = ctx.dstPetId,
			selectInfo = ctx.selectInfo,
			srcPet = getPetSummary(ctx.invitorPlayer, ctx.srcPetId),
			dstPet = getPetSummary(ctx.inviteePlayer, ctx.dstPetId)
		}
	end

	local function runTimerStep(name, fn)
		local ok, ret = pcall(fn)
		local data = dm.test_manager_data or {}

		data.lastStep = name

		if not ok then
			data.lastError = tostring(ret)
		else
			data.lastError = nil
			data.lastResult = ret
		end

		dm.test_manager_data = data
	end

	local function isSocialStarted(data)
		if not data or not data.socialId then
			return false
		end

		local invitorPlayer = data.invitorPlayer or getPlayer(data.invitorUid)
		local inviteePlayer = data.inviteePlayer or getPlayer(data.inviteeUid)

		return invitorPlayer and inviteePlayer and invitorPlayer.curSocialId == data.socialId and inviteePlayer.curSocialId == data.socialId
	end

	local function hasPendingInvite(data)
		if not data or not data.inviteePlayer then
			return false
		end

		local queue = data.inviteePlayer.socialInviteQueue

		return queue and queue[data.socialType] and queue[data.socialType][data.invitorUid] ~= nil
	end

	local function runWhenSocialReady(name, delay, maxRetry, fn)
		delay = delay or 1
		maxRetry = maxRetry or 10

		local function tick(left)
			TimerManager.addTimer(delay, function()
				runTimerStep(name, function()
					local data = dm.test_manager_data

					if isSocialStarted(data) or getSocial(data and data.socialId) then
						return fn(data)
					end

					if left > 0 then
						tick(left - 1)

						return string.format("wait social ready, retryLeft=%d", left)
					end

					error("social not found: " .. tostring(data and data.socialId))
				end)
			end)
		end

		tick(maxRetry)
	end

	local function findBreedPair(invitorPlayer, inviteePlayer)
		if not invitorPlayer or not inviteePlayer then
			return nil, nil, "player not found"
		end

		for srcPetId, srcPetInfo in pairs(invitorPlayer.pets) do
			if not invitorPlayer.isPetLockedBySocialTxn or not invitorPlayer:isPetLockedBySocialTxn(srcPetId) then
				for dstPetId, dstPetInfo in pairs(inviteePlayer.pets) do
					if (not inviteePlayer.isPetLockedBySocialTxn or not inviteePlayer:isPetLockedBySocialTxn(dstPetId)) and Utils.checkPetBreed(srcPetInfo, dstPetInfo) then
						return srcPetId, dstPetId
					end
				end
			end
		end

		return nil, nil, "breed pair not found"
	end

	local EXCHANGE_REMOVE_ERR_NAMES = {
		[Const.EPRR_PET_IN_TEAM] = "EPRR_PET_IN_TEAM",
		[Const.EPRR_FRIENDSHIP_LOW] = "EPRR_FRIENDSHIP_LOW",
		[Const.EPRR_EXCHANGE_CD] = "EPRR_EXCHANGE_CD",
		[Const.EPRR_PET_TYPE_FORBID] = "EPRR_PET_TYPE_FORBID",
		[Const.EPRR_LIMIT_EXCEED] = "EPRR_LIMIT_EXCEED",
		[Const.EPRR_PET_IN_HOME] = "EPRR_PET_IN_HOME",
		[Const.EPRR_ITEM_BAG_FULL] = "EPRR_ITEM_BAG_FULL",
		[Const.EPRR_PET_IN_DISPATCH] = "EPRR_PET_IN_DISPATCH"
	}
	local EXCHANGE_ADD_ERR_NAMES = {
		[Const.EPAR_COST_LACK] = "EPAR_COST_LACK",
		[Const.EPAR_FRIENDSHIP_LOW] = "EPAR_FRIENDSHIP_LOW",
		[Const.EPAR_EXCHANGE_CD] = "EPAR_EXCHANGE_CD",
		[Const.EPAR_PET_TYPE_FORBID] = "EPAR_PET_TYPE_FORBID",
		[Const.EPAR_LIMIT_EXCEED] = "EPAR_LIMIT_EXCEED",
		[Const.EPAR_ADD_PET_FORBID] = "EPAR_ADD_PET_FORBID"
	}

	local function newExchangeDiag(invitorPlayer, inviteePlayer, friendshipLevel)
		return {
			checkedPairs = 0,
			invitorUid = invitorPlayer and invitorPlayer.uid,
			inviteeUid = inviteePlayer and inviteePlayer.uid,
			friendshipLevel = friendshipLevel,
			invitorPetCount = invitorPlayer and lume.count(invitorPlayer.pets) or 0,
			inviteePetCount = inviteePlayer and lume.count(inviteePlayer.pets) or 0,
			locked = {
				invitee = 0,
				invitor = 0
			},
			noCfg = {
				src = 0,
				dst = 0
			},
			fail = {
				srcRemove = {},
				srcAdd = {},
				dstRemove = {},
				dstAdd = {}
			},
			samples = {}
		}
	end

	local function addExchangeFail(diag, phase, err, names, petInfo)
		if not diag then
			return
		end

		local reason = names[err] or tostring(err or "unknown")
		local map = diag.fail[phase]

		map[reason] = (map[reason] or 0) + 1

		if #diag.samples < 8 then
			diag.samples[#diag.samples + 1] = {
				phase = phase,
				reason = reason,
				petId = petInfo and petInfo.id,
				templateId = petInfo and petInfo.templateId,
				exchangeTs = petInfo and petInfo.petExchangeTs,
				lockId = petInfo and petInfo.socialTxnLockId,
				lockType = petInfo and petInfo.socialTxnLockType
			}
		end
	end

	local function findExchangePair(invitorPlayer, inviteePlayer, needDiag)
		if not invitorPlayer or not inviteePlayer then
			return nil, nil, "player not found", needDiag and newExchangeDiag(invitorPlayer, inviteePlayer)
		end

		local isFriend1, _, level1 = invitorPlayer:getFriendInfo(inviteePlayer.uid)
		local isFriend2, _, level2 = inviteePlayer:getFriendInfo(invitorPlayer.uid)
		local friendshipLevel = math.min(level1 or 0, level2 or 0)
		local diag = needDiag and newExchangeDiag(invitorPlayer, inviteePlayer, friendshipLevel)

		if not isFriend1 or not isFriend2 then
			return nil, nil, "friend relation not found", diag
		end

		for srcPetId, srcPetInfo in pairs(invitorPlayer.pets) do
			if not invitorPlayer:isPetLockedBySocialTxn(srcPetId) then
				local srcRaw = invitorPlayer:genPetExchangeSnapshot(srcPetInfo)
				local srcCfg = Utils.getExchangePetConfig(srcRaw)

				if srcCfg then
					for dstPetId, dstPetInfo in pairs(inviteePlayer.pets) do
						if not inviteePlayer:isPetLockedBySocialTxn(dstPetId) then
							if diag then
								diag.checkedPairs = diag.checkedPairs + 1
							end

							local dstRaw = inviteePlayer:genPetExchangeSnapshot(dstPetInfo)
							local dstCfg = Utils.getExchangePetConfig(dstRaw)
							local srcRemoveOk, srcRemoveErr = Utils.checkExchangeRemovePet(invitorPlayer, srcRaw, friendshipLevel, srcCfg)
							local srcAddOk, srcAddErr = dstCfg and Utils.checkExchangeAddPet(invitorPlayer, dstRaw, friendshipLevel, dstCfg)
							local dstRemoveOk, dstRemoveErr = dstCfg and Utils.checkExchangeRemovePet(inviteePlayer, dstRaw, friendshipLevel, dstCfg)
							local dstAddOk, dstAddErr = srcCfg and Utils.checkExchangeAddPet(inviteePlayer, srcRaw, friendshipLevel, srcCfg)

							if srcAddOk and srcRemoveOk and dstAddOk and dstRemoveOk then
								return srcPetId, dstPetId, nil, diag
							end

							if diag then
								if not dstCfg then
									diag.noCfg.dst = diag.noCfg.dst + 1
								end

								if not srcRemoveOk then
									addExchangeFail(diag, "srcRemove", srcRemoveErr, EXCHANGE_REMOVE_ERR_NAMES, srcRaw)
								end

								if not srcAddOk then
									addExchangeFail(diag, "srcAdd", srcAddErr, EXCHANGE_ADD_ERR_NAMES, dstRaw)
								end

								if not dstRemoveOk then
									addExchangeFail(diag, "dstRemove", dstRemoveErr, EXCHANGE_REMOVE_ERR_NAMES, dstRaw)
								end

								if not dstAddOk then
									addExchangeFail(diag, "dstAdd", dstAddErr, EXCHANGE_ADD_ERR_NAMES, srcRaw)
								end
							end
						elseif diag then
							diag.locked.invitee = diag.locked.invitee + 1
						end
					end
				elseif diag then
					diag.noCfg.src = diag.noCfg.src + 1
				end
			elseif diag then
				diag.locked.invitor = diag.locked.invitor + 1
			end
		end

		return nil, nil, "exchange pair not found", diag
	end

	function TestManager.prepare(socialType, invitorUid, inviteeUid)
		invitorUid = tostring(invitorUid)
		inviteeUid = tostring(inviteeUid)
		dm.test_manager_data = {
			socialType = socialType,
			socialId = makeSocialId(socialType, invitorUid, inviteeUid),
			invitorUid = invitorUid,
			inviteeUid = inviteeUid,
			invitorPlayer = dm.getPlayerByUid(invitorUid),
			inviteePlayer = dm.getPlayerByUid(inviteeUid)
		}

		return lume.keys(dm.test_manager_data)
	end

	function TestManager.invite()
		local data = dm.test_manager_data

		if not data then
			return "data not found"
		end

		data.invitorPlayer:RPC_CS_SocialInvite(data.socialType, data.inviteeUid, data.inviteInfo or {})

		return TestManager.status()
	end

	function TestManager.doubleInvite()
		local data = dm.test_manager_data

		if not data then
			return "data not found"
		end

		data.invitorPlayer:RPC_CS_SocialInvite(data.socialType, data.inviteeUid, data.inviteInfo or {})
		data.inviteePlayer:RPC_CS_SocialInvite(data.socialType, data.invitorUid, data.reverseInviteInfo or {})

		return TestManager.status()
	end

	function TestManager.reply(accept)
		if accept == nil then
			accept = true
		end

		local data = dm.test_manager_data

		if not data then
			return "data not found"
		end

		if not hasPendingInvite(data) then
			return {
				reason = "inviteQueueNotFound",
				skipped = true,
				socialStarted = isSocialStarted(data)
			}
		end

		data.inviteePlayer:RPC_CS_SocialInviteReply(data.socialType, data.invitorUid, {
			accept,
			{}
		})

		return TestManager.status()
	end

	function TestManager.doubleReply(accept)
		if accept == nil then
			accept = true
		end

		local data = dm.test_manager_data

		if not data then
			return "data not found"
		end

		data.inviteePlayer:RPC_CS_SocialInviteReply(data.socialType, data.invitorUid, {
			accept,
			{}
		})
		data.invitorPlayer:RPC_CS_SocialInviteReply(data.socialType, data.inviteeUid, {
			accept,
			{}
		})

		return TestManager.status()
	end

	function TestManager.csop(uid, op, params, socialId)
		local data = dm.test_manager_data or {}

		uid = tostring(uid or data.invitorUid)
		socialId = socialId or data.socialId
		params = params or {}

		if not socialId or socialId == "" then
			return "socialId not found"
		end

		local social = getSocial(socialId)

		if not social then
			local player = dm.getPlayerByUid(uid)

			if not player then
				return "player not found"
			end

			player:callService("SocialService", "CMD_ClientOperation", {
				uid,
				socialId,
				op,
				params
			}, nil, {
				hint = socialId,
				callerId = uid
			})

			return {
				notice = "sent to SocialService",
				uid = uid,
				socialId = socialId,
				op = op
			}
		end

		return social:onClientOperation(uid, op, params)
	end

	function TestManager.scop(uid, op, params, socialId)
		local social = getSocial(socialId)

		if not social then
			return "social not found"
		end

		if uid then
			social:notifyClient(uid, op, params)
		else
			social:notifyAllClients(op, params)
		end
	end

	function TestManager.prepare_breed(invitorUid, inviteeUid, srcPetId, dstPetId, selectInfo)
		local invitorPlayer = getPlayer(invitorUid, 1)
		local inviteePlayer = getPlayer(inviteeUid, 2)

		if not invitorPlayer or not inviteePlayer then
			return "player not found"
		end

		invitorUid, inviteeUid = invitorPlayer.uid, inviteePlayer.uid

		if not srcPetId or not dstPetId then
			local autoSrc, autoDst, err = findBreedPair(invitorPlayer, inviteePlayer)

			srcPetId = srcPetId or autoSrc
			dstPetId = dstPetId or autoDst

			if not srcPetId or not dstPetId then
				return err
			end
		end

		srcPetId, dstPetId = tostring(srcPetId), tostring(dstPetId)

		local srcPetInfo = invitorPlayer.pets[srcPetId]
		local dstPetInfo = inviteePlayer.pets[dstPetId]

		if not srcPetInfo or not dstPetInfo then
			return "pet not found"
		end

		return setContext({
			socialType = SocialConst.SOCIAL_PET_BREED,
			socialId = makeSocialId(SocialConst.SOCIAL_PET_BREED, invitorUid, inviteeUid),
			invitorUid = invitorUid,
			inviteeUid = inviteeUid,
			invitorPlayer = invitorPlayer,
			inviteePlayer = inviteePlayer,
			srcPetId = srcPetId,
			dstPetId = dstPetId,
			selectInfo = selectInfo or {},
			inviteInfo = {
				srcPetId = srcPetId,
				dstPetId = dstPetId,
				srcPetInfo = srcPetInfo:getRawTable()
			}
		})
	end

	function TestManager.prepare_exchange(invitorUid, inviteeUid, srcPetId, dstPetId)
		local invitorPlayer = getPlayer(invitorUid, 1)
		local inviteePlayer = getPlayer(inviteeUid, 2)

		if not invitorPlayer or not inviteePlayer then
			return "player not found"
		end

		invitorUid, inviteeUid = invitorPlayer.uid, inviteePlayer.uid

		if not srcPetId or not dstPetId then
			local autoSrc, autoDst, err = findExchangePair(invitorPlayer, inviteePlayer)

			srcPetId = srcPetId or autoSrc
			dstPetId = dstPetId or autoDst

			if not srcPetId or not dstPetId then
				return err
			end
		end

		srcPetId, dstPetId = tostring(srcPetId), tostring(dstPetId)

		if not invitorPlayer.pets[srcPetId] or not inviteePlayer.pets[dstPetId] then
			return "pet not found"
		end

		return setContext({
			socialType = SocialConst.SOCIAL_PET_EXCHANGE,
			socialId = makeSocialId(SocialConst.SOCIAL_PET_EXCHANGE, invitorUid, inviteeUid),
			invitorUid = invitorUid,
			inviteeUid = inviteeUid,
			invitorPlayer = invitorPlayer,
			inviteePlayer = inviteePlayer,
			srcPetId = srcPetId,
			dstPetId = dstPetId,
			inviteInfo = {}
		})
	end

	function TestManager.find_breed_pair(invitorUid, inviteeUid)
		local invitorPlayer = getPlayer(invitorUid, 1)
		local inviteePlayer = getPlayer(inviteeUid, 2)
		local srcPetId, dstPetId, err = findBreedPair(invitorPlayer, inviteePlayer)

		return {
			srcPetId = srcPetId,
			dstPetId = dstPetId,
			err = err,
			srcPet = getPetSummary(invitorPlayer, srcPetId),
			dstPet = getPetSummary(inviteePlayer, dstPetId)
		}
	end

	function TestManager.find_exchange_pair(invitorUid, inviteeUid)
		local invitorPlayer = getPlayer(invitorUid, 1)
		local inviteePlayer = getPlayer(inviteeUid, 2)
		local srcPetId, dstPetId, err, diag = findExchangePair(invitorPlayer, inviteePlayer, true)

		return {
			srcPetId = srcPetId,
			dstPetId = dstPetId,
			err = err,
			srcPet = getPetSummary(invitorPlayer, srcPetId),
			dstPet = getPetSummary(inviteePlayer, dstPetId),
			diag = diag
		}
	end

	function TestManager.breed_select(uid, selectInfo, socialId)
		local data = dm.test_manager_data

		uid = tostring(uid or data and data.invitorUid)
		selectInfo = selectInfo or data and data.selectInfo or {}

		return TestManager.csop(uid, SocialConst.PB_CS_ChangeSelectInfo, {
			selectInfo
		}, socialId)
	end

	function TestManager.breed_confirm(uid, socialId)
		local data = dm.test_manager_data

		uid = tostring(uid or data and data.invitorUid)

		return TestManager.csop(uid, SocialConst.PB_CS_ConfirmBreed, {}, socialId)
	end

	function TestManager.breed_ops(selectInfo, socialId)
		local data = dm.test_manager_data

		if not data then
			return "data not found"
		end

		selectInfo = selectInfo or data.selectInfo or {}

		local ret = {
			confirm = "scheduled after select",
			invitorSelect = TestManager.breed_select(data.invitorUid, selectInfo, socialId),
			inviteeSelect = TestManager.breed_select(data.inviteeUid, selectInfo, socialId)
		}

		TimerManager.addTimer(1, function()
			runTimerStep("breed_confirm", function()
				return {
					invitorConfirm = TestManager.breed_confirm(data.invitorUid, socialId),
					inviteeConfirm = TestManager.breed_confirm(data.inviteeUid, socialId)
				}
			end)
		end)

		return ret
	end

	function TestManager.breed_ops_now(selectInfo, socialId)
		local data = dm.test_manager_data

		if not data then
			return "data not found"
		end

		selectInfo = selectInfo or data.selectInfo or {}

		return {
			invitorSelect = TestManager.breed_select(data.invitorUid, selectInfo, socialId),
			inviteeSelect = TestManager.breed_select(data.inviteeUid, selectInfo, socialId),
			invitorConfirm = TestManager.breed_confirm(data.invitorUid, socialId),
			inviteeConfirm = TestManager.breed_confirm(data.inviteeUid, socialId)
		}
	end

	function TestManager.exchange_choose(uid, petId, socialId)
		local data = dm.test_manager_data

		uid = tostring(uid or data and data.invitorUid)

		local player = dm.getPlayerByUid(uid)

		petId = tostring(petId or data and (uid == data.invitorUid and data.srcPetId or data.dstPetId))

		local petInfo = player and player.pets[petId]

		if not petInfo then
			return "pet not found"
		end

		return TestManager.csop(uid, SocialConst.PE_CS_ChoosePet, {
			petInfo:getRawTable()
		}, socialId)
	end

	function TestManager.exchange_confirm(uid, petId, socialId)
		local data = dm.test_manager_data

		uid = tostring(uid or data and data.invitorUid)

		local player = dm.getPlayerByUid(uid)

		petId = tostring(petId or data and (uid == data.invitorUid and data.srcPetId or data.dstPetId))

		local petInfo = player and player.pets[petId]

		if not petInfo then
			return "pet not found"
		end

		return TestManager.csop(uid, SocialConst.PE_CS_ConfirmPet, {
			petInfo:getRawTable()
		}, socialId)
	end

	function TestManager.exchange_final(uid, isClickOk, socialId)
		local data = dm.test_manager_data

		uid = tostring(uid or data and data.invitorUid)

		if isClickOk == nil then
			isClickOk = true
		end

		return TestManager.csop(uid, SocialConst.PE_CS_FinalClick, {
			isClickOk
		}, socialId)
	end

	function TestManager.exchange_ops(socialId)
		local data = dm.test_manager_data

		if not data then
			return "data not found"
		end

		local ret = {
			final = "scheduled after confirm",
			confirm = "scheduled after choose",
			invitorChoose = TestManager.exchange_choose(data.invitorUid, data.srcPetId, socialId),
			inviteeChoose = TestManager.exchange_choose(data.inviteeUid, data.dstPetId, socialId)
		}

		TimerManager.addTimer(1, function()
			runTimerStep("exchange_confirm", function()
				return {
					invitorConfirm = TestManager.exchange_confirm(data.invitorUid, data.srcPetId, socialId),
					inviteeConfirm = TestManager.exchange_confirm(data.inviteeUid, data.dstPetId, socialId)
				}
			end)
		end)
		TimerManager.addTimer(2, function()
			runTimerStep("exchange_final", function()
				return {
					invitorFinal = TestManager.exchange_final(data.invitorUid, true, socialId),
					inviteeFinal = TestManager.exchange_final(data.inviteeUid, true, socialId)
				}
			end)
		end)

		return ret
	end

	function TestManager.exchange_ops_now(socialId)
		local data = dm.test_manager_data

		if not data then
			return "data not found"
		end

		return {
			invitorChoose = TestManager.exchange_choose(data.invitorUid, data.srcPetId, socialId),
			inviteeChoose = TestManager.exchange_choose(data.inviteeUid, data.dstPetId, socialId),
			invitorConfirm = TestManager.exchange_confirm(data.invitorUid, data.srcPetId, socialId),
			inviteeConfirm = TestManager.exchange_confirm(data.inviteeUid, data.dstPetId, socialId),
			invitorFinal = TestManager.exchange_final(data.invitorUid, true, socialId),
			inviteeFinal = TestManager.exchange_final(data.inviteeUid, true, socialId)
		}
	end

	function TestManager.breed_flow(invitorUid, inviteeUid, srcPetId, dstPetId, selectInfo, delay)
		local ctx = TestManager.prepare_breed(invitorUid, inviteeUid, srcPetId, dstPetId, selectInfo)

		if type(ctx) == "string" then
			return ctx
		end

		delay = delay or 1

		TestManager.invite()
		TimerManager.addTimer(delay, function()
			runTimerStep("breed_reply", function()
				return TestManager.reply(true)
			end)
		end)
		runWhenSocialReady("breed_ops", delay, 10, function()
			return TestManager.breed_ops()
		end)

		ctx.next = "wait a few seconds then call tm.status()"

		return ctx
	end

	function TestManager.exchange_flow(invitorUid, inviteeUid, srcPetId, dstPetId, useTxn, delay)
		if useTxn ~= nil then
			CommonSwitch.SOCIAL_TXN_EXCHANGE = ToBool(useTxn)
		end

		local ctx = TestManager.prepare_exchange(invitorUid, inviteeUid, srcPetId, dstPetId)

		if type(ctx) == "string" then
			return ctx
		end

		delay = delay or 1

		TestManager.invite()
		TimerManager.addTimer(delay, function()
			runTimerStep("exchange_reply", function()
				return TestManager.reply(true)
			end)
		end)
		runWhenSocialReady("exchange_ops", delay, 10, function()
			return TestManager.exchange_ops()
		end)

		ctx.txnSwitch = CommonSwitch.SOCIAL_TXN_EXCHANGE
		ctx.next = "exchange has 3s settle delay; call tm.status() after about 6-10s"

		return ctx
	end

	function TestManager.txn_switch(breed, exchange)
		if breed ~= nil then
			CommonSwitch.SOCIAL_TXN_BREED = ToBool(breed)
		end

		if exchange ~= nil then
			CommonSwitch.SOCIAL_TXN_EXCHANGE = ToBool(exchange)
		end

		return {
			SOCIAL_TXN_BREED = CommonSwitch.SOCIAL_TXN_BREED,
			SOCIAL_TXN_EXCHANGE = CommonSwitch.SOCIAL_TXN_EXCHANGE
		}
	end

	local SocialTxnFaultUtils = require("GameServer.SocialTxnFaultUtils")

	local function _resolveTxnId(player, txnIdOrSocialId)
		if not player or not txnIdOrSocialId or txnIdOrSocialId == "" then
			return nil
		end

		local key = tostring(txnIdOrSocialId)
		local info = player.getTxnInfo and player:getTxnInfo(key) or nil

		if info then
			return key, info
		end

		local foundId = player.findSocialTxnIdBySocialId and player:findSocialTxnIdBySocialId(key) or nil

		if foundId then
			return foundId, player:getTxnInfo(foundId)
		end

		return nil
	end

	function TestManager.fault_set(uid, point, opts)
		uid = uid and tostring(uid)

		if not uid or not point then
			return "uid and point required"
		end

		local ret, err = SocialTxnFaultUtils.set(uid, point, opts or {})

		if not ret then
			return err
		end

		ret.next = "run target flow then tm.status() / tm.fault_list()"

		return ret
	end

	function TestManager.fault_clear(uid, point)
		return SocialTxnFaultUtils.clear(uid and tostring(uid), point)
	end

	function TestManager.fault_list(uid)
		local list = SocialTxnFaultUtils.list(uid and tostring(uid))

		return next(list) and list or "no fault"
	end

	function TestManager.txn_list(uid)
		if uid then
			local player = getPlayer(uid)

			if not player then
				return "player not found"
			end

			local list = getTxnList(player)

			return next(list) and list or "no txn"
		end

		local data = dm.test_manager_data or {}

		return {
			invitor = data.invitorPlayer and getTxnList(data.invitorPlayer) or "nil",
			invitee = data.inviteePlayer and getTxnList(data.inviteePlayer) or "nil"
		}
	end

	function TestManager.txn_dump(uid, txnIdOrSocialId)
		local player = uid and getPlayer(uid) or nil

		if not player then
			return "player not found"
		end

		local txnId, info = _resolveTxnId(player, txnIdOrSocialId)

		if not txnId then
			for _, item in ipairs(getTxnList(player)) do
				txnId = item.txnId
				info = player:getTxnInfo(txnId)

				break
			end
		end

		if not txnId or not info then
			return "txn not found"
		end

		return {
			uid = player.uid,
			txnId = txnId,
			txnType = info.txnType,
			txnStatus = info.txnStatus,
			retryCount = info.retryCount or 0,
			createTs = info.createTs,
			terminateTs = info.terminateTs,
			txnData = info.txnData
		}
	end

	function TestManager.txn_retry(uid, txnIdOrSocialId)
		local player = uid and getPlayer(uid) or nil

		if not player then
			return "player not found"
		end

		local txnId, info

		if txnIdOrSocialId then
			txnId, info = _resolveTxnId(player, txnIdOrSocialId)
		else
			for _, item in ipairs(getTxnList(player)) do
				if item.txnStatus == TxnConst.TXN_STATUS_PENDING then
					txnId = item.txnId
					info = player:getTxnInfo(txnId)

					break
				end
			end
		end

		if not txnId or not info then
			return "pending txn not found"
		end

		local TxnUtils = require("GameServer.TxnUtils")
		local handler = TxnUtils.HandlerMap[info.txnType]

		if not handler or not handler.retryFunc then
			return "no retryFunc for " .. tostring(info.txnType)
		end

		info.retryCount = (info.retryCount or 0) + 1
		info.lastRetryTs = Time.secondCache

		local ok, ret = pcall(handler.retryFunc, player, txnId, info.txnData)
		local latestInfo = player:getTxnInfo(txnId)
		local latestData = latestInfo and latestInfo.txnData or info.txnData

		return {
			ok = ok,
			ret = ret,
			txnId = txnId,
			txnStatus = latestInfo and latestInfo.txnStatus or "cleared",
			retryCount = latestInfo and latestInfo.retryCount or info.retryCount,
			stepMap = latestData and latestData.stepMap,
			decision = latestData and latestData.decision
		}
	end

	function TestManager.txn_force_clear(uid, txnId)
		local player = uid and getPlayer(uid) or nil

		if not player then
			return "player not found"
		end

		txnId = txnId and tostring(txnId)

		if not txnId or txnId == "" then
			return "txnId required"
		end

		local info = player:getTxnInfo(txnId)

		if not info then
			return "txn not found"
		end

		local txnType = info.txnType
		local txnStatus = info.txnStatus

		if player._removeTypeIndex then
			player:_removeTypeIndex(txnType, txnId)
		end

		if player._txnMap then
			player._txnMap[txnId] = nil
		end

		local lockCleared = {}

		for petId, petInfo in pairs(player.pets or EMPTY_TABLE) do
			if petInfo.socialTxnLockId == txnId then
				petInfo.socialTxnLockId = ""
				petInfo.socialTxnLockType = 0
				lockCleared[#lockCleared + 1] = petId
			end
		end

		return {
			ok = true,
			uid = player.uid,
			txnId = txnId,
			txnType = txnType,
			txnStatus = txnStatus,
			lockCleared = lockCleared
		}
	end

	function TestManager.lock_try_remove(uid, petId)
		local player = uid and getPlayer(uid) or nil

		if not player then
			return "player not found"
		end

		local data = dm.test_manager_data or {}

		petId = petId and tostring(petId) or player.uid == data.invitorUid and data.srcPetId or player.uid == data.inviteeUid and data.dstPetId

		if not petId then
			return "petId required"
		end

		local ok, errCode = player:checkRemovePet(petId)

		return {
			uid = player.uid,
			petId = petId,
			checkOk = ok and true or false,
			errCode = errCode,
			lockId = player.pets[petId] and player.pets[petId].socialTxnLockId,
			lockType = player.pets[petId] and player.pets[petId].socialTxnLockType
		}
	end

	function TestManager.lock_try_exchange(uid1, uid2, petId1, petId2)
		local p1 = uid1 and getPlayer(uid1, 1) or nil
		local p2 = uid2 and getPlayer(uid2, 2) or nil

		if not p1 or not p2 then
			return "player not found"
		end

		local data = dm.test_manager_data or {}

		petId1 = petId1 and tostring(petId1) or data.srcPetId
		petId2 = petId2 and tostring(petId2) or data.dstPetId

		if not petId1 or not petId2 then
			return "petId1/petId2 required"
		end

		local pet1 = p1.pets[petId1]
		local pet2 = p2.pets[petId2]

		if not pet1 or not pet2 then
			return "pet not found"
		end

		local _, _, friendshipLevel, isVariantFriend = p1:getFriendInfo(p2.uid)
		local socialInfo = {
			socialId = "tm_lock_try_exchange_" .. tostring(p1.uid) .. "_" .. tostring(p2.uid),
			socialType = SocialConst.SOCIAL_PET_EXCHANGE,
			friendshipLevel = friendshipLevel or 0,
			isVariantFriend = isVariantFriend
		}
		local socialPlayerInfo = {
			[p1.uid] = {
				petInfo = pet1:getRawTable()
			},
			[p2.uid] = {
				petInfo = pet2:getRawTable()
			}
		}
		local socialPlayerInfo2 = {
			[p1.uid] = {
				petInfo = pet1:getRawTable()
			},
			[p2.uid] = {
				petInfo = pet2:getRawTable()
			}
		}
		local n1, args1 = p1:checkPetExchangeSettle(socialPlayerInfo, socialInfo)
		local n2, args2 = p2:checkPetExchangeSettle(socialPlayerInfo2, socialInfo)

		return {
			uid1 = p1.uid,
			petId1 = petId1,
			check1Notice = NoticeDef.getRepr and NoticeDef.getRepr(n1) or n1,
			uid2 = p2.uid,
			petId2 = petId2,
			check2Notice = NoticeDef.getRepr and NoticeDef.getRepr(n2) or n2,
			lock1Id = pet1.socialTxnLockId,
			lock1Type = pet1.socialTxnLockType,
			lock2Id = pet2.socialTxnLockId,
			lock2Type = pet2.socialTxnLockType
		}
	end

	local ItemConstSourceData = require("Data.item_const_source_data")

	function TestManager.item_mail_overflow(uid, itemId, count, mailId)
		local player = uid and getPlayer(uid, 1) or dm.player(1)

		if not player then
			return "player not found"
		end

		itemId = tonumber(itemId) or 1101
		count = tonumber(count) or 9999

		local addContext = {
			enableOverFlowMail = true,
			overFlowMailReason = "tm_item_overflow",
			sendOverFlowMail = true,
			recentAddGenIds = {}
		}

		if mailId then
			addContext.overFlowMailId = tonumber(mailId)
		end

		local ok = player:addItemsByIdNumDict({
			[itemId] = count
		}, ItemConstSourceData.ITEM_SOURCE_GM_CODE, addContext)
		local overflow = addContext.overFlowItems or {}
		local flat = {}

		for id, numInfo in pairs(overflow) do
			local total = 0

			if type(numInfo) == "table" then
				for _, n in pairs(numInfo) do
					total = total + (n or 0)
				end
			else
				total = numInfo or 0
			end

			flat[#flat + 1] = {
				itemId = id,
				num = total
			}
		end

		return {
			ok = ok and true or false,
			uid = player.uid,
			itemId = itemId,
			count = count,
			mailId = addContext.overFlowMailId,
			overFlowItems = flat,
			recentAddGenIds = addContext.recentAddGenIds
		}
	end

	function TestManager.pet_mail_overflow(uid, templateId, count, mailId)
		local player = uid and getPlayer(uid, 1) or dm.player(1)

		if not player then
			return "player not found"
		end

		templateId = tonumber(templateId)

		if not templateId then
			for petId, petInfo in pairs(player.pets) do
				templateId = petInfo.templateId

				break
			end
		end

		if not templateId or not PetData[templateId] then
			return "templateId required"
		end

		count = tonumber(count) or 1

		local createInfo = {}

		for i = 1, count do
			createInfo[i] = {
				templateId = templateId
			}
		end

		local addPetContext = {
			enableOverFlowMail = true,
			overFlowMailReason = "tm_pet_overflow",
			sendOverFlowMail = true,
			petCreateRecord = {}
		}

		if mailId then
			addPetContext.overFlowMailId = tonumber(mailId)
		end

		local results = player:batchAddPets(createInfo, Const.PET_FROM_GM or 0, addPetContext)
		local addedPets = {}

		for _, r in ipairs(results or EMPTY_TABLE) do
			addedPets[#addedPets + 1] = r[1]
		end

		local overflowPets = {}

		for _, info in ipairs(addPetContext.overFlowPets or EMPTY_TABLE) do
			overflowPets[#overflowPets + 1] = info and info.templateId or 0
		end

		return {
			ok = true,
			uid = player.uid,
			templateId = templateId,
			count = count,
			mailId = addPetContext.overFlowMailId,
			addedPets = addedPets,
			overFlowPets = overflowPets
		}
	end

	function TestManager.breed_mail_flow(invitorUid, inviteeUid, srcPetId, dstPetId, selectInfo, delay)
		if not CommonSwitch.SOCIAL_TXN_BREED then
			return "SOCIAL_TXN_BREED off"
		end

		return TestManager.breed_flow(invitorUid, inviteeUid, srcPetId, dstPetId, selectInfo, delay)
	end

	function TestManager.lock_mark(uid, petId, lockType)
		local player = uid and getPlayer(uid, 1) or dm.player(1)

		if not player then
			return "player not found"
		end

		local data = dm.test_manager_data or {}

		petId = petId and tostring(petId)

		if not petId then
			for pid, _ in pairs(player.pets) do
				petId = pid

				break
			end
		end

		if not petId or not player.pets[petId] then
			return "pet not found"
		end

		lockType = tonumber(lockType) or SocialConst.SOCIAL_TXN_LOCK_EXCHANGE

		local lockId = "tm_lock_" .. tostring(player.uid) .. "_" .. tostring(petId)
		local petInfo = player.pets[petId]

		petInfo.socialTxnLockId = lockId
		petInfo.socialTxnLockType = lockType

		return {
			uid = player.uid,
			petId = petId,
			lockId = lockId,
			lockType = lockType
		}
	end

	function TestManager.lock_clear(uid, petId)
		local player = uid and getPlayer(uid, 1) or dm.player(1)

		if not player then
			return "player not found"
		end

		petId = petId and tostring(petId)

		local cleared = {}

		if petId then
			local petInfo = player.pets[petId]

			if petInfo then
				petInfo.socialTxnLockId = ""
				petInfo.socialTxnLockType = 0
				cleared[#cleared + 1] = petId
			end
		else
			for pid, petInfo in pairs(player.pets) do
				if type(petInfo.socialTxnLockId) == "string" and petInfo.socialTxnLockId ~= "" then
					petInfo.socialTxnLockId = ""
					petInfo.socialTxnLockType = 0
					cleared[#cleared + 1] = pid
				end
			end
		end

		return {
			uid = player.uid,
			petId = petId,
			cleared = cleared
		}
	end

	function TestManager.lock_try_basic_ops(uid, petId)
		local player = uid and getPlayer(uid, 1) or dm.player(1)

		if not player then
			return "player not found"
		end

		petId = petId and tostring(petId)

		if not petId then
			for pid, _ in pairs(player.pets) do
				petId = pid

				break
			end
		end

		if not petId or not player.pets[petId] then
			return "pet not found"
		end

		if not player:isPetLockedBySocialTxn(petId) then
			return {
				ok = false,
				err = "pet not locked; call tm.lock_mark(uid, petId) first",
				uid = player.uid,
				petId = petId
			}
		end

		local function noticeRepr(code)
			if not code then
				return nil
			end

			return NoticeDef.getRepr and NoticeDef.getRepr(code) or code
		end

		local results = {}

		do
			local ok, code = player:checkBatchRemovePets({
				petId
			}, Const.PET_REMOVE_RECYCLE)

			results.recycle = {
				ok = ok and true or false,
				notice = noticeRepr(code)
			}
		end

		do
			local res = player:addPetExp(petId, 1, ItemConstSourceData.ITEM_SOURCE_GM_CODE)

			results.addExp = {
				ok = res and true or false
			}
		end

		do
			local rpcRet = player:RPC_CS_PetBreakthrough(petId)
			local code = rpcRet and rpcRet[1]

			results.breakthrough = {
				ok = code == NoticeDef.SUCCESS,
				notice = noticeRepr(code)
			}
		end

		do
			local code = player:petEvolve(petId, 1, false, true)

			results.evolve = {
				ok = code == NoticeDef.SUCCESS,
				notice = noticeRepr(code)
			}
		end

		do
			local current = player.prepareFormationList[player.curPetFormationIndex]
			local formation = current and current.formation and current.formation:getRawTable() or {}

			if not lume.find(formation, petId) then
				formation[#formation + 1] = petId
			end

			local rpcRet = player:RPC_CS_ModifyPrepareFormation(player.curPetFormationIndex, formation, true)

			results.formation = {
				ok = rpcRet and rpcRet[1] == true
			}
		end

		do
			local lockedBefore = player:isPetLockedBySocialTxn(petId)

			player:RPC_CS_PetBoxMovePet(petId, 1, 1)

			results.boxMove = {
				locked = lockedBefore
			}
		end

		local petInfo = player.pets[petId]

		return {
			uid = player.uid,
			petId = petId,
			lockId = petInfo.socialTxnLockId,
			lockType = petInfo.socialTxnLockType,
			results = results
		}
	end

	function TestManager.status(socialId)
		local data = dm.test_manager_data or {}
		local social = getSocial(socialId or data.socialId)
		local invitorPlayer = data.invitorPlayer or getPlayer(data.invitorUid, 1)
		local inviteePlayer = data.inviteePlayer or getPlayer(data.inviteeUid, 2)

		return {
			socialId = socialId or data.socialId,
			visible = social ~= nil,
			started = isSocialStarted(data),
			step = data.lastStep,
			err = data.lastError,
			switches = {
				breed = CommonSwitch.SOCIAL_TXN_BREED,
				exchange = CommonSwitch.SOCIAL_TXN_EXCHANGE
			},
			invitor = invitorPlayer and {
				uid = invitorPlayer.uid,
				cur = invitorPlayer.curSocialType,
				pet = getPetBrief(invitorPlayer, data.srcPetId),
				txns = getTxnBriefList(invitorPlayer)
			} or "nil",
			invitee = inviteePlayer and {
				uid = inviteePlayer.uid,
				cur = inviteePlayer.curSocialType,
				pet = getPetBrief(inviteePlayer, data.dstPetId),
				txns = getTxnBriefList(inviteePlayer)
			} or "nil"
		}
	end

	function TestManager.help()
		local res = {
			"--- Social basic flow ---",
			"tm.find_breed_pair(uid1, uid2)                         -- find usable breed pets",
			"tm.breed_flow(uid1, uid2, srcPetId?, dstPetId?, selectInfo?, delay?) -- full breed flow",
			"tm.find_exchange_pair(uid1, uid2)                      -- find usable exchange pets",
			"tm.exchange_flow(uid1, uid2, srcPetId?, dstPetId?, useTxn?, delay?) -- full exchange flow",
			"tm.prepare_breed(...) / tm.prepare_exchange(...)       -- prepare test context",
			"tm.invite() + tm.reply()                               -- create and accept social invite",
			"tm.breed_ops() / tm.exchange_ops()                     -- async client ops",
			"tm.breed_ops_now() / tm.exchange_ops_now()             -- only when SocialService is visible here",
			"tm.txn_switch(breed?, exchange?)                       -- view or set txn switches",
			"tm.status()                                            -- current test summary",
			"",
			"--- Fault injection (debug only) ---",
			"tm.fault_set(uid, point, opts?)                        -- opts: count/action/socialId/txnType/reason",
			"tm.fault_clear(uid?, point?)                           -- clear all, one uid, or one point",
			"tm.fault_list(uid?)                                    -- list active fault points",
			"tm.txn_list(uid?)                                      -- list social pending txns",
			"tm.txn_dump(uid, txnIdOrSocialId?)                     -- dump one txn summary",
			"tm.txn_retry(uid, txnIdOrSocialId?)                    -- run retryFunc without waiting heartbeat",
			"tm.txn_force_clear(uid, txnId)                         -- force remove broken test txn by exact txnId",
			"tm.lock_try_remove(uid, petId?)                        -- check locked pet remove rejection",
			"tm.lock_try_exchange(uid1, uid2, petId1?, petId2?)     -- check locked pet exchange rejection",
			"",
			"--- R2 overflow mail / lock smoke ---",
			"tm.item_mail_overflow(uid?, itemId?, count?, mailId?)  -- trigger item overflow mail",
			"tm.pet_mail_overflow(uid?, templateId?, count?, mailId?) -- trigger pet overflow mail",
			"tm.breed_mail_flow(uid1, uid2, srcPetId?, dstPetId?)   -- run breed flow under bag-full",
			"tm.lock_mark(uid, petId?, lockType?)                   -- manually set socialTxn lock",
			"tm.lock_clear(uid, petId?)                             -- clear socialTxn lock(s)",
			"tm.lock_try_basic_ops(uid, petId?)                     -- smoke recycle/exp/evolve/formation/boxMove rejection"
		}

		return lume.tonumstrkey(res, 3)
	end

	function TestManager.settleBreed()
		local social = getSocial()

		if not social then
			return "social not found"
		end

		for _, info in pairs(social.socialInfo.players) do
			info.petInfo = info.petInfo or {
				id = "123"
			}
			info.confirm = true
			info.selectInfo = {}
		end

		social:_checkAllConfirmAndSettle()
	end

	function TestManager.settleExchange()
		local social = getSocial()

		if not social then
			return "social not found"
		end

		for _, info in pairs(social.socialInfo.players) do
			info.petInfo = info.petInfo or {
				id = "123"
			}
			info.confirm = true
			info.clicked = true
		end

		social:_checkAllConfirmAndSettle()
	end
end

if TEST_CATCH_ROGUE then
	local player = dm.player(1)

	function TestManager.get_data()
		local spaceInfo

		if player:isInCatchRogueSpace() then
			local space = player.space

			spaceInfo = {
				repr = space:repr(),
				levelId = space.levelId,
				status = (DungeonConst.STATUS_HANDLER[space.status] or "") .. string.format("(%d)", space.status),
				isPausing = space.isPausing,
				stateRemainTime = space:getStateRemainTime(),
				result = space.result,
				teleportNpc = space.teleportNpc,
				levelRemainTime = space.levelRemainTime
			}
		end

		return {
			_ballList = player.catchRogueInfo:getValidBallCountPairs(player),
			_finishCount = {
				player.catchRogueInfo:getCurPuppetFinishCount()
			},
			_canGetAddOnSet = player.catchRogueInfo:getCurCanGetAddOnSet(),
			catchRogueInfo = player.catchRogueInfo:getRawTable(),
			catchRogueDelayResetGameId = player.catchRogueDelayResetGameId,
			remainCountStr = player.catchRogueInfo:getGameCntRepr(),
			spaceInfo = spaceInfo
		}
	end

	function TestManager.reset_game(newGameId)
		newGameId = newGameId or 1

		player:tryResetCatchRoguePhase(newGameId)

		return TestManager.get_data()
	end

	function TestManager.op(op, params)
		return player:RPC_CS_CatchRogueOp(op, params)
	end

	local OpDef = require("Common.OpDef")

	function TestManager.update_pets(ids)
		ids = ids or player.petPrepareList:getRawTable()

		lume.reverseInPlace(ids)

		return TestManager.op(OpDef.OP.CS_CR_UpdatePets, {
			petIds = ids or {}
		})
	end

	function TestManager.update_balls(ids)
		ids = ids or {
			110003,
			111002,
			110008,
			110009,
			111003
		}

		return TestManager.op(OpDef.OP.CS_CR_UpdateBalls, {
			ballIds = ids or {}
		})
	end

	function TestManager.update_ball_count(countMap)
		countMap = countMap or {
			[110003] = 1,
			[111002] = 1
		}

		return TestManager.op(OpDef.OP.CS_CR_UpdateBallCount, {
			ballCountMap = countMap or {}
		})
	end

	function TestManager.game_enter()
		return TestManager.op(OpDef.OP.CS_CR_GameEnter, {})
	end

	function TestManager.game_start()
		return TestManager.op(OpDef.OP.CS_CR_GameStart, {})
	end

	function TestManager.time_stop()
		player.space:pauseGameByType(Const.GameTimeScaleType.TEST, -1)
	end

	function TestManager.time_start()
		player.space:resumeGameByType(Const.GameTimeScaleType.TEST)
	end

	function TestManager.game_save()
		return TestManager.op(OpDef.OP.CS_CR_GameSave, {})
	end

	function TestManager.dungeon_finish(result)
		player.space:onDungeonFinish(result)
	end

	function TestManager.game_settle(isQuit, purchaseType)
		return TestManager.op(OpDef.OP.CS_CR_GameSettle, {
			isQuit = isQuit or false,
			purchaseType = purchaseType
		})
	end

	function TestManager.game_next()
		return TestManager.op(OpDef.OP.CS_CR_GameNext, {})
	end
end

if TEST_BOSS_CATCH then
	local player = dm.player(1)
	local ballItemId = 110001

	function TestManager.test1(actorId)
		local ent = pg.getEntityByActorId(actorId)

		player:RPC_CS_CaptureBossMonster(ent.id, ballItemId, true)

		return "ok"
	end

	function TestManager.test2(actorId)
		local ent = pg.getEntityByActorId(actorId)

		player:RPC_CS_CaptureBossMonster(ent.id, ballItemId, true)
		TimerManager.addTimer(1, function()
			player:RPC_CS_CaptureBossMonster(ent.id, ballItemId, true)
		end)

		return "ok"
	end
end

if TEST_PHOTO_PRESET then
	local player = dm.player(1)
	local testId = "user_68ff5d065b1e7e13f0e6baa0"
	local testInfo = {
		"test photo preset string"
	}

	function TestManager.get_data()
		return player.photoPresetInfo:dump()
	end

	function TestManager.save_add(info)
		info = info or testInfo

		return player:RPC_CS_SavePhotoPresetAdd(Utils.encodeToStr(info))
	end

	function TestManager.save_del(id)
		id = id or testId

		return player:RPC_CS_SavePhotoPresetDel(id)
	end

	function TestManager.like_add(id)
		id = id or testId

		return player:RPC_CS_LikePhotoPresetAdd(id)
	end

	function TestManager.like_del(id)
		id = id or testId

		return player:RPC_CS_LikePhotoPresetDel(id)
	end

	function TestManager.clear()
		player.photoPresetInfo.savedIdMap = {}
		player.photoPresetInfo.likedIdMap = {}

		return "ok"
	end
end

if TEST_ROBEGG_CATCH then
	TestManager.log = "createCollectItemEntities|pet_change_flow"

	local player = dm.player(1)
	local puppetTemplateId = 11005100050
	local ballItemId = 110003

	function TestManager:prepare()
		player:addItemById(ballItemId, 10)

		return {
			pg.gmMgr():teleportToScene(player, 3004, 0)
		}
	end

	function TestManager.create()
		return {
			pg.gmMgr():createPuppet(player, puppetTemplateId, 1, 3, 1, 1, -1, 0, 0, nil)
		}
	end

	function TestManager.catch(actorId)
		local ent = pg.getEntityByActorId(actorId)

		player:captureAndSettleInstant({
			ent.id
		}, ballItemId, true)
		player:captureAndSettleInstantFinish({
			ent.id
		})
	end

	function TestManager.pick(actorId)
		local ent = pg.getEntityByActorId(actorId)
		local cidd = require("Data.collect_item_data")[ent.templateId]

		return player:handleInteract(Const.IACT_IP_COLLECT_ITEM, ent.id, cidd.actionPrototypeId, {})
	end

	function TestManager.exit()
		player.space:onExtractAlarm(player.id)
	end

	function TestManager:item()
		local ServerUtils = require("GameServer.ServerUtils")
		local dropResId = 5050020
		local pos = ServerUtils.genSpaceRandomPosition(player.space.id, player:getPosition(), 10, player:getRotation():ToYaw())

		return player.space:createCollectItemEntities(player, dropResId, pos, Quaternion.identity)
	end
end

if TEST_HOME_MANAGE then
	local player = dm.player(1)
	local space = dm.player(1).space
	local home = Utils.isHomeland(space.spaceType) and space
	local petIds = lume.sort(lume.keys(player.pets))
	local itemIds = lume.sort(lume.keys(lume.filter(require("Data.item_data"), function(v)
		return ToInt(v.homeFoodAdd) > 0
	end, true)))
	local petTmplIds = lume.sort(lume.keys(lume.filter(require("Data.pet_data"), function(v)
		return ToInt(v.homeFoodCostSpeed) > 0
	end, true)))

	function TestManager.get_data()
		return {
			_2_homeBoxs = home and home.petBoxMap:getRawTable(),
			_3_foodItemMaxCount = require("Data.homeland_config_data").foodItemMaxCount or 0,
			_3_foodFacilityIds = Utils.deepCopyTable(require("Data.homeland_config_data").foodFacilityIds) or {},
			_3_petIds = lume.first(petIds, 5),
			_4_itemIds = lume.first(itemIds, 10),
			_5_petTmplIds = lume.first(petTmplIds, 10),
			_6_slotRepr = home and home.homeFoodSlotList:repr(home) or "nil",
			_7_slotList = home and home.homeFoodSlotList:getRawTable()
		}
	end

	function TestManager.add_pets(ids)
		local petIds = type(ids) == "table" and ids or lume.first(petIds, ids or 1)

		return player:RPC_CS_BatchAddHomelandPet(petIds, Const.HOMELAND_AREA_TYPE.PRODUCE)
	end

	function TestManager.del_pets(ids)
		local petIds = type(ids) == "table" and ids or lume.first(petIds, ids or 1)
		local homeSlotIndexes = {}

		for index, petId in ipairs(petIds) do
			local areaId, homeSlotIndex

			if home then
				areaId, homeSlotIndex = home.petBoxMap:getPetIndex(petId)
			end

			homeSlotIndexes[index] = areaId == Const.HOMELAND_AREA_TYPE.PRODUCE and homeSlotIndex or -1
		end

		return player:RPC_CS_BatchRemoveHomelandPet(petIds, Const.HOMELAND_AREA_TYPE.PRODUCE, homeSlotIndexes, -1)
	end

	function TestManager.add_pet(id)
		local petId = type(id) == "string" and id or petIds[id]

		return player:RPC_CS_AddHomelandPet(petId, Const.HOMELAND_AREA_TYPE.PRODUCE, -1)
	end

	function TestManager.del_pet(id)
		local petId = type(id) == "string" and id or petIds[id]
		local areaId, homeSlotIndex

		if home then
			areaId, homeSlotIndex = home.petBoxMap:getPetIndex(petId)
		end

		return player:RPC_CS_RemoveHomelandPet(petId, areaId or Const.HOMELAND_AREA_TYPE.PRODUCE, homeSlotIndex or -1, -1, -1)
	end

	function TestManager.add_item(itemId, itemNum)
		return player:RPC_CS_HomelandFoodOp(OpDef.OP.CS_HF_AddItem, {
			itemId = itemId,
			itemNum = itemNum
		})
	end

	function TestManager.clear_slot(slotIndex)
		return player:RPC_CS_HomelandFoodOp(OpDef.OP.CS_HF_ClearSlot, {
			slotIndex = slotIndex
		})
	end

	function TestManager.refresh(seconds1, seconds2)
		local offlineFromTs = seconds1 and Time.secondCache + seconds1 or nil

		Time.secondCache = seconds2 and Time.secondCache + seconds2 or Time.secondCache
		Time.realSecondCache = Time.getTickSecond()

		return home and home.homeFoodSlotList:refreshWorking(home, offlineFromTs)
	end
end

if TEST_HOME_CAMP then
	local specEnt = require("Globals").specificEntity
	local CommonSwitch = require("Common.CommonSwitch")
	local HomeLandUtils = require("Common.Utils.HomeLandUtils")
	local HomeCampTenantUtils = require("Common.Utils.HomeCampTenantUtils")
	local HomeCampLineUid = require("Common.Utils.HomeCampLineUid")
	local HomeCampConst = require("Common.Const.HomeCampConst")
	local HomeCampData = require("Data.home_camp_data")
	local GameServerRepo = require("Core.Server.GameServerRepo")
	local ServerSwitch = require("ServerSwitch")
	local LOG_TAG = "test_home_camp"
	local player = dm.player(1)
	local defaultCampStaticId = 83980508
	local defaultAreaId = 1
	local defaultBucketId = 0
	local defaultBucketCount = HomeCampConst.DEFAULT_BUCKET_COUNT

	if not HomeCampTenantUtils._initialized then
		HomeCampTenantUtils.init()
	end

	local function logCallback(tag, result, response)
		local ok = result.status and response.flag ~= false
		local status = ok and "OK" or "FAIL"

		specEnt.logger:debug("[%s] %s  result=%s response=%s", LOG_TAG, tag, inspect(result, {
			depth = 1
		}), inspect(response, {
			depth = 3
		}))

		return status, response
	end

	local function getTenantKey()
		local clusterId = player and player.serverId or GameServerRepo.gameServerClusterId

		return HomeCampTenantUtils.getTenantKey(clusterId)
	end

	local function getClusterId()
		return player and player.serverId or GameServerRepo.gameServerClusterId
	end

	local function isNewArch()
		return CommonSwitch.UseNewHomeCampArch
	end

	local function callLineService(method, args, tag)
		local tenantKey = args[1]
		local areaId = args[2]
		local bucketId = args[3]
		local hint = HomeCampTenantUtils.getBucketKey(tenantKey, areaId, bucketId)

		specEnt:callService("HomeCampLineService", method, args, function(result, response)
			logCallback(tag or method, result, response)
		end, {
			hint = hint
		})

		return "check log: " .. LOG_TAG
	end

	local function callDirectoryService(method, args, tag)
		specEnt:callService("HomeCampDirectoryService", method, args, function(result, response)
			logCallback(tag or method, result, response)
		end, {
			hint = player and player.id or "test"
		})

		return "check log: " .. LOG_TAG
	end

	local function callOldService(method, args, tag)
		specEnt:callService("HomeCampService", method, args, function(result, response)
			logCallback(tag or method, result, response)
		end, {
			hint = player and player.id or "test"
		})

		return "check log: " .. LOG_TAG
	end

	function TestManager.imp(clusterId)
		local _, srv = next(pg.ent("HomeCampService"))

		if not srv then
			return nil
		end

		local imp = ServerSwitch.OneClusterOneHomeCampService and srv.imps[clusterId] or srv.imp

		return imp
	end

	function TestManager.dirSrv()
		local _, srv = next(pg.ent("HomeCampDirectoryService"))

		if not srv then
			return nil
		end

		return srv
	end

	function TestManager.dirImp(clusterId)
		local _, srv = next(pg.ent("HomeCampDirectoryService"))

		if not srv then
			return nil
		end

		return clusterId and srv.imp.tenants[HomeCampTenantUtils.getTenantKey(clusterId)] or srv.imp
	end

	function TestManager.lineSrv()
		local _, srv = next(pg.ent("HomeCampLineService"))

		if not srv then
			return nil
		end

		return srv
	end

	function TestManager.bucket(key)
		return dm.srvObj("HomeCampLineService", "bucketKey", key)
	end

	function TestManager.arch()
		return {
			UseNewHomeCampArch = CommonSwitch.UseNewHomeCampArch,
			tenantKey = getTenantKey(),
			clusterId = getClusterId(),
			allAreaIds = HomeCampTenantUtils.getAllAreaIds(),
			defaultBucketCount = defaultBucketCount
		}
	end

	function TestManager.get_data(clusterId)
		local campCar = player and HomeLandUtils.getCampCarEntity(player.uid)
		local res = {}

		res.arch = TestManager.arch()
		res.playerInfo = player and next(player) and {
			repr = player:repr(),
			uid = player.uid,
			serverId = player.serverId,
			sceneId = player.space and player.space.sceneId,
			spaceRepr = player.space and player.space:repr(),
			dumpHomeCamp = player.dumpHomeCamp and player:dumpHomeCamp(),
			curCampLineUid = player.curCampLineUid,
			curCampTenantKey = player.curCampTenantKey,
			curCampAreaId = player.curCampAreaId,
			curCampBucketId = player.curCampBucketId
		}

		if not isNewArch() then
			local srvImp = TestManager.imp(clusterId or getClusterId())

			res.srvInfo = srvImp and {
				repr = srvImp:repr(),
				stat = srvImp:stat()
			}
		end

		res.campIds = inspect(lume.map(HomeCampData, "sceneId"), {
			newline = " "
		})
		res.campCar = campCar and {
			repr = campCar:repr(),
			nextCheckTs = TimeUtils.timeStampToUtcString(campCar.petsNextCheckTs),
			dispatchInfo = campCar.dispatchInfo and campCar.dispatchInfo:getRawTable() or "nil"
		}

		return res
	end

	function TestManager.dump_lines(areaId)
		if not isNewArch() then
			local srvImp = TestManager.imp(getClusterId())

			return srvImp and {
				stat = srvImp:stat(),
				dump = srvImp:dump()
			} or "old service not found"
		end

		local tenantKey = getTenantKey()
		local areas = areaId and {
			areaId
		} or HomeCampTenantUtils.getAllAreaIds()
		local pending = 0
		local results = {}

		for _, aid in ipairs(areas) do
			local bucketCount = HomeCampTenantUtils.getBucketCount(aid)

			for bid = 0, bucketCount - 1 do
				pending = pending + 1

				local hint = HomeCampTenantUtils.getBucketKey(tenantKey, aid, bid)

				specEnt:callService("HomeCampLineService", "CMD_GetBucketStat", {
					tenantKey,
					aid,
					bid
				}, function(result, response)
					pending = pending - 1

					local key = string.format("area%d_bucket%d", aid, bid)

					if result.status and response.flag then
						results[key] = response.stat
					else
						results[key] = {
							err = response and response.err or "failed"
						}
					end

					if pending == 0 then
						specEnt.logger:debug("[%s] dump_lines ALL done: %s", LOG_TAG, inspect(results, {
							depth = 4
						}))
					end
				end, {
					hint = hint
				})
			end
		end

		return string.format("fetching %d buckets, check log: %s", pending, LOG_TAG)
	end

	function TestManager.dump_snapshot(areaId, bucketId)
		if not isNewArch() then
			return "only available in new arch"
		end

		areaId = areaId or defaultAreaId
		bucketId = bucketId or defaultBucketId

		local tenantKey = getTenantKey()

		return callLineService("CMD_GetBucketSnapshot", {
			tenantKey,
			areaId,
			bucketId
		}, "dump_snapshot")
	end

	function TestManager.dump_directory(staticId, count)
		if not isNewArch() then
			return "only available in new arch"
		end

		staticId = staticId or defaultCampStaticId
		count = count or 50

		return callDirectoryService("CMD_GetRecommendCampLines", {
			player.uid,
			getClusterId(),
			staticId,
			count
		}, "dump_directory")
	end

	function TestManager.dump_dir_page(areaId, offset, limit)
		if not isNewArch() then
			return "only available in new arch"
		end

		areaId = areaId or defaultAreaId

		return callDirectoryService("CMD_QueryCampLines", {
			player.uid,
			getClusterId(),
			areaId,
			offset or 0,
			limit or 20
		}, "dump_dir_page")
	end

	function TestManager.old_login(staticId, forceNewLine)
		staticId = staticId or defaultCampStaticId

		return callOldService("CMD_LoginCamp", {
			getClusterId(),
			player.uid,
			staticId,
			player.homeBasicInfo and player.homeBasicInfo:getRawTable() or {},
			forceNewLine
		}, "old_login")
	end

	function TestManager.old_enter(staticId, forceNewLine)
		staticId = staticId or defaultCampStaticId

		return callOldService("CMD_EnterCamp", {
			getClusterId(),
			player.uid,
			staticId,
			forceNewLine
		}, "old_enter")
	end

	function TestManager.old_change(staticId, lineId)
		staticId = staticId or defaultCampStaticId

		return callOldService("CMD_ChangeCamp", {
			getClusterId(),
			player.uid,
			staticId,
			lineId or 0,
			ServerSwitch.ForceNewCampLine
		}, "old_change")
	end

	function TestManager.old_logout()
		return callOldService("CMD_LogoutOrLeaveCamp", {
			getClusterId(),
			player.uid
		}, "old_logout")
	end

	function TestManager.old_recommend(n, staticId)
		staticId = staticId or defaultCampStaticId

		return callOldService("CMD_GetCampListN", {
			player.uid,
			getClusterId(),
			n or 20,
			staticId
		}, "old_recommend")
	end

	function TestManager.old_get_by_ids(ids)
		ids = ids or {
			player.campSpaceKeyMap and player.campSpaceKeyMap[defaultCampStaticId] or ""
		}

		return callOldService("CMD_GetCampListByIds", {
			player.uid,
			getClusterId(),
			ids
		}, "old_get_by_ids")
	end

	function TestManager.old_heartbeat()
		return callOldService("CMD_Heartbeat", {
			player.uid,
			getClusterId()
		}, "old_heartbeat")
	end

	function TestManager.old_sync_info()
		return callOldService("CMD_SyncBasicInfo", {
			getClusterId(),
			player.uid,
			player.homeBasicInfo and player.homeBasicInfo:getRawTable() or {}
		}, "old_sync_info")
	end

	function TestManager.old_hb_timeout(timeout)
		return callOldService("CMD_SetHeartbeatTimeout", {
			getClusterId(),
			timeout or 60
		}, "old_hb_timeout")
	end

	function TestManager.old_hb_config()
		return callOldService("CMD_GetHeartbeatConfig", {
			getClusterId()
		}, "old_hb_config")
	end

	function TestManager.new_login(staticId, areaId, bucketId, specLineUid)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		staticId = staticId or defaultCampStaticId
		areaId = areaId or HomeCampTenantUtils.getAreaIdFromStaticId(staticId) or defaultAreaId
		bucketId = bucketId or HomeCampTenantUtils.selectBucketForLogin(areaId)

		local tenantKey = getTenantKey()
		local forceClusterId = HomeCampTenantUtils.getForceClusterId(getClusterId())

		return callLineService("CMD_LoginLine", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			staticId,
			player.homeBasicInfo and player.homeBasicInfo:getRawTable() or {},
			specLineUid or 0,
			forceClusterId
		}, "new_login")
	end

	function TestManager.new_enter(staticId, areaId, bucketId, specLineUid)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		staticId = staticId or defaultCampStaticId
		areaId = areaId or HomeCampTenantUtils.getAreaIdFromStaticId(staticId) or defaultAreaId
		bucketId = bucketId or HomeCampTenantUtils.selectBucketForLogin(areaId)

		local tenantKey = getTenantKey()
		local forceClusterId = HomeCampTenantUtils.getForceClusterId(getClusterId())

		return callLineService("CMD_EnterLine", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			staticId,
			specLineUid or 0,
			forceClusterId
		}, "new_enter")
	end

	function TestManager.new_leave(staticId, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		staticId = staticId or defaultCampStaticId
		areaId = areaId or player.curCampAreaId or defaultAreaId
		bucketId = bucketId or player.curCampBucketId or defaultBucketId

		local tenantKey = getTenantKey()

		return callLineService("CMD_LeaveLine", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			staticId
		}, "new_leave")
	end

	function TestManager.new_change(staticId, targetLineUid, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		staticId = staticId or defaultCampStaticId
		areaId = areaId or player.curCampAreaId or defaultAreaId
		bucketId = bucketId or player.curCampBucketId or defaultBucketId

		local tenantKey = getTenantKey()
		local forceClusterId = HomeCampTenantUtils.getForceClusterId(getClusterId())

		return callLineService("CMD_ChangeLine", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			staticId,
			targetLineUid or 0,
			forceClusterId
		}, "new_change")
	end

	function TestManager.new_switch(targetStaticId, targetLineUid, preferredBucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		targetStaticId = targetStaticId or defaultCampStaticId

		local tenantKey = getTenantKey()
		local areaId = player.curCampAreaId or defaultAreaId
		local bucketId = player.curCampBucketId or defaultBucketId
		local forceClusterId = HomeCampTenantUtils.getForceClusterId(getClusterId())

		return callLineService("CMD_SwitchCamp", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			targetStaticId,
			targetLineUid or 0,
			preferredBucketId or -1,
			player.homeBasicInfo and player.homeBasicInfo:getRawTable() or {},
			forceClusterId
		}, "new_switch")
	end

	function TestManager.new_logout(areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		areaId = areaId or player.curCampAreaId or defaultAreaId
		bucketId = bucketId or player.curCampBucketId or defaultBucketId

		local tenantKey = getTenantKey()

		return callLineService("CMD_LogoutLine", {
			tenantKey,
			areaId,
			bucketId,
			player.uid
		}, "new_logout")
	end

	function TestManager.new_create(staticId, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		staticId = staticId or defaultCampStaticId
		areaId = areaId or HomeCampTenantUtils.getAreaIdFromStaticId(staticId) or defaultAreaId
		bucketId = bucketId or defaultBucketId

		local tenantKey = getTenantKey()

		return callLineService("CMD_CreateLine", {
			tenantKey,
			areaId,
			bucketId,
			staticId,
			"stress_test"
		}, "new_create")
	end

	function TestManager.new_destroy(lineUid, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		if not lineUid then
			return "lineUid required"
		end

		areaId = areaId or HomeCampLineUid.getAreaId(lineUid)
		bucketId = bucketId or HomeCampLineUid.getBucketId(lineUid)

		local tenantKey = getTenantKey()

		return callLineService("CMD_DestroyLine", {
			tenantKey,
			areaId,
			bucketId,
			lineUid,
			"stress_test_destroy"
		}, "new_destroy")
	end

	function TestManager.new_heartbeat(areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		areaId = areaId or player.curCampAreaId or defaultAreaId
		bucketId = bucketId or player.curCampBucketId or defaultBucketId

		local tenantKey = getTenantKey()

		return callLineService("CMD_Heartbeat", {
			tenantKey,
			areaId,
			bucketId,
			player.uid
		}, "new_heartbeat")
	end

	function TestManager.new_sync_info(areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		areaId = areaId or player.curCampAreaId or defaultAreaId
		bucketId = bucketId or player.curCampBucketId or defaultBucketId

		local tenantKey = getTenantKey()

		return callLineService("CMD_SyncBasicInfo", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			player.homeBasicInfo and player.homeBasicInfo:getRawTable() or {}
		}, "new_sync_info")
	end

	function TestManager.new_bucket_stat(areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		areaId = areaId or defaultAreaId
		bucketId = bucketId or defaultBucketId

		local tenantKey = getTenantKey()

		return callLineService("CMD_GetBucketStat", {
			tenantKey,
			areaId,
			bucketId
		}, "new_bucket_stat")
	end

	function TestManager.dir_recommend(staticId, count)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		staticId = staticId or defaultCampStaticId

		return callDirectoryService("CMD_GetRecommendCampLines", {
			player.uid or "",
			getClusterId(),
			staticId,
			count or 20
		}, "dir_recommend")
	end

	function TestManager.dir_find_code(displayCode)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		return callDirectoryService("CMD_FindCampByCode", {
			player.uid or "",
			getClusterId(),
			displayCode or "A1-TEST"
		}, "dir_find_code")
	end

	function TestManager.dir_get_by_ids(lineUids)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		lineUids = lineUids or {}

		return callDirectoryService("CMD_GetLinesByIds", {
			player.uid or "",
			getClusterId(),
			lineUids
		}, "dir_get_by_ids")
	end

	function TestManager.dir_get_by_keys(spaceKeys)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		spaceKeys = spaceKeys or {
			player.campSpaceKeyMap and player.campSpaceKeyMap[defaultCampStaticId] or ""
		}

		return callDirectoryService("CMD_GetLinesBySpaceKeys", {
			player.uid or "",
			getClusterId(),
			spaceKeys
		}, "dir_get_by_keys")
	end

	function TestManager.dir_query(areaId, offset, limit)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		return callDirectoryService("CMD_QueryCampLines", {
			player.uid or "",
			getClusterId(),
			areaId or defaultAreaId,
			offset or 0,
			limit or 20
		}, "dir_query")
	end

	function TestManager.dir_route(lineUid)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		if not lineUid then
			return "lineUid required"
		end

		local tenantKey = getTenantKey()

		return callDirectoryService("CMD_GetLineRoute", {
			player.uid or "",
			tenantKey,
			lineUid
		}, "dir_route")
	end

	function TestManager.dir_select_bucket(areaId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		local tenantKey = getTenantKey()

		return callDirectoryService("CMD_SelectJoinBucket", {
			player.uid or "",
			tenantKey,
			areaId or defaultAreaId
		}, "dir_select_bucket")
	end

	function TestManager.relogin()
		player:logoutHomeCamp()
		TimerManager.addTimer(1, function()
			player:loginHomeCamp()
		end)

		return "relogin scheduled"
	end

	function TestManager.gotocamp(staticId)
		player.banAutoDetectPhase = {}

		pg.gmMgr():gotoByStaticId(player, staticId or defaultCampStaticId)
	end

	function TestManager.force_unlock_camp(staticId)
		staticId = staticId or defaultCampStaticId

		return pg.gmMgr():unlockHomeCamp(player, staticId, 1)
	end

	function TestManager.unlock(staticId)
		player.isHomeCampUnlocked = false

		player:_handleCampUnlockCamp(staticId or defaultCampStaticId, "hello", {})
	end

	function TestManager.change(staticId, lineId)
		return player:_handleCampChangeCamp(staticId or defaultCampStaticId, lineId or 0)
	end

	function TestManager.enter_self()
		return player:RPC_CS_ReqEnterSelfHomeCamp()
	end

	function TestManager.enter_other(spaceKey, uid)
		return player:RPC_CS_ReqEnterHomeCamp(spaceKey, uid)
	end

	function TestManager.rfhCar()
		if player.space and player.space.refreshCampCarEntities then
			player.space:refreshCampCarEntities(true)
		else
			return "not in camp space"
		end
	end

	function TestManager.rfhPet()
		local campCar = HomeLandUtils.getCampCarEntity(player.uid)

		return campCar and campCar:refreshHomePetEntities(true) or "campCar not found"
	end

	function TestManager.stress_login(count, staticId, interval)
		count = count or 10
		staticId = staticId or defaultCampStaticId
		interval = interval or 0

		local ok, fail = 0, 0
		local startTs = Time.secondCache

		local function doLogin(i)
			local fakeUid = string.format("stress_%d_%d", startTs, i)
			local fakeBasicInfo = {
				level = 1,
				name = "StressBot" .. i,
				carShapeInfo = {}
			}

			if isNewArch() then
				local tenantKey = getTenantKey()
				local areaId = HomeCampTenantUtils.getAreaIdFromStaticId(staticId) or defaultAreaId
				local bucketId = HomeCampTenantUtils.selectBucketForLogin(areaId)
				local forceClusterId = HomeCampTenantUtils.getForceClusterId(getClusterId())
				local hint = HomeCampTenantUtils.getBucketKey(tenantKey, areaId, bucketId)

				specEnt:callService("HomeCampLineService", "CMD_LoginLine", {
					tenantKey,
					areaId,
					bucketId,
					fakeUid,
					staticId,
					fakeBasicInfo,
					0,
					forceClusterId
				}, function(result, response)
					if result.status and response.flag then
						ok = ok + 1
					else
						fail = fail + 1
					end

					if ok + fail == count then
						specEnt.logger:debug("[%s] stress_login DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
					end
				end, {
					hint = hint
				})
			else
				specEnt:callService("HomeCampService", "CMD_LoginCamp", {
					getClusterId(),
					fakeUid,
					staticId,
					fakeBasicInfo,
					true
				}, function(result, response)
					if result.status and response.flag then
						ok = ok + 1
					else
						fail = fail + 1
					end

					if ok + fail == count then
						specEnt.logger:debug("[%s] stress_login DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
					end
				end, {
					hint = "stress" .. i
				})
			end
		end

		for i = 1, count do
			if interval > 0 then
				TimerManager.addTimer(interval * (i - 1), function()
					doLogin(i)
				end)
			else
				doLogin(i)
			end
		end

		return string.format("stress_login started: count=%d, staticId=%s, check log: %s", count, staticId, LOG_TAG)
	end

	function TestManager.stress_recommend(count, staticId)
		count = count or 50
		staticId = staticId or defaultCampStaticId

		local ok, fail = 0, 0
		local startTs = Time.secondCache

		for i = 1, count do
			if isNewArch() then
				specEnt:callService("HomeCampDirectoryService", "CMD_GetRecommendCampLines", {
					player.uid,
					getClusterId(),
					staticId,
					20
				}, function(result, response)
					if result.status and response.flag then
						ok = ok + 1
					else
						fail = fail + 1
					end

					if ok + fail == count then
						specEnt.logger:debug("[%s] stress_recommend DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
					end
				end, {
					hint = player.id
				})
			else
				specEnt:callService("HomeCampService", "CMD_GetCampListN", {
					player.uid,
					getClusterId(),
					20,
					staticId
				}, function(result, response)
					if result.status and response.flag then
						ok = ok + 1
					else
						fail = fail + 1
					end

					if ok + fail == count then
						specEnt.logger:debug("[%s] stress_recommend DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
					end
				end, {
					hint = player.id
				})
			end
		end

		return string.format("stress_recommend started: count=%d, check log: %s", count, LOG_TAG)
	end

	function TestManager.stress_heartbeat(count)
		count = count or 100

		local ok, fail = 0, 0
		local startTs = Time.secondCache

		for i = 1, count do
			if isNewArch() then
				local tenantKey = getTenantKey()
				local areaId = player.curCampAreaId or defaultAreaId
				local bucketId = player.curCampBucketId or defaultBucketId
				local hint = HomeCampTenantUtils.getBucketKey(tenantKey, areaId, bucketId)

				specEnt:callService("HomeCampLineService", "CMD_Heartbeat", {
					tenantKey,
					areaId,
					bucketId,
					player.uid
				}, function(result, response)
					if result.status and response.flag then
						ok = ok + 1
					else
						fail = fail + 1
					end

					if ok + fail == count then
						specEnt.logger:debug("[%s] stress_heartbeat DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
					end
				end, {
					hint = hint
				})
			else
				specEnt:callService("HomeCampService", "CMD_Heartbeat", {
					player.uid,
					getClusterId()
				}, function(result, response)
					if result.status and response.flag then
						ok = ok + 1
					else
						fail = fail + 1
					end

					if ok + fail == count then
						specEnt.logger:debug("[%s] stress_heartbeat DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
					end
				end, {
					hint = player.id
				})
			end
		end

		return string.format("stress_heartbeat started: count=%d, check log: %s", count, LOG_TAG)
	end

	function TestManager.stress_lifecycle(count, staticId)
		count = count or 10
		staticId = staticId or defaultCampStaticId

		local ok, fail = 0, 0
		local startTs = Time.secondCache

		for i = 1, count do
			local fakeUid = string.format("lifecycle_%d_%d", startTs, i)
			local fakeBasicInfo = {
				level = 1,
				name = "LifeBot" .. i,
				carShapeInfo = {}
			}

			if isNewArch() then
				local tenantKey = getTenantKey()
				local areaId = HomeCampTenantUtils.getAreaIdFromStaticId(staticId) or defaultAreaId
				local bucketId = HomeCampTenantUtils.selectBucketForLogin(areaId)
				local hint = HomeCampTenantUtils.getBucketKey(tenantKey, areaId, bucketId)
				local forceClusterId = HomeCampTenantUtils.getForceClusterId(getClusterId())

				specEnt:callService("HomeCampLineService", "CMD_LoginLine", {
					tenantKey,
					areaId,
					bucketId,
					fakeUid,
					staticId,
					fakeBasicInfo,
					0,
					forceClusterId
				}, function(result, response)
					if result.status and response.flag then
						specEnt:callService("HomeCampLineService", "CMD_LogoutLine", {
							tenantKey,
							areaId,
							bucketId,
							fakeUid
						}, function(r2, resp2)
							if r2.status and resp2.flag then
								ok = ok + 1
							else
								fail = fail + 1
							end

							if ok + fail == count then
								specEnt.logger:debug("[%s] stress_lifecycle DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
							end
						end, {
							hint = hint
						})
					else
						fail = fail + 1

						if ok + fail == count then
							specEnt.logger:debug("[%s] stress_lifecycle DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
						end
					end
				end, {
					hint = hint
				})
			else
				specEnt:callService("HomeCampService", "CMD_LoginCamp", {
					getClusterId(),
					fakeUid,
					staticId,
					fakeBasicInfo,
					true
				}, function(result, response)
					if result.status and response.flag then
						specEnt:callService("HomeCampService", "CMD_LogoutOrLeaveCamp", {
							getClusterId(),
							fakeUid
						}, function(r2, resp2)
							if r2.status and resp2.flag then
								ok = ok + 1
							else
								fail = fail + 1
							end

							if ok + fail == count then
								specEnt.logger:debug("[%s] stress_lifecycle DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
							end
						end, {
							hint = "stress" .. i
						})
					else
						fail = fail + 1

						if ok + fail == count then
							specEnt.logger:debug("[%s] stress_lifecycle DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
						end
					end
				end, {
					hint = "stress" .. i
				})
			end
		end

		return string.format("stress_lifecycle started: count=%d, check log: %s", count, LOG_TAG)
	end

	function TestManager.stress_create_destroy(count, staticId, areaId, bucketId)
		if not isNewArch() then
			return "only available in new arch"
		end

		count = count or 5
		staticId = staticId or defaultCampStaticId
		areaId = areaId or HomeCampTenantUtils.getAreaIdFromStaticId(staticId) or defaultAreaId
		bucketId = bucketId or defaultBucketId

		local tenantKey = getTenantKey()
		local hint = HomeCampTenantUtils.getBucketKey(tenantKey, areaId, bucketId)
		local ok, fail = 0, 0
		local startTs = Time.secondCache

		for i = 1, count do
			specEnt:callService("HomeCampLineService", "CMD_CreateLine", {
				tenantKey,
				areaId,
				bucketId,
				staticId,
				"stress_create_" .. i
			}, function(result, response)
				if result.status and response.flag and response.lineUid then
					specEnt:callService("HomeCampLineService", "CMD_DestroyLine", {
						tenantKey,
						areaId,
						bucketId,
						response.lineUid,
						"stress_destroy_" .. i
					}, function(r2, resp2)
						if r2.status and resp2.flag then
							ok = ok + 1
						else
							fail = fail + 1
						end

						if ok + fail == count then
							specEnt.logger:debug("[%s] stress_create_destroy DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
						end
					end, {
						hint = hint
					})
				else
					fail = fail + 1

					if ok + fail == count then
						specEnt.logger:debug("[%s] stress_create_destroy DONE: ok=%d, fail=%d, elapsed=%ds", LOG_TAG, ok, fail, Time.secondCache - startTs)
					end
				end
			end, {
				hint = hint
			})
		end

		return string.format("stress_create_destroy started: count=%d, check log: %s", count, LOG_TAG)
	end

	function TestManager.stress_mixed(loginCount, hbCount, recCount)
		loginCount = loginCount or 10
		hbCount = hbCount or 20
		recCount = recCount or 20

		specEnt.logger:debug("[%s] stress_mixed starting: login=%d, hb=%d, rec=%d", LOG_TAG, loginCount, hbCount, recCount)
		TestManager.stress_login(loginCount)
		TestManager.stress_heartbeat(hbCount)
		TestManager.stress_recommend(recCount)

		return string.format("stress_mixed started: login=%d, hb=%d, rec=%d, check log: %s", loginCount, hbCount, recCount, LOG_TAG)
	end

	function TestManager.priv_create()
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		return player:_handleCampCreatePrivateLine()
	end

	function TestManager.priv_create_cmd(staticId, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		staticId = staticId or defaultCampStaticId
		areaId = areaId or player.curCampAreaId or HomeCampTenantUtils.getAreaIdFromStaticId(staticId) or defaultAreaId
		bucketId = bucketId or player.curCampBucketId or defaultBucketId

		local tenantKey = getTenantKey()
		local forceClusterId = HomeCampTenantUtils.getForceClusterId(getClusterId())

		return callLineService("CMD_CreatePrivateLine", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			staticId,
			player.homeBasicInfo and player.homeBasicInfo:getRawTable() or {},
			forceClusterId
		}, "priv_create")
	end

	function TestManager.priv_dissolve()
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		return player:_handleCampDissolvePrivateLine()
	end

	function TestManager.priv_dissolve_cmd(lineUid, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		lineUid = lineUid or player.curCampLineUid

		if not lineUid or lineUid <= 0 then
			return "lineUid required (or login to camp first)"
		end

		areaId = areaId or HomeCampLineUid.getAreaId(lineUid)
		bucketId = bucketId or HomeCampLineUid.getBucketId(lineUid)

		local tenantKey = getTenantKey()

		return callLineService("CMD_DissolvePrivateLine", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			lineUid
		}, "priv_dissolve")
	end

	function TestManager.priv_set_perm(permissions)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		permissions = permissions or HomeCampConst.DEFAULT_PRIVATE_PERMISSIONS

		return player:_handleCampSetLinePermission(permissions)
	end

	function TestManager.priv_set_perm_cmd(permissions, lineUid, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		permissions = permissions or HomeCampConst.DEFAULT_PRIVATE_PERMISSIONS
		lineUid = lineUid or player.curCampLineUid

		if not lineUid or lineUid <= 0 then
			return "lineUid required"
		end

		areaId = areaId or HomeCampLineUid.getAreaId(lineUid)
		bucketId = bucketId or HomeCampLineUid.getBucketId(lineUid)

		local tenantKey = getTenantKey()

		return callLineService("CMD_SetLinePermission", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			lineUid,
			permissions
		}, "priv_set_perm")
	end

	function TestManager.create_invite(inviteeUid, lineUid, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		if not inviteeUid then
			return "inviteeUid required"
		end

		lineUid = lineUid or player.curCampLineUid

		if not lineUid or lineUid <= 0 then
			return "lineUid required"
		end

		areaId = areaId or HomeCampLineUid.getAreaId(lineUid)
		bucketId = bucketId or HomeCampLineUid.getBucketId(lineUid)

		local tenantKey = getTenantKey()

		return callLineService("CMD_CreateInvite", {
			tenantKey,
			areaId,
			bucketId,
			lineUid,
			player.uid,
			inviteeUid
		}, "create_invite")
	end

	function TestManager.invite(targetUid)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		if not targetUid then
			return "targetUid required"
		end

		return player:_handleCampInviteFriend(targetUid)
	end

	function TestManager.accept_invite(inviteId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		if not inviteId then
			return "inviteId required"
		end

		return player:_handleCampAcceptInvite(inviteId)
	end

	function TestManager.priv_info(lineUid, areaId, bucketId)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		lineUid = lineUid or player.curCampLineUid

		if not lineUid or lineUid <= 0 then
			return "not in a camp line"
		end

		areaId = areaId or HomeCampLineUid.getAreaId(lineUid)
		bucketId = bucketId or HomeCampLineUid.getBucketId(lineUid)

		local tenantKey = getTenantKey()
		local hint = HomeCampTenantUtils.getBucketKey(tenantKey, areaId, bucketId)

		specEnt:callService("HomeCampLineService", "CMD_GetBucketSnapshot", {
			tenantKey,
			areaId,
			bucketId
		}, function(result, response)
			local status, resp = logCallback("priv_info", result, response)

			if status == "OK" and resp.lineSummaries then
				for _, summary in ipairs(resp.lineSummaries) do
					if summary.lineUid == lineUid then
						specEnt.logger:debug("[%s] priv_info lineUid=%s isPrivate=%s ownerUid=%s loginCount=%d", LOG_TAG, tostring(lineUid), tostring(summary.isPrivate), tostring(summary.ownerUid), summary.loginCount or 0)

						return
					end
				end

				specEnt.logger:debug("[%s] priv_info lineUid=%s NOT FOUND in bucket snapshot", LOG_TAG, tostring(lineUid))
			end
		end, {
			hint = hint
		})

		return "check log: " .. LOG_TAG
	end

	function TestManager.priv_full_test()
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		local staticId = defaultCampStaticId
		local areaId = HomeCampTenantUtils.getAreaIdFromStaticId(staticId) or defaultAreaId
		local bucketId = player.curCampBucketId or defaultBucketId
		local tenantKey = getTenantKey()
		local hint = HomeCampTenantUtils.getBucketKey(tenantKey, areaId, bucketId)
		local forceClusterId = HomeCampTenantUtils.getForceClusterId(getClusterId())

		specEnt.logger:debug("[%s] priv_full_test START", LOG_TAG)
		specEnt:callService("HomeCampLineService", "CMD_CreatePrivateLine", {
			tenantKey,
			areaId,
			bucketId,
			player.uid,
			staticId,
			player.homeBasicInfo and player.homeBasicInfo:getRawTable() or {},
			forceClusterId
		}, function(r1, resp1)
			local s1 = logCallback("priv_full_test[1_create]", r1, resp1)

			if s1 ~= "OK" or not resp1.lineUid then
				specEnt.logger:debug("[%s] priv_full_test ABORTED at create", LOG_TAG)

				return
			end

			local lineUid = resp1.lineUid

			specEnt:callService("HomeCampLineService", "CMD_SetLinePermission", {
				tenantKey,
				areaId,
				bucketId,
				player.uid,
				lineUid,
				7
			}, function(r2, resp2)
				logCallback("priv_full_test[2_set_perm]", r2, resp2)
				specEnt:callService("HomeCampLineService", "CMD_CreateInvite", {
					tenantKey,
					areaId,
					bucketId,
					lineUid,
					player.uid,
					player.uid
				}, function(r3, resp3)
					logCallback("priv_full_test[3_create_invite]", r3, resp3)
					specEnt:callService("HomeCampLineService", "CMD_DissolvePrivateLine", {
						tenantKey,
						areaId,
						bucketId,
						player.uid,
						lineUid
					}, function(r4, resp4)
						logCallback("priv_full_test[4_dissolve]", r4, resp4)
						specEnt.logger:debug("[%s] priv_full_test DONE", LOG_TAG)
					end, {
						hint = hint
					})
				end, {
					hint = hint
				})
			end, {
				hint = hint
			})
		end, {
			hint = hint
		})

		return "priv_full_test started, check log: " .. LOG_TAG
	end

	local _persistRaceCtx = {}

	local function _persistRaceLog(fmt, ...)
		specEnt.logger:info("[PersistentRaceTest] " .. fmt, ...)
	end

	local function _persistRaceCurCar()
		return HomeLandUtils.getCampCarEntity(player.uid)
	end

	local function _persistRaceCarSummary(car)
		if not car then
			return nil
		end

		return {
			id = car.id,
			actorId = car.actorId,
			ownerUid = car.ownerUid,
			spaceKey = car.space and car.space.spaceKey,
			lineId = car.space and car.space.lineId,
			staticId = car.space and car.space.staticId,
			carIndex = car.carIndex,
			dbterm = car.dbterm,
			dbversion = car.dbversion,
			likeCnt = car.likeCnt,
			marker = car._persistRaceMarker,
			isDestroyWaiting = car.isDestroyWaiting,
			isStartPersistent = car.isStartPersistent,
			lastSaveTs = car.lastSaveTs
		}
	end

	function TestManager.help_persist_race()
		local res = {
			"--- R0/R1 persistent-race observation (CampCar) ---",
			"tm.persist_race_status()                                -- show ctx + cur CampCar summary",
			"tm.persist_race_reset()                                  -- clear ctx + any residual delay hooks",
			"tm.force_unlock_camp(83980508)                          -- setup: GM force migrate CampCar to start camp",
			"tm.persist_race_dirty_car({marker, likeDelta})          -- write marker + likeCnt delta on cur CampCar (likeDelta default 1)",
			"tm.persist_race_switch_camp({targetStaticId, delayOldLogoutMs, delayOldSaveMs, forceNewLine}) -- cross-camp switch (inject old logout/save delays)",
			"tm.persist_race_switch_line({targetLineUid, delayOldLogoutMs, delayOldSaveMs, forceNewLine})  -- same-camp line switch (inject delays)",
			"tm.persist_race_dump_car()                               -- dump cur CampCar summary (no big objects)",
			"tm.persist_race_assert({marker})                          -- compare marker vs start; report pass/reason",
			"",
			"Logs:",
			"  Server R0: rg [CampCarPersistRace] <log_dir>        (slice by phase=)",
			"  Server R1: rg [PersistentCreateGate] <log_dir>      (barrier acquire/prepare/release/commit)",
			"  Server R1: rg PersistentCreateGateForceGrant <log>  (ALARM: 2x prepare timeout fallback)",
			"  Server R1: rg CampCarTermMismatch <log>             (ALARM: barrier failure -> data loss)",
			"  Test     : rg [PersistentRaceTest] <log_dir>        (slice by marker/case)",
			"",
			"Cross-game reproduction requires two Game processes: <clusterId>-game0 and <clusterId>-game1",
			"Enable ServerSwitch.DebugHomeCampSpaceParityGame=true in debug mode",
			"Start staticId=83980508(sceneId 3000100 -> game0), target staticId=84748009(sceneId 3000101 -> game1)",
			"Do NOT use tm.gotocamp for setup; it only teleports and does not migrate CampCar",
			"Single-game run only validates hooks and create queue guard; see homecamp pressure guide Sect.10",
			"",
			"R1 acceptance (post-barrier):",
			"  T2 with delayOldSaveMs=3000 MUST NOT produce race=TERM_MISMATCH",
			"  Expected order: old release_ack -> Gate grant -> new create_request -> create_commit",
			"  Expected log: [PersistentCreateGate] phase=acquire_grant|release_request|release_ack|create_commit_notify"
		}

		return lume.tonumstrkey(res, 3)
	end

	function TestManager.persist_race_status()
		return {
			ctx = lume.clone(_persistRaceCtx),
			curCar = _persistRaceCarSummary(_persistRaceCurCar()),
			curSpace = player.space and {
				spaceKey = player.space.spaceKey,
				staticId = player.space.staticId,
				lineId = player.space.lineId,
				_persistRaceTestLogoutDelayMs = player.space._persistRaceTestLogoutDelayMs
			} or nil,
			arch = TestManager.arch()
		}
	end

	function TestManager.persist_race_reset()
		_persistRaceCtx = {}

		local car = _persistRaceCurCar()

		if car then
			car._persistRaceTestSaveDelayMs = nil
			car._persistRaceMarker = nil
		end

		if player.space then
			player.space._persistRaceTestLogoutDelayMs = nil
		end

		_persistRaceLog("reset done")

		return "persist_race state cleared"
	end

	function TestManager.persist_race_dirty_car(opts)
		opts = opts or {}

		local marker = opts.marker or string.format("M%d", Time.secondCache)
		local likeDelta = opts.likeDelta or 1
		local car = _persistRaceCurCar()

		if not car then
			return "no CampCar entity for " .. tostring(player.uid)
		end

		local before = _persistRaceCarSummary(car)

		car._persistRaceMarker = marker
		car.likeCnt = (car.likeCnt or 0) + likeDelta
		_persistRaceCtx.marker = marker
		_persistRaceCtx.likeCntBefore = car.likeCnt
		_persistRaceCtx.oldSpaceKey = before.spaceKey
		_persistRaceCtx.oldLineUid = before.lineId
		_persistRaceCtx.oldDbterm = before.dbterm
		_persistRaceCtx.oldDbversion = before.dbversion
		_persistRaceCtx.startTs = Time.secondCache

		_persistRaceLog("dirty_car marker=%s likeCnt=%d->%d dbterm=%s dbversion=%s spaceKey=%s lineId=%s", marker, before.likeCnt or 0, car.likeCnt or 0, tostring(before.dbterm), tostring(before.dbversion), tostring(before.spaceKey), tostring(before.lineId))

		return _persistRaceCarSummary(car)
	end

	local function _persistRaceInjectDelays(opts)
		local oldSpace = player.space
		local oldCar = _persistRaceCurCar()
		local logoutMs = tonumber(opts.delayOldLogoutMs) or 0
		local saveMs = tonumber(opts.delayOldSaveMs) or 0

		if oldSpace and logoutMs > 0 then
			oldSpace._persistRaceTestLogoutDelayMs = logoutMs
		end

		if oldCar and saveMs > 0 then
			oldCar._persistRaceTestSaveDelayMs = saveMs
		end

		_persistRaceLog("inject_delay logoutMs=%d saveMs=%d oldSpaceKey=%s oldCarId=%s", logoutMs, saveMs, tostring(oldSpace and oldSpace.spaceKey), tostring(oldCar and oldCar.id))
	end

	function TestManager.persist_race_switch_camp(opts)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		opts = opts or {}

		local targetStaticId = opts.targetStaticId or 84748009

		_persistRaceInjectDelays(opts)
		_persistRaceLog("switch_camp marker=%s targetStaticId=%s forceNewLine=%s", tostring(_persistRaceCtx.marker), tostring(targetStaticId), tostring(opts.forceNewLine))

		return player:_handleCampChangeCamp(targetStaticId, 0)
	end

	function TestManager.persist_race_switch_line(opts)
		if not isNewArch() then
			return "switch UseNewHomeCampArch first"
		end

		opts = opts or {}

		local targetLineUid = opts.targetLineUid or 0

		_persistRaceInjectDelays(opts)

		local staticId = player.curCampStaticId or defaultCampStaticId

		_persistRaceLog("switch_line marker=%s targetLineUid=%s forceNewLine=%s staticId=%s", tostring(_persistRaceCtx.marker), tostring(targetLineUid), tostring(opts.forceNewLine), tostring(staticId))

		return player:_handleCampChangeCamp(staticId, targetLineUid)
	end

	function TestManager.persist_race_dump_car()
		return {
			ctx = lume.clone(_persistRaceCtx),
			curCar = _persistRaceCarSummary(_persistRaceCurCar())
		}
	end

	function TestManager.persist_race_assert(opts)
		opts = opts or {}

		local expectMarker = opts.marker or _persistRaceCtx.marker
		local car = _persistRaceCurCar()
		local result = {
			expectMarker = expectMarker,
			ctx = lume.clone(_persistRaceCtx),
			curCar = _persistRaceCarSummary(car)
		}

		if not car then
			result.pass = false
			result.reason = "no CampCar entity on this game (switch in progress, failed, or command is running on old game after cross-game switch)"
		elseif car._persistRaceMarker == expectMarker then
			result.pass = true
			result.reason = "marker preserved on current CampCar memory"
		else
			result.pass = false
			result.reason = string.format("marker mismatch: expect=%s actual=%s (marker is memory-only; check destroy_save_ack race/matched and persisted fields)", tostring(expectMarker), tostring(car._persistRaceMarker))
		end

		_persistRaceLog("assert marker=%s pass=%s reason=%s", tostring(expectMarker), tostring(result.pass), tostring(result.reason))

		return result
	end

	function TestManager.help()
		local res = {
			"--- Info & Monitor ---",
			"tm.arch()                             -- current architecture info",
			"tm.get_data(clusterId)                -- player camp data overview",
			"tm.dump_lines(areaId)                 -- line distribution summary (all bucket stat)",
			"tm.dump_snapshot(areaId, bucketId)     -- bucket snapshot (new arch)",
			"tm.dump_directory(staticId, count)     -- directory recommend list dump (new arch)",
			"tm.dump_dir_page(areaId, offset, limit)-- directory paged query (new arch)",
			"",
			"--- Old arch HomeCampService ---",
			"tm.old_login(staticId, forceNewLine)   -- login camp",
			"tm.old_enter(staticId, forceNewLine)   -- enter camp (visitor)",
			"tm.old_change(staticId, lineId)        -- move",
			"tm.old_logout()                        -- logout",
			"tm.old_recommend(n, staticId)           -- recommend list",
			"tm.old_get_by_ids(ids)                 -- batch query",
			"tm.old_heartbeat()                     -- heartbeat",
			"tm.old_sync_info()                     -- sync base info",
			"tm.old_hb_timeout(timeout)             -- set heartbeat timeout",
			"tm.old_hb_config()                     -- get heartbeat config",
			"",
			"--- New arch HomeCampLineService ---",
			"tm.new_login(staticId, areaId, bucketId, specLineUid) -- login line",
			"tm.new_enter(staticId, areaId, bucketId, specLineUid)     -- enter line",
			"tm.new_leave(areaId, bucketId)         -- leave line",
			"tm.new_change(staticId, targetLineUid)  -- change line",
			"tm.new_switch(targetStaticId, targetLineUid, preferredBucketId) -- cross-camp switch",
			"tm.new_logout(areaId, bucketId)        -- logout",
			"tm.new_create(staticId, areaId, bucketId) -- create line",
			"tm.new_destroy(lineUid)                -- destroy line",
			"tm.new_heartbeat(areaId, bucketId)     -- heartbeat",
			"tm.new_sync_info(areaId, bucketId)     -- sync base info",
			"tm.new_bucket_stat(areaId, bucketId)   -- bucket stat",
			"",
			"--- New arch HomeCampDirectoryService ---",
			"tm.dir_recommend(staticId, count)       -- recommend list",
			"tm.dir_find_code(displayCode)           -- find by display code",
			"tm.dir_get_by_ids(lineUids)             -- batch query lines",
			"tm.dir_get_by_keys(spaceKeys)           -- query by spaceKey",
			"tm.dir_query(areaId, offset, limit)     -- paged query",
			"tm.dir_route(lineUid)                   -- query line route",
			"tm.dir_select_bucket(areaId)            -- select bucket",
			"",
			"--- Player component API ---",
			"tm.relogin()                           -- relogin",
			"tm.gotocamp(staticId)                  -- teleport only; does NOT migrate CampCar",
			"tm.force_unlock_camp(staticId)          -- GM force unlock/migrate CampCar to camp",
			"tm.unlock(staticId)                    -- unlock camp",
			"tm.change(staticId, lineId)            -- move (component)",
			"tm.enter_self()                        -- enter own camp",
			"tm.enter_other(spaceKey, uid)          -- enter other's camp",
			"tm.rfhCar()                            -- refresh campcar entity",
			"tm.rfhPet()                            -- refresh pets",
			"",
			"--- Stress test ---",
			"tm.stress_login(count, staticId, interval) -- batch login",
			"tm.stress_recommend(count, staticId)   -- batch recommend query",
			"tm.stress_heartbeat(count)             -- batch heartbeat",
			"tm.stress_lifecycle(count, staticId)   -- login+logout cycle",
			"tm.stress_create_destroy(count, staticId) -- create+destroy line (new arch)",
			"tm.stress_mixed(login, hb, rec)        -- mixed stress",
			"",
			"--- Private line & invite ---",
			"tm.priv_create()                       -- create private line (component)",
			"tm.priv_create_cmd(staticId, areaId, bucketId) -- create private line (CMD)",
			"tm.priv_dissolve()                     -- dissolve private line (component)",
			"tm.priv_dissolve_cmd(lineUid)          -- dissolve private line (CMD)",
			"tm.priv_set_perm(permissions)           -- set permissions (1=invite,2=decorate,4=random)",
			"tm.priv_set_perm_cmd(permissions, lineUid) -- set permissions (CMD)",
			"tm.create_invite(inviteeUid, lineUid)  -- create invite ticket (CMD)",
			"tm.priv_info(lineUid)                  -- view private line info",
			"tm.priv_full_test()                    -- full flow: create -> perm -> invite -> dissolve",
			"tm.invite(targetUid)                   -- invite friend (component)",
			"tm.accept_invite(inviteId)             -- accept invite (component)",
			"",
			"--- R0 persistent-race observation (CampCar) ---",
			"tm.help_persist_race()                  -- detailed persist_race help & usage"
		}

		return lume.tonumstrkey(res, 3)
	end
end

if TEST_FISHING_CAPTURE then
	local player = dm.player(1)

	function TestManager.get_data()
		local spaceInfo

		if player.space and player.space.gamePhase then
			local space = player.space
			local phaseNames = {
				"READY",
				"BATTLE",
				"TRANSITION",
				"CAPTURE",
				"SETTLE"
			}

			spaceInfo = {
				repr = space:repr(),
				gamePhase = (phaseNames[space.gamePhase] or "") .. string.format("(%d)", space.gamePhase),
				status = (DungeonConst.STATUS_HANDLER[space.status] or "") .. string.format("(%d)", space.status),
				phaseEndTs = space.phaseEndTs,
				stateRemainTime = space:getStateRemainTime(),
				bossEntityId = space.bossEntityId or 0
			}
		end

		return {
			fishingCaptureCurPhase = player.fishingCaptureCurPhase,
			fishingCaptureInfo = player.fishingCaptureInfo and player.fishingCaptureInfo:getRawTable() or "nil",
			settleHistoryCount = player.fishingCaptureSettleHistory and #player.fishingCaptureSettleHistory or 0,
			spaceInfo = spaceInfo
		}
	end

	function TestManager.op(op, params)
		return player:RPC_CS_FishingCaptureOp(op, params)
	end

	function TestManager.enter()
		return TestManager.op(OpDef.OP.CS_FC_Enter, {})
	end

	function TestManager.quit()
		return TestManager.op(OpDef.OP.CS_FC_Quit, {})
	end

	function TestManager.time_stop()
		player.space:pauseGameByType(Const.GameTimeScaleType.TEST, -1)
	end

	function TestManager.time_start()
		player.space:resumeGameByType(Const.GameTimeScaleType.TEST)
	end

	function TestManager.get_history(count)
		local history = player.fishingCaptureSettleHistory

		if not history then
			return "settleHistory is nil"
		end

		local total = #history
		local startIdx = count and math.max(1, total - count + 1) or 1
		local res = {
			total = total
		}

		for i = startIdx, total do
			local record = history[i]

			if record then
				res[#res + 1] = {
					index = i,
					settleTime = TimeUtils.timeStampToUtcString(record.settleTime),
					phaseId = record.phaseId,
					ballUsedMap = record.ballUsedMap and record.ballUsedMap:getRawTable() or {},
					petTemplateId = record.petTemplateId,
					rewards = record.rewards and record.rewards:getRawTable() or {},
					isByLevelRandom = record.isByLevelRandom
				}
			end
		end

		return res
	end

	function TestManager.clear_history()
		player.fishingCaptureSettleHistory = {}

		return {
			cleared = true,
			count = #player.fishingCaptureSettleHistory
		}
	end

	function TestManager.mock_history(count, daysAgo)
		count = count or 5
		daysAgo = daysAgo or 0

		local history = player.fishingCaptureSettleHistory
		local baseTime = Time.secondCache - daysAgo * 86400

		for i = 1, count do
			history:insert(#history + 1, {
				settleTime = baseTime - (count - i) * 60,
				phaseId = player.fishingCaptureCurPhase or 1,
				ballUsedMap = {
					[110003] = math.random(3, 15)
				},
				petTemplateId = i % 3 == 0 and math.random(10001, 99999) or 0,
				rewards = {
					[990001] = math.random(1, 5)
				},
				isByLevelRandom = i % 5 == 0
			})
		end

		return {
			added = count,
			total = #history
		}
	end
end

if TEST_USER_DATA then
	local specEnt = require("Globals").specificEntity
	local uid = "47777"
	local LOG_TAG = "test_user_data"

	function TestManager.get_stable(key)
		specEnt:callService("UserDataService", "getAttribute", {
			uid,
			{
				"stableAttributesStr"
			}
		}, function(result, response)
			local attrstr = result.status and response.AttributesMap and response.AttributesMap.stableAttributesStr or ""
			local dict = Utils.decodeFromStr(attrstr) or {}
			local value = dict[key]

			specEnt.logger:debug("%s get_stable, key=%s, value=%s, dict=%s", LOG_TAG, inspect(key), inspect(value, {
				depth = 10
			}), inspect(dict, {
				depth = 1
			}))
		end, {
			callerId = uid
		})

		return "check log: " .. LOG_TAG
	end

	function TestManager.get_data(key)
		specEnt:callService("UserDataService", "getAttribute", {
			uid,
			{
				key
			}
		}, function(result, response)
			specEnt.logger:debug("%s get_data result=%s, response=%s", LOG_TAG, inspect(result), inspect(response, {
				depth = 10
			}))
		end, {
			callerId = uid
		})

		return "check log: " .. LOG_TAG
	end

	function TestManager.set_data(key, value)
		specEnt:callService("UserDataService", "syncAttribute", {
			uid,
			{
				[key] = value
			}
		}, function(result, response)
			specEnt.logger:debug("%s set_data result=%s, response=%s", LOG_TAG, inspect(result), inspect(response))
		end, {
			callerId = uid
		})

		return "check log: " .. LOG_TAG
	end
end

local TEST_REDIS = dm.isTesting("redis")

if TEST_REDIS then
	local redis = require("Core.Server.DBManager.DBManagerRedis")
	local Time = require("Core.Common.Time")
	local LoggerManager = require("Core.Log.LoggerManager")
	local redisLogger = LoggerManager.getLogger("TestRedis")
	local TEST_PREFIX = "test:redis:"

	local function logResult(tag, status, value, err)
		if status then
			redisLogger:info("[REDIS_TEST] %s OK: %s", tag, tostring(value))
		else
			redisLogger:error("[REDIS_TEST] %s FAIL: %s", tag, tostring(err))
		end
	end

	local function logResultTable(tag, status, value, err)
		if status then
			if type(value) == "table" then
				redisLogger:info("[REDIS_TEST] %s OK: %s", tag, table.concat(value, ", "))
			else
				redisLogger:info("[REDIS_TEST] %s OK: %s", tag, tostring(value))
			end
		else
			redisLogger:error("[REDIS_TEST] %s FAIL: %s", tag, tostring(err))
		end
	end

	function TestManager.redis_ping()
		local key = TEST_PREFIX .. "ping"

		redis:set(key, "pong", function(s, v)
			logResult("SET ping", s, v)
			redis:get(key, function(s2, v2)
				logResult("GET ping (expect pong)", s2, v2)
				redis:del(key, function(s3, v3)
					logResult("DEL ping", s3, v3)
				end)
			end)
		end)

		return "redis_ping: check log [TestRedis]"
	end

	function TestManager.redis_test_string()
		local key = TEST_PREFIX .. "str"
		local numKey = TEST_PREFIX .. "num"

		redis:set(key, "hello_world", function(s, v)
			logResult("SET str", s, v)
			redis:get(key, function(s, v)
				logResult("GET str (expect hello_world)", s, v)
				redis:set(numKey, "10", function(s, v)
					logResult("SET num=10", s, v)
					redis:incr(numKey, function(s, v)
						logResult("INCR num (expect 11)", s, v)
						redis:decr(numKey, function(s, v)
							logResult("DECR num (expect 10)", s, v)
							redis:del(key, function(s, v)
								logResult("DEL str", s, v)
							end)
							redis:del(numKey, function(s, v)
								logResult("DEL num", s, v)
							end)
						end)
					end)
				end)
			end)
		end)

		return "redis_test_string: check log [TestRedis]"
	end

	function TestManager.redis_test_hash()
		local key = TEST_PREFIX .. "hash"

		redis:hset(key, "name", "worldx", function(s, v)
			logResult("HSET name", s, v)
			redis:hset(key, "version", "1", function(s, v)
				logResult("HSET version", s, v)
				redis:hget(key, "name", function(s, v)
					logResult("HGET name (expect worldx)", s, v)
					redis:hmget(key, "name", "version", function(s, v)
						logResultTable("HMGET name,version", s, v)
						redis:hexists(key, "name", function(s, v)
							logResult("HEXISTS name (expect 1)", s, v)
							redis:hdel(key, "name", function(s, v)
								logResult("HDEL name", s, v)
								redis:hexists(key, "name", function(s, v)
									logResult("HEXISTS name after del (expect 0)", s, v)
									redis:del(key, function(s, v)
										logResult("DEL hash", s, v)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)

		return "redis_test_hash: check log [TestRedis]"
	end

	function TestManager.redis_test_list()
		local key = TEST_PREFIX .. "list"

		redis:lpush(key, "c", "b", "a", function(s, v)
			logResult("LPUSH a,b,c", s, v)
			redis:llen(key, function(s, v)
				logResult("LLEN (expect 3)", s, v)
				redis:lindex(key, 0, function(s, v)
					logResult("LINDEX 0 (expect a)", s, v)
					redis:lrange(key, 0, -1, function(s, v)
						logResultTable("LRANGE 0,-1", s, v)
						redis:lpop(key, function(s, v)
							logResult("LPOP (expect a)", s, v)
							redis:del(key, function(s, v)
								logResult("DEL list", s, v)
							end)
						end)
					end)
				end)
			end)
		end)

		return "redis_test_list: check log [TestRedis]"
	end

	function TestManager.redis_test_set()
		local key = TEST_PREFIX .. "set"

		redis:sadd(key, "alpha", function(s, v)
			logResult("SADD alpha", s, v)
			redis:sadd(key, "beta", function(s, v)
				logResult("SADD beta", s, v)
				redis:sismember(key, "alpha", function(s, v)
					logResult("SISMEMBER alpha (expect 1)", s, v)
					redis:smembers(key, function(s, v)
						logResultTable("SMEMBERS", s, v)
						redis:srem(key, "alpha", function(s, v)
							logResult("SREM alpha", s, v)
							redis:del(key, function(s, v)
								logResult("DEL set", s, v)
							end)
						end)
					end)
				end)
			end)
		end)

		return "redis_test_set: check log [TestRedis]"
	end

	function TestManager.redis_test_zset()
		local key = TEST_PREFIX .. "zset"

		redis:zadd(key, 100, "player_a", function(s, v)
			logResult("ZADD player_a=100", s, v)
			redis:zadd(key, 200, "player_b", function(s, v)
				logResult("ZADD player_b=200", s, v)
				redis:zadd(key, 150, "player_c", function(s, v)
					logResult("ZADD player_c=150", s, v)
					redis:zrank(key, "player_a", function(s, v)
						logResult("ZRANK player_a (expect 0)", s, v)
						redis:zrange(key, 0, -1, function(s, v)
							logResultTable("ZRANGE 0,-1 (expect a,c,b)", s, v)
							redis:zincrby(key, 200, "player_a", function(s, v)
								logResult("ZINCRBY player_a+200 (expect 300)", s, v)
								redis:zrem(key, "player_b", function(s, v)
									logResult("ZREM player_b", s, v)
									redis:del(key, function(s, v)
										logResult("DEL zset", s, v)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)

		return "redis_test_zset: check log [TestRedis]"
	end

	function TestManager.redis_test_pipeline()
		redis:init_pipeline()
		redis:set(TEST_PREFIX .. "p1", "val1")
		redis:set(TEST_PREFIX .. "p2", "val2")
		redis:get(TEST_PREFIX .. "p1")
		redis:get(TEST_PREFIX .. "p2")
		redis:del(TEST_PREFIX .. "p1")
		redis:del(TEST_PREFIX .. "p2")
		redis:commit_pipeline(function(s, v, errs)
			if s then
				redisLogger:info("[REDIS_TEST] PIPELINE OK: set1=%s set2=%s get1=%s get2=%s del1=%s del2=%s", tostring(v[1]), tostring(v[2]), tostring(v[3]), tostring(v[4]), tostring(v[5]), tostring(v[6]))
			else
				redisLogger:error("[REDIS_TEST] PIPELINE FAIL: %s", tostring(errs))
			end
		end)

		return "redis_test_pipeline: check log [TestRedis]"
	end

	function TestManager.redis_test_expire()
		local key = TEST_PREFIX .. "expire"

		redis:set(key, "temp_data", function(s, v)
			logResult("SET expire_key", s, v)
			redis:expire(key, 5, function(s, v)
				logResult("EXPIRE 5s (expect 1)", s, v)
				redis:doCommand(redis, "ttl", key, function(s, v)
					logResult("TTL (expect <=5)", s, v)
				end)
			end)
		end)

		return "redis_test_expire: check log [TestRedis], key auto-expires in 5s"
	end

	function TestManager.redis_test_eval()
		local key = TEST_PREFIX .. "eval"

		redis:eval("return redis.call('set', KEYS[1], ARGV[1])", 1, key, "eval_value", function(s, v)
			logResult("EVAL set", s, v)
			redis:get(key, function(s, v)
				logResult("GET after eval (expect eval_value)", s, v)
				redis:del(key, function(s, v)
					logResult("DEL eval", s, v)
				end)
			end)
		end)

		return "redis_test_eval: check log [TestRedis]"
	end

	function TestManager.redis_test_all()
		TestManager.redis_ping()
		TestManager.redis_test_string()
		TestManager.redis_test_hash()
		TestManager.redis_test_list()
		TestManager.redis_test_set()
		TestManager.redis_test_zset()
		TestManager.redis_test_pipeline()
		TestManager.redis_test_expire()
		TestManager.redis_test_eval()

		return "redis_test_all: all tests dispatched, check log [TestRedis]"
	end

	function TestManager.redis_bench(n, cmd)
		n = n or 1000
		cmd = cmd or "set"

		local completed = 0
		local errors = 0
		local startTime = Time.getMillisecond()

		local function onDone()
			completed = completed + 1

			if completed + errors >= n then
				local elapsed = Time.getMillisecond() - startTime
				local opsPerSec = elapsed > 0 and n / (elapsed / 1000) or 0

				redisLogger:info("[REDIS_BENCH] cmd=%s n=%d elapsed=%dms ops/sec=%.1f errors=%d", cmd, n, elapsed, opsPerSec, errors)
			end
		end

		local function cb(status, value, err)
			if status then
				onDone()
			else
				errors = errors + 1

				onDone()
			end
		end

		local prefix = TEST_PREFIX .. "bench:"

		if cmd == "set" then
			for i = 1, n do
				redis:set(prefix .. i, "v_" .. i, cb)
			end
		elseif cmd == "get" then
			for i = 1, n do
				redis:get(prefix .. i, cb)
			end
		elseif cmd == "hset" then
			for i = 1, n do
				redis:hset(prefix .. "hash", "f_" .. i, "v_" .. i, cb)
			end
		elseif cmd == "hget" then
			for i = 1, n do
				redis:hget(prefix .. "hash", "f_" .. i, cb)
			end
		elseif cmd == "incr" then
			for i = 1, n do
				redis:incr(prefix .. "counter", cb)
			end
		else
			return "unknown cmd: " .. cmd .. ", supported: set/get/hset/hget/incr"
		end

		return string.format("redis_bench: dispatched %d [%s] commands, check log [TestRedis]", n, cmd)
	end

	function TestManager.redis_bench_pipeline(n, batchSize)
		n = n or 1000
		batchSize = batchSize or 100

		local batches = math.ceil(n / batchSize)
		local completedBatches = 0
		local errorBatches = 0
		local startTime = Time.getMillisecond()
		local prefix = TEST_PREFIX .. "pbench:"

		for b = 1, batches do
			redis:init_pipeline()

			local startIdx = (b - 1) * batchSize + 1
			local endIdx = math.min(b * batchSize, n)

			for i = startIdx, endIdx do
				redis:set(prefix .. i, "v_" .. i)
			end

			redis:commit_pipeline(function(status, value, errs)
				if status then
					completedBatches = completedBatches + 1
				else
					errorBatches = errorBatches + 1
				end

				if completedBatches + errorBatches >= batches then
					local elapsed = Time.getMillisecond() - startTime
					local opsPerSec = elapsed > 0 and n / (elapsed / 1000) or 0

					redisLogger:info("[REDIS_BENCH_PIPELINE] n=%d batchSize=%d batches=%d elapsed=%dms ops/sec=%.1f errors=%d", n, batchSize, batches, elapsed, opsPerSec, errorBatches)
				end
			end)
		end

		return string.format("redis_bench_pipeline: %d ops in %d batches (size=%d), check log [TestRedis]", n, batches, batchSize)
	end

	function TestManager.redis_bench_mixed(n)
		n = n or 1000

		local half = math.floor(n / 2)
		local completed = 0
		local errors = 0
		local startTime = Time.getMillisecond()

		local function onDone()
			completed = completed + 1

			if completed + errors >= n then
				local elapsed = Time.getMillisecond() - startTime
				local opsPerSec = elapsed > 0 and n / (elapsed / 1000) or 0

				redisLogger:info("[REDIS_BENCH_MIXED] n=%d (set=%d get=%d) elapsed=%dms ops/sec=%.1f errors=%d", n, half, n - half, elapsed, opsPerSec, errors)
			end
		end

		local function cb(status, value, err)
			if status then
				onDone()
			else
				errors = errors + 1

				onDone()
			end
		end

		local prefix = TEST_PREFIX .. "mix:"

		for i = 1, half do
			redis:set(prefix .. i, "v_" .. i, cb)
		end

		for i = 1, n - half do
			redis:get(prefix .. i, cb)
		end

		return string.format("redis_bench_mixed: %d ops (set=%d get=%d), check log [TestRedis]", n, half, n - half)
	end

	function TestManager.redis_cleanup()
		local script = "            local cursor = \"0\"\n            local count = 0\n            repeat\n                local result = redis.call(\"scan\", cursor, \"MATCH\", ARGV[1], \"COUNT\", 100)\n                cursor = result[1]\n                local keys = result[2]\n                if #keys > 0 then\n                    redis.call(\"del\", unpack(keys))\n                    count = count + #keys\n                end\n            until cursor == \"0\"\n            return count\n        "

		redis:eval(script, 0, TEST_PREFIX .. "*", function(s, v)
			if s then
				redisLogger:info("[REDIS_TEST] cleanup done, deleted %s keys", tostring(v))
			else
				redisLogger:error("[REDIS_TEST] cleanup failed: %s", tostring(v))
			end
		end)

		return "redis_cleanup: check log [TestRedis]"
	end

	function TestManager.redis_help()
		return table.concat({
			"=== Redis Test Commands ===",
			"tm.redis_ping()                  -- connectivity test",
			"tm.redis_test_string()           -- string ops test",
			"tm.redis_test_hash()             -- hash ops test",
			"tm.redis_test_list()             -- list ops test",
			"tm.redis_test_set()              -- set ops test",
			"tm.redis_test_zset()             -- sorted set ops test",
			"tm.redis_test_pipeline()         -- pipeline test",
			"tm.redis_test_expire()           -- expire/ttl test",
			"tm.redis_test_eval()             -- lua script test",
			"tm.redis_test_all()              -- run all tests above",
			"tm.redis_bench(n, cmd)           -- bench: n ops, cmd=set/get/hset/hget/incr",
			"tm.redis_bench_pipeline(n, batch)-- bench: n ops in pipeline batches",
			"tm.redis_bench_mixed(n)          -- bench: n mixed set+get ops",
			"tm.redis_cleanup()               -- delete all test:redis:* keys",
			"tm.redis_help()                  -- this help",
			"",
			"Usage: dm.switchTest('redis') then tm = dm.switchTest('redis')"
		}, "\n")
	end
end

if TEST_TIPS_TIMELINE then
	local BaseTipArea = require("Guis.Panels.Tips.BaseTipArea")
	local BaseAreaItem = require("Guis.Panels.Tips.Items.BaseAreaItem")
	local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
	local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")

	function TestManager.run_tips_timeline_deadline_regression()
		local passed, result = xpcall(function()
			local queueItem = {
				runList = {
					{
						timeOut = 100,
						endTime = 99
					},
					{
						timeOut = 99,
						endTime = 100
					},
					{
						timeOut = 102,
						endTime = 101
					}
				}
			}

			function queueItem:onQueuePressureChanged()
				return
			end

			BaseQueueItem.onTimelineResume(queueItem, 5, 100)
			assert(queueItem.runList[1].endTime == 99, "expired endTime must not be extended")
			assert(queueItem.runList[1].timeOut == 100, "deadline at suspension time must not be extended")
			assert(queueItem.runList[2].endTime == 100, "endTime at suspension time must not be extended")
			assert(queueItem.runList[2].timeOut == 99, "expired timeOut must not be extended")
			assert(queueItem.runList[3].endTime == 106, "future endTime must be extended by delta")
			assert(queueItem.runList[3].timeOut == 107, "future timeOut must be extended by delta")

			local legacyQueueItem = {
				runList = {
					{
						timeOut = 101,
						endTime = 100
					}
				}
			}

			function legacyQueueItem:onQueuePressureChanged()
				return
			end

			BaseQueueItem.onTimelineResume(legacyQueueItem, 5)
			assert(legacyQueueItem.runList[1].endTime == 105, "legacy resume without suspendedAt must retain unconditional endTime extension")
			assert(legacyQueueItem.runList[1].timeOut == 106, "legacy resume without suspendedAt must retain unconditional timeOut extension")

			local recycleOwner = {
				owner = {
					recycleController = {
						resumeItem = function()
							return
						end
					}
				}
			}
			local suspendedAt = Time.realSecondCache - 1
			local callbackDelta, callbackSuspendedAt
			local areaItem = {
				__timelineSuspendCount = 1,
				owner = recycleOwner,
				__timelineSuspendAt = suspendedAt
			}

			function areaItem:onTimelineResume(delta, resumeSuspendedAt)
				callbackDelta = delta
				callbackSuspendedAt = resumeSuspendedAt
			end

			BaseAreaItem.resumeTimeline(areaItem)
			assert(callbackDelta > 0, "timeline resume must report a positive delta")
			assert(callbackSuspendedAt == suspendedAt, "timeline resume must forward suspendedAt")

			local isCutsceneHidden = true
			local runState = TipAreaConst.ITEM_RUN_STATE
			local clearRunningListCount = 0
			local finishedCount = 0
			local startCount = 0
			local updateCount = 0
			local queueItemInCutscene = {
				itemKey = "tipsTimelineQueueItem",
				__delayTime = 1,
				fix_state = 0,
				run_state = runState.RUN_QUEUE
			}

			function queueItemInCutscene:checkRunState()
				self.run_state = isCutsceneHidden and runState.WAITING or runState.RUN_QUEUE

				return self.run_state
			end

			function queueItemInCutscene:isAreaHidden()
				return isCutsceneHidden
			end

			function queueItemInCutscene:isTimelineSuspended()
				return isCutsceneHidden
			end

			function queueItemInCutscene:isRunning()
				return self.run_state == runState.RUN_QUEUE or self.run_state == runState.RUN_FIXED
			end

			function queueItemInCutscene:clearRunningList()
				clearRunningListCount = clearRunningListCount + 1
			end

			function queueItemInCutscene:finished()
				finishedCount = finishedCount + 1
			end

			function queueItemInCutscene:start()
				startCount = startCount + 1
			end

			function queueItemInCutscene:update()
				updateCount = updateCount + 1
			end

			local area = {
				__CanRecycle = false,
				preCount = 1,
				visible = true,
				dealtTime = 0,
				maxRunNum = 1,
				isWaitingOpenFullScreen = false,
				tmpFrame = {},
				items = {
					queueItemInCutscene
				},
				lastUpdateTime = Time.realSecondCache,
				curFrame = {},
				preFrame = {
					[queueItemInCutscene.itemKey] = queueItemInCutscene
				}
			}

			function area:onRunStateChanged()
				return
			end

			BaseTipArea.update(area)
			assert(clearRunningListCount == 0, "cutscene-hidden running queue item must not be cleared")
			assert(finishedCount == 1, "cutscene-hidden queue item must leave the current frame")
			assert(queueItemInCutscene.__delayTime == 1, "a suspended timeline must freeze the item's overall delay")

			isCutsceneHidden = false
			area.lastUpdateTime = Time.realSecondCache - 0.25

			BaseTipArea.update(area)
			assert(math.abs(queueItemInCutscene.__delayTime - 0.75) < 1e-06, "the overall delay must resume counting down once the cutscene suspension clears")
			assert(startCount == 0 and updateCount == 0, "an item still serving its overall delay must not be scheduled yet")

			area.visible = false
			area.lastUpdateTime = Time.realSecondCache - 100

			BaseTipArea.update(area)
			assert(queueItemInCutscene.__delayTime == 0.75, "hidden areas must freeze their delays")
			assert(area.lastUpdateTime == Time.realSecondCache, "hidden areas must still refresh their clock")

			area.visible = true
			area.isWaitingOpenFullScreen = true
			area.lastUpdateTime = Time.realSecondCache - 100

			BaseTipArea.update(area)
			assert(queueItemInCutscene.__delayTime == 0.75, "waiting for fullscreen must freeze delays")
			assert(area.lastUpdateTime == Time.realSecondCache, "fullscreen waits must still refresh their clock")

			area.isWaitingOpenFullScreen = false
			area.lastUpdateTime = Time.realSecondCache - 0.75

			BaseTipArea.update(area)
			assert(startCount == 1 and updateCount == 1, "queue item must resume scheduling after the cutscene hides flag clears")

			local expiredDelta
			local expiredItem = {
				__timelineSuspendCount = 1,
				owner = recycleOwner,
				__timelineSuspendAt = Time.realSecondCache - (TipAreaConst.CUTSCENE_MAX_SUSPEND_TIME + 1)
			}

			function expiredItem:onTimelineResume()
				error("an over-long suspension must not extend deadlines")
			end

			function expiredItem:onTimelineSuspendExpired(delta)
				expiredDelta = delta
			end

			BaseAreaItem.resumeTimeline(expiredItem)
			assert(expiredDelta and expiredDelta > TipAreaConst.CUTSCENE_MAX_SUSPEND_TIME, "an over-long suspension must take the expired path instead of resuming")

			local forcedClearCount = 0
			local expiredQueueItem = {}

			function expiredQueueItem:clearAllData(force)
				forcedClearCount = force == true and forcedClearCount + 1 or forcedClearCount
			end

			BaseQueueItem.onTimelineSuspendExpired(expiredQueueItem, 999)
			assert(forcedClearCount == 1, "an expired suspension must force-clear the queue instead of popping stale tips")

			return "tips timeline deadline regression passed"
		end, debug.traceback)

		assert(passed, result)

		return result
	end
end

if TEST_SOUL_EGG_TIPS then
	local SoulEggEvolutionSystem = require("GameApp.Evolution.SoulEggEvolutionSystem")

	function TestManager.run_soul_egg_recorded_tip_release_regression()
		local passed, result = xpcall(function()
			local shownCount = 0
			local system = {
				_isInEggTouchPlaying = true,
				_tipsInfoList = {
					{
						desc = "test recorded tip"
					}
				}
			}

			function system:showRecordTips()
				shownCount = shownCount + 1
				self._tipsInfoList = nil
			end

			SoulEggEvolutionSystem._finishEggTouchPlaying(system)
			assert(system._isInEggTouchPlaying == false, "egg touch completion must clear the playing state")
			assert(shownCount == 0, "recorded tips must not be released before the evolution UI closes")
			assert(SoulEggEvolutionSystem.shouldRecordTipsUntilEvolutionClose(system), "tips received after egg touch completion must still be recorded until the evolution UI closes")
			SoulEggEvolutionSystem._flushRecordedTips(system)
			assert(shownCount == 1, "recorded tips must be released after the evolution UI closes")
			assert(not SoulEggEvolutionSystem.shouldRecordTipsUntilEvolutionClose(system), "tips must stop being recorded after the evolution UI closes")
			SoulEggEvolutionSystem._flushRecordedTips(system)
			assert(shownCount == 1, "recorded tips must only be released once")

			local normalFinishShownCount = 0
			local normalFinishSystem = {
				_isInEggTouchPlaying = true,
				_tipsInfoList = {
					{
						desc = "test normal finish recorded tip"
					}
				}
			}

			function normalFinishSystem:_isRunContextValid()
				return true
			end

			function normalFinishSystem:_finishEggTouchPlaying()
				SoulEggEvolutionSystem._finishEggTouchPlaying(self)
			end

			function normalFinishSystem:playTimer(_, callback)
				callback()
			end

			function normalFinishSystem:_openIncubateResult()
				return
			end

			function normalFinishSystem:playSoulEggEvolution()
				return
			end

			function normalFinishSystem:showRecordTips()
				normalFinishShownCount = normalFinishShownCount + 1
				self._tipsInfoList = nil
			end

			SoulEggEvolutionSystem.onEggTouchFinish(normalFinishSystem, 1, {})
			assert(normalFinishSystem._recordedTipsReadyToShow == true, "normal egg touch completion must mark recorded tips ready before the result UI can close")
			SoulEggEvolutionSystem._flushRecordedTips(normalFinishSystem)
			assert(normalFinishShownCount == 1, "normal egg touch completion must release recorded tips after the result UI closes")

			local interruptedShownCount = 0
			local interruptedSystem = {
				_isInEggTouchPlaying = true,
				_tipsInfoList = {
					{
						desc = "test interrupted recorded tip"
					}
				}
			}

			function interruptedSystem:showRecordTips()
				interruptedShownCount = interruptedShownCount + 1
				self._tipsInfoList = nil
			end

			SoulEggEvolutionSystem._flushRecordedTips(interruptedSystem)
			assert(interruptedShownCount == 1, "recorded tips must survive an interruption before egg touch completion")

			local deferredTips = {
				{
					desc = "test next run recorded tip"
				}
			}
			local deferredFlushCount = 0
			local deferredSystem = {
				_recordedTipsReadyToShow = true,
				_tipsInfoList = deferredTips
			}

			function deferredSystem:_flushRecordedTips()
				deferredFlushCount = deferredFlushCount + 1
				self._tipsInfoList = nil
			end

			SoulEggEvolutionSystem._finalizeRecordedTipsForReset(deferredSystem, true)
			assert(deferredFlushCount == 0, "preparing the next evolution must not flush recorded tips into the new cutscene")
			assert(deferredSystem._tipsInfoList == deferredTips and deferredSystem._recordedTipsReadyToShow == true, "preparing the next evolution must preserve recorded tips")
			SoulEggEvolutionSystem._finalizeRecordedTipsForReset(deferredSystem, false)
			assert(deferredFlushCount == 1, "closing an evolution must flush preserved recorded tips")
			assert(deferredSystem._tipsInfoList == nil and deferredSystem._recordedTipsReadyToShow == false, "flushing recorded tips must clear preserved state")

			local cappedSystem = {}

			for i = 1, 12 do
				SoulEggEvolutionSystem.recordTips(cappedSystem, {
					desc = "capped tip " .. i
				})
			end

			assert(#cappedSystem._tipsInfoList == 10, "recorded tips must be capped so multi-round hatching cannot flood A3")
			assert(cappedSystem._tipsInfoList[1].desc == "capped tip 3", "the oldest recorded tips must be dropped first")
			assert(cappedSystem._tipsInfoList[10].desc == "capped tip 12", "the newest recorded tip must always be kept")

			return "soul egg recorded tip release regression passed"
		end, debug.traceback)

		assert(passed, result)

		return result
	end
end

return TestManager
