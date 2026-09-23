-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils.lua

local PetPrototypeData = require("Data.pet_prototype_data")
local Mathf = require("Common.Math.Mathf")
local PetData = require("Data.pet_data")
local PuppetData = require("Data.puppet_data")
local ExploreAbilityData = require("Data.explore_ability_data")
local AddressDataConst = require("Const.AddressDataConst")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientConst = require("Const.ClientConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local Const = require("Common.Const.Const")
local PlatformUtils = require("Common.Utils.PlatformUtils")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local CombatThreatLevelData = require("Data.combat_threat_level_data")
local HudStateShowShortcutData = require("Data.hud_state_show_shortcut_data")
local HudStateShowShortcutGamepadData = require("Data.hud_state_show_shortcut_gamepad_data")
local PlayerLevelTable = require("Data.player_level_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ItemSourceData = require("Data.item_source_data")
local PlayableConst = require("Common.Const.PlayableConst")
local RedDotConst = require("Const.RedDotConst")
local CommonSwitch = require("Common.CommonSwitch")
local GlobalData = require("Core.Client.GlobalData")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LevelData = require("Data.player_level_data")
local PlayerTitleData = require("Data.player_title_data")
local DescriptionInformationData = require("Data.description_information_data")
local RoguelikeData = require("Data.roguelike_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local NoticeDef = require("Common.NoticeDef")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local ValueDisplayUtils = require("Utils.ValueDisplayUtils")
local UIConst = require("Const.UIConst")
local MapAreaConfigData = require("Data.map_area_config_data")
local LoggerManager = require("Core.Log.LoggerManager")
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local LuaUIUtils = {}
local logger = LoggerManager.getLogger("LuaUIUtils")

require("Utils.LuaUIUtils.UIConstants")(LuaUIUtils)
require("Utils.LuaUIUtils.UIFormatUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UITimeUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIInputUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIItemUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIPetUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UISkillUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIAppearanceUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIFuncMenuUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIHomelandUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIActivityUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIPlayerSparkUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UIPlayerAvatarUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UISceneUtils")(LuaUIUtils)
require("Utils.LuaUIUtils.UICameraUtils")(LuaUIUtils)

local bit = bit
local UIUtils = UIUtils
local IsNil = IsNil

function LuaUIUtils.getCountryIconByType(countryId, iconType)
	local countryCfg = MapAreaConfigData[countryId]

	if countryCfg then
		if iconType == LuaUIUtils.PET_ICON then
			return countryCfg.areaImageSmall
		else
			return countryCfg.areaImageBig
		end
	end
end

function LuaUIUtils.getVisibleStatus(go)
	if IsNil(go) then
		return false
	end

	local localScale = go.transform.localScale

	if LuaUIUtils.checkEqual(localScale.x, 0) and LuaUIUtils.checkEqual(localScale.y, UIConst.MIN_SCALE_VALUE) and LuaUIUtils.checkEqual(localScale.z, 0) then
		return false
	else
		return true
	end
end

function LuaUIUtils.checkEqual(x, y)
	if math.abs(x - y) <= UIConst.EPS then
		return true
	else
		return false
	end
end

function LuaUIUtils.onPlayerCreate()
	local hudId = UIConst.UI_ID_HUD_V2

	if not pg.global.ui:checkUIShow(hudId) then
		pg.global.ui:open(hudId)
	end

	pg.global.ui:open(UIConst.UI_ID_GAMEPAD_MENU_NEW)
	pg.global.ui:open(UIConst.UI_ID_CHAIN_ATTACK)
	pg.global.ui:open(UIConst.UI_ID_DAMAGE_NUMBER)
	pg.global.ui:open(UIConst.UI_ID_TIPS)
	pg.global.ui:open(UIConst.UI_ID_BOTTOM_PET_CHAT)
	pg.global.ui:open(UIConst.UI_ID_QTE)
	pg.global.ui:open(UIConst.UI_ID_PET_EVOLVE)
	pg.global.ui:open(UIConst.UI_ID_HATRED_ARROW_TIP)

	if UIPlatformName == "mobile" then
		pg.global.ui.mobileOperate:open()
	end

	if pg.me.gameVoteOpen == 1 then
		pg.global.ui:open(UIConst.UI_ID_VOTING_FEATURE)
	end

	pg.me:onEnterSpectate()
end

function LuaUIUtils.onPlayerDestroy()
	local hudId = UIConst.UI_ID_HUD_V2

	pg.global.ui:close(hudId)
	pg.global.ui:close(UIConst.UI_ID_GAMEPAD_MENU_NEW)
	pg.global.ui:close(UIConst.UI_ID_INTERACT)
	pg.global.ui:close(UIConst.UI_ID_CHAIN_ATTACK)
	pg.global.ui:close(UIConst.UI_ID_BIG_WHITE_BALL)
	pg.global.ui:close(UIConst.UI_ID_DAMAGE_NUMBER)
	pg.global.ui:close(UIConst.UI_ID_BOTTOM_PET_CHAT)
	pg.global.ui:close(UIConst.UI_ID_QTE)
	pg.global.ui:close(UIConst.UI_ID_PET_EVOLVE)
	pg.global.ui:close(UIConst.UI_ID_HATRED_ARROW_TIP)
	pg.global.ui:close(UIConst.UI_ID_VOTING_FEATURE)
	pg.global.ui:closeAllNormalPanel({
		[UIConst.UI_ID_NPC_DUEL_START] = true
	})
end

function LuaUIUtils.setUIViewVisible(uiView, visible)
	if IsNil(uiView) then
		return
	end

	if uiView.SetActiveFastest then
		uiView:SetActiveFastest(visible)
	else
		UIUtils.ScaleVisible(uiView.gameObject, visible)
	end
end

function LuaUIUtils.setUIVisible(uiItem, visible)
	if IsNil(uiItem) then
		return
	end

	if uiItem.SetActiveFastest then
		uiItem:SetActiveFastest(visible)
	else
		UIUtils.ScaleVisible(uiItem.gameObject, visible)
	end
end

function LuaUIUtils.isUIViewVisible(uiItem)
	if IsNil(uiItem) then
		return false
	end

	return UIUtils.IsVisible(uiItem.gameObject)
end

function LuaUIUtils.playEntPhasePlayableAction(ent, startAction, loopAction, endAction, duration, cb)
	if not ent then
		if cb then
			cb()
		end

		return
	end

	local startTimer, loopTimer, endTimer
	local startClipLength = AnimationUtils.getPlayableClipLength(ent, startAction)
	local loopClipLength = math.max(AnimationUtils.getPlayableClipLength(ent, loopAction), duration or 0)
	local endClipLength = AnimationUtils.getPlayableClipLength(ent, endAction)

	ent:playAnimation(PlayableConst[startAction])

	if not duration and loopAction and not endAction then
		if startClipLength then
			duration = startClipLength
			startTimer = TimerManager.addTimer(duration, function()
				ent:playAnimation(PlayableConst[loopAction])
			end)
		end

		return startTimer, loopTimer, endTimer
	end

	duration = 0

	if startClipLength then
		duration = duration + startClipLength
		startTimer = TimerManager.addTimer(duration, function()
			ent:playAnimation(PlayableConst[loopAction])
		end)
	end

	if loopClipLength then
		duration = duration + loopClipLength
		loopTimer = TimerManager.addTimer(duration, function()
			ent:playAnimation(PlayableConst[endAction])
		end)
	end

	duration = duration + endClipLength or 0
	endTimer = TimerManager.addTimer(duration, function()
		if cb then
			cb()
		end
	end)

	return startTimer, loopTimer, endTimer
end

function LuaUIUtils.getThreatLevelState(targetLevel)
	targetLevel = targetLevel or 0

	for index, levelConfig in ipairs(CombatThreatLevelData) do
		if pg.me.maxPreparedPetLevel and pg.me.maxPreparedPetLevel - targetLevel >= levelConfig.level then
			return levelConfig.color
		elseif index == #CombatThreatLevelData then
			return levelConfig.color
		end
	end
end

function LuaUIUtils.tryOpenBattlePassUnlockPopup(data)
	local oldGear = data and tonumber(data.oldGear) or ActivityConst.BattlePassGear.Free
	local newGear = data and tonumber(data.newGear) or ActivityConst.BattlePassGear.Free

	if newGear <= oldGear then
		return false
	end

	if newGear ~= ActivityConst.BattlePassGear.Pay1 then
		return false
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BP_Get) then
		return false
	end

	pg.global.ui:open(UIConst.UI_ID_BP_Get, {
		gear = newGear
	})

	return true
end

function LuaUIUtils.openInfoPlayerCard(param)
	if not CommonSwitch.PLAYER_CARD then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	local playerId = param.playerId

	if not playerId then
		return
	end

	local prevPlayerInfo = param.playerInfo

	local function queryPlayerInfoCb()
		param.playerInfo = pg.game.chat:getPlayerInfo(tostring(playerId))

		PlatformUtils.fillMissingFlatIdentityFields(param.playerInfo, prevPlayerInfo)
		pg.global.ui:hide(UIConst.UI_ID_HUD_V2)
		pg.global.ui:hide(UIConst.UI_ID_TOPLOGO)
		pg.global.ui:hide(UIConst.UI_ID_INTERACT)
		pg.global.ui:open(UIConst.UI_ID_INFO_PLAYER_CARD, param, nil, function()
			pg.global.ui:show(UIConst.UI_ID_HUD_V2)
			pg.global.ui:show(UIConst.UI_ID_TOPLOGO)
			pg.global.ui:show(UIConst.UI_ID_INTERACT)
		end)
	end

	if not pg.game.chat:getPlayerInfoFromServer(playerId, pg.game.chat.queryPlayerInfoType.ShowPlayerInfo, queryPlayerInfoCb, param.openType, true) then
		queryPlayerInfoCb()
	end
end

function LuaUIUtils.getPlayerDisplayName(playerId, playerName, forceOriginName)
	if not playerId then
		return ""
	end

	local friendCustomInfo = pg.game.chat:getFriendCustomInfo(playerId)

	if forceOriginName or string.isNilOrEmpty(friendCustomInfo.remark) then
		if string.isNilOrEmpty(playerName) then
			local playerInfo = pg.game.chat:getPlayerInfo(playerId)

			playerName = playerInfo and not string.isNilOrEmpty(playerInfo.playerName) and playerInfo.playerName or ""
		end

		return playerName
	else
		return friendCustomInfo.remark
	end
end

function LuaUIUtils.getMeDisplayName()
	if pg.me.playerNameFirstChanged == true then
		return pg.me.playerName
	else
		return pg.getGameString("PLAYER_NO_NAME")
	end
end

function LuaUIUtils.setKeyboard(uWidget, keyWord)
	local hotKeyText = uWidget:Find("panel_key/panel_character/Text"):GetComponent("UBaseText")

	ClientTextUtils.setText(hotKeyText, pg.getLocalizationText(keyWord))
end

function LuaUIUtils.tryTruncateArray(ret, maxCount)
	if type(ret) ~= "table" then
		return
	end

	local isValidMaxCount = type(maxCount) == "number" and maxCount >= 0 and math.floor(maxCount) == maxCount

	if not isValidMaxCount then
		return
	end

	local arrLen = #ret

	if arrLen <= maxCount then
		return
	end

	for i = arrLen, maxCount + 1, -1 do
		ret[i] = nil
	end

	return ret
end

function LuaUIUtils.tableContains(t, element)
	if not t or not element then
		return false, nil
	end

	for k, v in pairs(t) do
		if v == element then
			return true, k
		end
	end

	return false, nil
end

function LuaUIUtils.arrayContains(t, element)
	for k, v in ipairs(t) do
		if v == element then
			return true
		end
	end

	return false
end

function LuaUIUtils.reverseTable(tab)
	local tmp = {}

	for i = 1, #tab do
		local key = #tab + 1 - i

		tmp[i] = tab[key]
	end

	return tmp
end

function LuaUIUtils.refreshShieldUI(data)
	if data.curShield and data.curShield <= 0 then
		data.rootComponent:TryChangePage("Shield", "Normal")
	else
		data.rootComponent:TryChangePage("Shield", "Shield")

		local maxBarValue = data.maxHp

		data.shieldBar1.maxHp = maxBarValue

		if maxBarValue >= data.curShield then
			LuaUIUtils.setUIViewVisible(data.shieldBar2, false)
			data.shieldBar1:ProgressHp(data.curShield or 0)
		elseif data.curShield <= 2 * maxBarValue then
			data.shieldBar1:ProgressHp(maxBarValue)
		else
			data.shieldBar1:ProgressHp(maxBarValue)
		end
	end
end

function LuaUIUtils.isGoBubble(emojiName)
	return UIConst.LET_GO_STATE[emojiName] or false
end

function LuaUIUtils.getDeviceShortcutData()
	if pg.game.input:isUsingGamepad() then
		return HudStateShowShortcutGamepadData
	end

	return HudStateShowShortcutData
end

function LuaUIUtils.getShortcutDataByState(stateKey)
	local ret = {}
	local shortcutData = LuaUIUtils.getDeviceShortcutData()
	local stateData = shortcutData[stateKey] or {}
	local inputKeys = stateData.inputKeyTable or {}
	local player = pg.me

	for idx, keyInfo in pairs(inputKeys) do
		local conditionID = keyInfo[3]

		if (not conditionID or player.triggerMap:isCompleteOrMeetCondition(conditionID)) and LuaUIUtils.checkHotKeyShowState(keyInfo) then
			local actionPaths = {}

			for _, actionPath in pairs(keyInfo[1]) do
				if LuaUIUtils.checkNeedAbilityActionPath(actionPath) then
					local abilityActionPath = LuaUIUtils.getSkillActionPath(pg.me.combatContext.abilityId or 0)

					if abilityActionPath then
						actionPaths[#actionPaths + 1] = abilityActionPath
					end
				end

				if pg.global.inputMgr:CheckActionPathInCurDevice(actionPath) then
					actionPaths[#actionPaths + 1] = actionPath
				end
			end

			if #actionPaths > 0 then
				ret[#ret + 1] = {
					actionPaths = actionPaths,
					desc = keyInfo[2]
				}
			end
		end
	end

	return ret
end

function LuaUIUtils.checkHotKeyShowState(keyInfo)
	local actionPath = keyInfo[1][1]

	if pg.me:checkArkSceneState() and table.contains(LuaUIUtils.ArkForbidenOperation, actionPath) then
		return false
	end

	local isInCatch = pg.me:isInCatchMode()
	local isInThrowItem = pg.me:isThrowItem()
	local isInSocialScene = Utils.isInSocialScene()

	if actionPath == "Player/Jump" and isInCatch then
		return false
	end

	if actionPath == "Hud/Snapshot" and isInCatch then
		return false
	end

	if actionPath == "Skill/LockTarget" and (isInSocialScene or isInThrowItem or isInCatch) then
		return false
	end

	if actionPath == "Hud/SwitchSkillGroup" and (pg.global.scene.curScene and pg.global.scene.curScene.getClassType() and pg.global.scene.curScene.getClassType() == "TempleScene" or pg.space and pg.space:isHomeCamp()) then
		return false
	end

	local hudCtrl = pg.global.ui.hudV2

	if actionPath == "Hud/GamepadMenu" and hudCtrl and not hudCtrl:checkCanOpenGamepadMenu() then
		return false
	end

	if actionPath == "Hud/NormalAttack" and (isInCatch or not pg.game:checkModuleEnable(ClientConst.ModuleKey.NormalAttack)) then
		return false
	end

	if actionPath == "Player/StartSprint" and not pg.game:checkModuleEnable(ClientConst.ModuleKey.Dash) then
		return false
	end

	if actionPath == "Player/StartSprint" and (isInCatch or pg.pawn and pg.pawn:FLY_ST() and (pg.pawn:getConfigData().canFly < 3 or pg.me:judgeStaminaInCombat(TagMask.Fly))) then
		return false
	end

	if actionPath == "Hud/BallMenu" and (isInSocialScene or not pg.game:checkModuleEnable(ClientConst.ModuleKey.BallAndItem) or pg.space and (pg.space:isBossRushEnv() or pg.space:isRogueEnv()) or isInThrowItem or isInCatch) then
		return false
	end

	if actionPath == "Hud/TeamSpeech" then
		return not pg.game.speech:checkMemberInRoom(pg.me.uid)
	end

	if actionPath == "Hud/PushTalk" then
		return not isInCatch and pg.game.speech:checkMemberInRoom(pg.me.uid) and not pg.game.setting:getTeamSpeechFreeTalk()
	end

	if actionPath == "Skill/LockTarget" then
		return not pg.global.ui.hudV2 or not pg.global.ui.hudV2.RD or not pg.global.ui.hudV2.RD.interactGesture or not pg.global.ui.hudV2.RD.interactGesture.transform
	end

	return true
end

function LuaUIUtils.setKeyHintList(keyHintList, stateKey, useRawBindingPath)
	local shortcutData = LuaUIUtils.getShortcutDataByState(stateKey)

	function keyHintList.luaRenderItem(button, idx, data)
		local objectReference = button.transform:GetComponent("ObjectReference")
		local key = objectReference:GetRefValue("keyHotKeyContent")

		key.useRawBindingPath = useRawBindingPath

		key:SetHotKeyPaths(data.actionPaths[1])

		local btnTips = objectReference:GetRefValue("btnTipsUText")

		ClientTextUtils.setText(btnTips, pg.getLocalizationText(data.desc))
	end

	keyHintList:SetList(shortcutData)
end

function LuaUIUtils.getPlayerStar()
	return pg.me.starTitle
end

function LuaUIUtils.getStarTitleName(star, isFull)
	local cData = PlayerTitleData[star]

	if cData == nil then
		return tostring(star)
	end

	local name = pg.getLocalizationText(cData.nameFirst)

	if isFull then
		name = ClientTextUtils.concatByLanguage(name, pg.getLocalizationText(cData.nameLast))
	end

	return name
end

function LuaUIUtils.getStarTitleNameForIcon(star)
	local cData = PlayerTitleData[star]

	if cData == nil then
		return tostring(star)
	end

	local name = pg.getLocalizationText(cData.nameFirstInIcon)

	return name
end

function LuaUIUtils.getStarNeedLevel(star)
	local cData = PlayerTitleData[star]

	if cData == nil then
		return nil
	end

	return cData and cData.needLevel
end

function LuaUIUtils.getStarIcon(star, isSmallIcon)
	local cData = PlayerTitleData[star]

	if cData == nil then
		return nil
	end

	return isSmallIcon and cData.iconSmall or cData.icon
end

function LuaUIUtils.renderStarToolTip(toolTip, star)
	local objectReference = toolTip:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local title = LuaUIUtils.getStarTitleName(star or pg.me.starTitle, true)

	ClientTextUtils.setText(txtNameUSDFText, title)
end

function LuaUIUtils.renderLevelToolTip(toolTip)
	local objectReference = toolTip:GetComponent("ObjectReference")
	local txtTitle = objectReference:GetRefValue("txtTitle")
	local txtNum = objectReference:GetRefValue("txtNum")
	local txtDesc = objectReference:GetRefValue("txtDesc")
	local btnUpUButton = objectReference:GetRefValue("btnUpUButton")
	local btnNameUSDFText = objectReference:GetRefValue("btnNameUSDFText")

	txtNum:SetActive(true)

	local info = LuaUIUtils.getPlayerInfo()

	ClientTextUtils.setText(txtTitle, pg.getGameString("CURRENT_EXP"))
	ClientTextUtils.setText(txtNum, string.format("%d/%d", info.curExp, info.maxExp))
	ClientTextUtils.setText(txtDesc, pg.getGameString("LEVEL_DESCRIPTION"))
	toolTip:TryChangePage("Btn", 1)

	function btnUpUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_HELP, {
			helpId = 209
		})
	end

	ClientTextUtils.setText(btnNameUSDFText, pg.getGameString("BTN_TITLE_LEVEL_UP_HELP"))
end

function LuaUIUtils.getMaxEnableUpTitle(player, title, idx)
	idx = idx or 0

	local curStarTitle = player.starTitle or 0
	local nextTitle = curStarTitle + idx
	local cData = PlayerTitleData[nextTitle]

	if cData == nil then
		return title
	end

	local curLevel = player.level or 0
	local needLv = cData.needLevel or 999
	local canUp = needLv <= curLevel

	if canUp then
		idx = idx + 1
		title = pg.getLocalizationText(cData.name)
		title = LuaUIUtils.getMaxEnableUpTitle(player, title, idx)
	end

	return title
end

function LuaUIUtils.startUPStarAssess()
	if Utils.checkCanUpGradeStar(pg.me) then
		LuaUIUtils.openQuestPanel()
	else
		pg.global.ui:open(UIConst.UI_ID_HELP, {
			helpId = 209
		})
	end
end

function LuaUIUtils.openQuestPanel()
	local curStarTitle = pg.me.starTitle or 0
	local nextTitle = curStarTitle + 1
	local cData = PlayerTitleData[nextTitle]

	pg.global.ui:open(UIConst.UI_ID_QUEST_PANEL, {
		questId = cData.quest
	})
end

function LuaUIUtils.getMaxCurrentLv(star)
	local maxLv

	for i, v in ipairs(PlayerLevelTable) do
		if v.needTitle and star < v.needTitle then
			maxLv = i

			break
		end
	end

	maxLv = maxLv or #PlayerLevelTable

	return maxLv
end

function LuaUIUtils.checkNeedUpTitle()
	local playerTitle = pg.me.starTitle or 0

	for i, v in ipairs(PlayerLevelTable) do
		if v.needTitle and playerTitle < v.needTitle then
			local titleCanUp = true

			if v.needTitle > 1 and PlayerTitleData[v.needTitle] then
				local titleCfg = PlayerTitleData[v.needTitle]

				titleCanUp = titleCfg.quest ~= nil
			end

			return titleCanUp and i == pg.me.level
		end
	end

	return false
end

function LuaUIUtils.getDescriptionData(id)
	local res = {}
	local cData = DescriptionInformationData[id]

	if cData == nil then
		return res
	end

	res.popUpType = UIConst.DESCRIPTION_POP_UP_TYPE.NO_BTN

	local isTab1Info = true

	for index, data in ipairs(cData) do
		if data.icon == UIConst.DESCRIPTION_ITEM_TYPE.TITLE then
			res.title = pg.getLocalizationText(data.txt)
		elseif data.icon == UIConst.DESCRIPTION_ITEM_TYPE.TAB_NAME then
			res.popUpType = UIConst.DESCRIPTION_POP_UP_TYPE.HAVE_TAB

			if res.tab1Name then
				res.tab2Name = data.txt
				isTab1Info = false
			else
				res.tab1Name = data.txt
			end
		else
			res.content = res.content or {}

			local insertList

			if isTab1Info then
				res.content.info1 = res.content.info1 or {}
				insertList = res.content.info1
			else
				res.content.info2 = res.content.info2 or {}
				insertList = res.content.info2
			end

			local txtContent = data.txt

			if data.value then
				local canProcess = true

				for _, v in ipairs(data.value) do
					if v == 0 then
						canProcess = false

						break
					end
				end

				if canProcess == true then
					txtContent = ValueDisplayUtils.getFormatTxtNoParam(data.value, data.txt)
				end
			end

			table.insert(insertList, {
				tIndex = UIConst.DESCRIPTION_ITEM_TYPE_2_TINDEX[data.icon],
				content = txtContent,
				subTitleType = data.subTitleType
			})
		end
	end

	return res
end

function LuaUIUtils.getGradeContent(player)
	local res = {}

	if player == nil then
		return res
	end

	if player.starTitle == 0 then
		local dData = DescriptionInformationData[7]

		if dData == nil then
			return res
		end

		res.title = pg.getLocalizationText(dData[1].txt)

		local nextTitle = player.starTitle + 1
		local info = Utils.getTitleAssessInfo(nextTitle)

		res.state = info.state

		local contentList = {}

		for infoIdx = 2, #dData do
			table.insert(contentList, {
				tIndex = UIConst.DESCRIPTION_ITEM_TYPE_2_TINDEX[dData[infoIdx].icon],
				content = pg.getLocalizationText(dData[infoIdx].txt)
			})
		end

		res.content = {
			info1 = contentList
		}
		res.state = "TiTileZero"

		return res
	end

	local dData = DescriptionInformationData[1]

	if dData == nil then
		return res
	end

	res.title = pg.getLocalizationText(dData[1].txt)

	local curTitle = player.starTitle or 0
	local maxLv = LuaUIUtils.getMaxCurrentLv(curTitle)
	local cData = PlayerTitleData[curTitle]
	local cT = LuaUIUtils.getStarTitleName(curTitle, true)
	local needLv = cData.needLevel or 0
	local nextTitle = curTitle + 1
	local info = Utils.getTitleAssessInfo(nextTitle)

	res.state = info.state
	cData = PlayerTitleData[nextTitle]

	if cData == nil then
		nextTitle = curTitle
		cData = PlayerTitleData[nextTitle]
	end

	local nT = LuaUIUtils.getStarTitleName(nextTitle, true)
	local contentList = {}

	contentList[1] = {
		tIndex = 0,
		content = pg.getLocalizationText(dData[2].txt)
	}
	contentList[2] = {
		tIndex = 1,
		content = pg.getFormatText(pg.getLocalizationText(dData[3].txt), needLv, nT)
	}
	contentList[3] = {
		tIndex = 1,
		content = pg.getFormatText(pg.getLocalizationText(dData[4].txt), 0, 0, cT, maxLv)
	}
	contentList[4] = {
		tIndex = 0,
		content = pg.getLocalizationText(dData[5].txt)
	}
	contentList[5] = {
		tIndex = 1,
		content = pg.getLocalizationText(dData[6].txt)
	}

	for i, v in ipairs(contentList) do
		v.tIndex = UIConst.DESCRIPTION_ITEM_TYPE_2_TINDEX[dData[i + 1].icon]
	end

	if not info.can and info.state == "TimeNotMatch" then
		local addContent = pg.getGameString("GRADE_UNLOCK_DAY")
		local timeString = LuaUIUtils.timeStampToUtcString(info.formatTime)

		contentList[6] = {
			tIndex = UIConst.DESCRIPTION_ITEM_TYPE_2_TINDEX[dData[#contentList].icon],
			content = pg.getFormatText(addContent, nT, timeString)
		}
	end

	res.content = {
		info1 = contentList
	}

	return res
end

function LuaUIUtils.getPlayerInfo()
	local res = {}
	local me = pg.me

	if me == nil then
		return res
	end

	res.curExp = me.exp
	res.curSta = me.starTitle
	res.curLev = me.level

	local cData = LevelData[res.curLev + 1]

	if cData == nil then
		cData = LevelData[res.curLev]
	end

	if cData then
		res.maxExp = cData.needExp
	end

	return res
end

function LuaUIUtils.renderCommonSmallTip(uWidget, title, desc)
	local objectReference = uWidget:GetComponent("ObjectReference")
	local txtTitle = objectReference:GetRefValue("txtTitle")
	local txtDesc = objectReference:GetRefValue("txtDesc")

	ClientTextUtils.setText(txtTitle, title)
	ClientTextUtils.setText(txtDesc, desc)
end

function LuaUIUtils.bindHotKey(obj, path, func, hotKeyContent, priority)
	if obj == nil then
		return
	end

	local gamepadBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, path)

	if gamepadBind == nil then
		return
	end

	if hotKeyContent then
		gamepadBind.keyBoardContent = hotKeyContent
	end

	gamepadBind.isVirtual = true
	gamepadBind.priority = priority or -1
	gamepadBind.actionPath = path

	function gamepadBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			return func()
		end
	end

	return gamepadBind
end

function LuaUIUtils.waitHotKeyContentObjectReference(owner, hotKeyContent, callback)
	if not owner or not hotKeyContent or IsNil(hotKeyContent) or not callback then
		return
	end

	local keyContainer = hotKeyContent:GetComponent("UContainer")

	if not keyContainer then
		local objectReference = hotKeyContent:GetComponent("ObjectReference")

		if objectReference and not IsNil(objectReference) then
			callback(objectReference)
		end

		return
	end

	local function getLoadedObjectReference()
		if IsNil(hotKeyContent) or IsNil(keyContainer) then
			return true, nil
		end

		if not keyContainer:CheckURLLoaded() then
			return false, nil
		end

		local keyContent = keyContainer.content

		if IsNil(keyContent) then
			return true, nil
		end

		return true, keyContent:GetComponent("ObjectReference")
	end

	local loaded, objectReference = getLoadedObjectReference()

	if loaded then
		if objectReference then
			callback(objectReference)
		end

		return
	end

	if not owner.startTimer or not owner.killTimer then
		return
	end

	local timerId

	timerId = owner:startTimer(function()
		local isLoaded, loadedObjectReference = getLoadedObjectReference()

		if not isLoaded then
			return
		end

		owner:killTimer(timerId)

		if loadedObjectReference then
			callback(loadedObjectReference)
		end
	end, 0, true)

	return timerId
end

function LuaUIUtils.bindFuncBtnHotKey(gameObject, keyBindingName, actionPath, callback)
	local keyBindingPro = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, keyBindingName)
	local objectReference = keyBindingPro:GetComponent("ObjectReference")
	local hotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	keyBindingPro.isVirtual = true
	keyBindingPro.keyBoardContent = hotKeyContent
	keyBindingPro.actionPath = actionPath

	function keyBindingPro.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and callback then
			callback()
		end
	end
end

function LuaUIUtils.getLimitTitleString(limitType)
	local str = ""

	if limitType == 1 then
		str = pg.getGameString("SHOP_ITEM_LIMIT_DAY")
	elseif limitType == 2 then
		str = pg.getGameString("SHOP_ITEM_LIMIT_WEEK")
	elseif limitType == 3 then
		str = pg.getGameString("SHOP_ITEM_LIMIT_MONTH")
	elseif limitType == 4 then
		str = pg.getGameString("SHOP_ITEM_LIMIT_SCENE")
	else
		str = pg.getGameString("SHOP_ITEM_LIMIT_FOREVER")
	end

	return str .. " : "
end

function LuaUIUtils.getNewAvatarCount()
	local newCount = 0

	for id, value in pairs(pg.me.headIconDicts) do
		local isNew = pg.me:getRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarIcon .. id, true)

		if value and pg.me.headIcon ~= id and isNew then
			newCount = newCount + 1
		end
	end

	return newCount
end

function LuaUIUtils.getHeadIcon(playerId)
	if playerId == pg.me.id then
		return PlayerHeadIconData[pg.me.headIcon] and PlayerHeadIconData[pg.me.headIcon].res or ""
	else
		local playerInfo = pg.game.chat:getPlayerInfo(playerId)

		if playerInfo then
			local headIcon = playerInfo.headIcon or 1

			return PlayerHeadIconData[headIcon] and PlayerHeadIconData[headIcon].res or ""
		end
	end

	return ""
end

function LuaUIUtils.getNewAvatarFrameCount()
	local newCount = 0

	for id, value in pairs(pg.me.headFrameDicts) do
		local isNew = pg.me:getRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarFrame .. id, true)

		if value and pg.me.headFrame ~= id and isNew then
			newCount = newCount + 1
		end
	end

	return newCount
end

function LuaUIUtils.checkHasNewAvatar()
	local newCount = LuaUIUtils.getNewAvatarCount()
	local lastNewCount = pg.me:getRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarIconNewCount, 0)

	return newCount ~= lastNewCount
end

function LuaUIUtils.checkHasNewAvatarFrame()
	local newCount = LuaUIUtils.getNewAvatarFrameCount()
	local lastNewCount = pg.me:getRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarFrameNewCount, 0)

	return newCount ~= lastNewCount
end

function LuaUIUtils.renderPlayerAvatar(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local equipIconUWidget = objectReference:GetRefValue("equipIconUWidget")

	button:TryChangePage("Lock", data.isLock and 1 or 0)
	equipIconUWidget:SetActive(data.isEquip == true)

	local playerHeadUWidget = button:GetComponent("ObjectReference"):GetRefValue("playerHeadUWidget")

	LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, data, true)

	if data.isAvatarList then
		local isNew = pg.me:getRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarIcon .. data.iconId, true)

		if not data.isLock and pg.me.headIcon ~= data.iconId and isNew then
			pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_PLAYER_AVATAR_ICON_LIST .. data.iconId, button, true, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
		end
	end

	if data.isAvatarFrameList then
		local isNew = pg.me:getRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarFrame .. data.iconId, true)

		if not data.isLock and pg.me.headFrame ~= data.iconId and isNew then
			pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_PLAYER_AVATAR_FRAME_LIST .. data.iconId, button, true, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
		end
	end
end

function LuaUIUtils.renderPlayerAvatarButton(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
	local levelUWidget = objectReference:GetRefValue("levelUWidget")
	local playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")

	LuaUIUtils.renderPlayerSparkButton(objectReference, data.playerId, data.avatarType, data.playSparkAnimation)

	if levelUWidget ~= nil then
		levelUWidget:SetActive(not data.hideLevel)
	end

	local playerInfo = data.playerInfo

	if playerInfo == nil then
		playerInfo = pg.game.chat:getPlayerInfo(data.playerId)
	end

	if playerInfo == nil then
		return
	end

	LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, data, true)
	ClientTextUtils.setText(textLvUSDFText, playerInfo.level)

	if data.showOnlineState then
		button:TryChangePage("State", playerInfo.online and 1 or 2)
	end

	if data.showCaptain then
		button:TryChangePage("Captain", pg.me:isUidTeamLeader(playerInfo.uid) and 1 or 0)
	end

	if data.canOpenInfoPlayerCard then
		function button.luaClick()
			local param = {
				openType = ClientConst.PlayerInfoOpenType.Chat,
				playerId = data.playerId,
				playerInfo = playerInfo,
				openSource = data.openSource or pg.game.chat.AddFriendSource.PlayerCard
			}

			LuaUIUtils.openInfoPlayerCard(param)
		end
	end
end

function LuaUIUtils.sendCustomLog(logName, logParam, eventType)
	local logData = {}

	if pg.me then
		logData.server_id = pg.me.serverId
		logData.role_name = pg.me.playerName
		logData.role_level = pg.me.level

		if pg.me.space then
			logData.game_scene_id = pg.me.space.sceneId
			logData.game_space_nuid = pg.me.space.id
		end
	end

	for key, value in pairs(logParam) do
		logData[key] = value
	end

	GlobalData.BILogger:customeLog(logName, logData, eventType)
end

function LuaUIUtils.bindViewCtrlKeyBind(obj, triggerCallback)
	local viewAxisBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, "viewAxis")

	viewAxisBind.isVirtual = true
	viewAxisBind.priority = 0
	viewAxisBind.actionPath = "Camera/ViewAxis"

	function viewAxisBind.luaTrigger(inputInfo)
		pg.game.input.cameraProcessor:handleViewAxisAction(inputInfo)
	end

	local viewAxisGamepadBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, "viewAxisGamepad")

	viewAxisGamepadBind.isVirtual = true
	viewAxisGamepadBind.priority = 0
	viewAxisGamepadBind.actionPath = "Camera/ViewAxisGamepad"

	function viewAxisGamepadBind.luaTrigger(inputInfo)
		pg.game.input.cameraProcessor:handleViewAxisGamepadAction(inputInfo)
	end
end

function LuaUIUtils.getBossTitleCombatState(ent)
	if not ent then
		return UIConst.BossCombatState.Normal
	end

	if pg.me and pg.me:isInCombat() then
		local configData = ent:getConfigData()
		local noWarnRadius = configData.followRadius - (configData.followWarnRadius or 5)

		if Vector3.HoriSqrDistance(ent.enterCombatPosition, pg.pawn:getPosition()) < noWarnRadius * noWarnRadius then
			return UIConst.BossCombatState.InBattle
		else
			return UIConst.BossCombatState.Leaving
		end
	else
		return UIConst.BossCombatState.Normal
	end
end

function LuaUIUtils.renderExploreList(List, templateId)
	local pData = PetData[templateId]
	local ret = {}

	for k, info in pairs(ExploreAbilityData) do
		if pData[k] then
			local item = {}
			local level = pData[k]

			item.level = level
			item.name = info.name

			if info.icon then
				if #info.icon <= 1 then
					item.icon = info.icon
				else
					item.icon = info.icon[level]
				end
			end
		end
	end

	function List.luaRenderItem(button1, index1, data1)
		local objectReference = button1:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data1.icon

		ClientTextUtils.setText(txtNameUBaseText, data1.exploreLevel)
		button1:TryChangePage("Quality", data1.level)
	end

	List:SetList(ret)
end

function LuaUIUtils.getRogueEnemyList()
	local levelCfg = RoguelikeData[pg.me.curRogueLayer]
	local data = {}

	if levelCfg.monsterInformation then
		for _, pet in ipairs(levelCfg.monsterInformation) do
			local petInfo = {}
			local pData = PetData[pet[1]] or {}

			petInfo.level = pet[2]
			petInfo.iconName = pData.iconName

			local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

			petInfo.elementIds = elementIds
			petInfo.elementNames = elementNames

			table.insert(data, petInfo)
		end
	end

	return data
end

function LuaUIUtils.renderRogueEnemyInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local petIconUImage = objectReference:GetRefValue("petIconUImage")
	local elementUButton = objectReference:GetRefValue("elementUButton")
	local numLevelUText = objectReference:GetRefValue("numLevelUText")

	petIconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender), function()
		return
	end)

	if data.elementNames and data.elementNames[1] then
		LuaUIUtils.setElementButtonNew(elementUButton, data.elementNames[1].element)
	end

	ClientTextUtils.setText(numLevelUText, "Lv.", data.level)
end

function LuaUIUtils.toastPoiPopup(state, priority, uniqueId, showType, icon, title, subTitle, music, duration, extraArgs, delayTime)
	local toastArgs = {
		POIShowType = showType,
		POIIcon = icon,
		POIMusic = music,
		title = title,
		completeTitle = title,
		failTitle = title,
		subTitle = subTitle,
		completeText = subTitle,
		failText = subTitle
	}

	if extraArgs then
		table.merge(toastArgs, extraArgs)
	end

	local data = {
		state = state,
		priority = priority,
		uniqueId = uniqueId,
		duration = duration,
		overallDelayTime = delayTime,
		args = toastArgs
	}

	if uniqueId then
		pg.global.ui.tips:hidePoi(uniqueId)
	end

	pg.global.ui.tips:showPoi(data)
end

function LuaUIUtils.clearToastPoiPopup(uniqueId)
	pg.global.ui.tips:hidePoi(uniqueId)
end

function LuaUIUtils.openPlayerEnhance(param, uiOpenCb)
	if not LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PLAYERENHANCEMENT) then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_NOT_OPEN"))

		return
	end

	if pg.me.isUIOpened[UIConst.UI_ID_PLAYER_ENHANCEMENT] then
		pg.global.ui:open(UIConst.UI_ID_PLAYER_ENHANCEMENT, param, uiOpenCb)
	else
		pg.global.ui.playerEnhanceLoading:open(param, uiOpenCb)
	end
end

function LuaUIUtils.appendTable(t1, t2)
	for i = 1, #t2 do
		t1[#t1 + 1] = t2[i]
	end
end

function LuaUIUtils.isOverseas()
	return Utils.isOverseas()
end

function LuaUIUtils.setTextTooltip(tipItem, desc)
	local objectReference = tipItem:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, desc)
end

function LuaUIUtils.renderGamePadKey(button, data)
	local objRef = button.transform:GetComponent("ObjectReference")
	local keyHotKeyContent = objRef:GetRefValue("keyHotKeyContent")
	local txtNameUText = objRef:GetRefValue("btnTipsUText")
	local keyUList = objRef:GetRefValue("keyUList")

	function keyUList.luaFinishRender(list)
		return
	end

	keyHotKeyContent:SetHotKeyPaths(data.path)
	ClientTextUtils.setText(txtNameUText, data.name)
	button:TryChangePage("KeyType", data.isImportant and 1 or 0)
end

function LuaUIUtils.renderTextTip(button, data)
	function button.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		if data.state == LuaUIUtils.PetInfoState.None then
			local smallAreaCfg = MapBlockConfigData[data.smallAreaId]
			local areaName = pg.getLocalizationText(smallAreaCfg.areaName)
			local petData = PetData[data.petPrototypeId]
			local weatherText = petData.condition and string.format(pg.getGameString("PET_WEATHER_TIP"), pg.getLocalizationText(petData.condition)) or ""
			local clueText = petData.clue and ", " .. string.format(pg.getGameString("PET_CLUE_TIP"), pg.getLocalizationText(petData.clue)) or ""
			local rulesText = petData.rules and ", " .. pg.getLocalizationText(petData.rules) or ""

			ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getFormatText(pg.getGameString("PET_EREA_NOT_FIND_TIP"), areaName, weatherText, clueText, rulesText))

			if pg.game.setting:getShowDebugId() then
				ClientTextUtils.setText(txtNameUSDFText, txtNameUSDFText.text .. "-" .. tostring(data.petPrototypeId))
			end
		end
	end
end

function LuaUIUtils.checkInOtherPlayerWorld()
	if not pg.space then
		return false
	end

	if pg.space:isGrabEgg() then
		return true, pg.getGameString("GRAB_EGG_EXIT_ECS")
	end

	if pg.space:isBossRushEnv() then
		return true, ""
	end

	if pg.me:isInLeaderWorld() then
		return true, pg.getGameString("EXIT_OTHERS_WORLD")
	end

	return false
end

function LuaUIUtils.checkCarryIsRecommend(petId, carryId)
	local petInfo = pg.me:getPetInfo(petId)
	local ppd = petInfo and PetPrototypeData[petInfo.templateId]
	local isRecommend = false

	if ppd then
		if ppd.recommendSuit and ppd.recommendSuit[1] then
			isRecommend = carryId == ppd.recommendSuit[1]
		end

		if not isRecommend and ppd.recommendEquipment then
			for _, eid in ipairs(ppd.recommendEquipment) do
				isRecommend = carryId == eid

				if isRecommend then
					break
				end
			end
		end
	end

	return isRecommend
end

function LuaUIUtils.bindCommonTipInfo(button, tip)
	function button.luaRenderTooltip(button, panel)
		local objectReference = panel:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, tip)
	end
end

function LuaUIUtils.openPhotoFolder()
	local picturesPath = CS.FunPlus.WorldX.Manager.MobileCameraManager.photoPath

	pgUtils.OpenFolder(picturesPath)
end

function LuaUIUtils.renderPlayerInfo(button, playerId)
	local playerInfo = pg.game.chat:getPlayerInfo(playerId)

	if playerInfo == nil then
		return
	end

	local playerLevel = button.transform:Find("Emblem/TxtName")

	if playerLevel and playerInfo.level then
		ClientTextUtils.setText(playerLevel:GetComponent("UBaseText"), "")
	end

	local playerName = button:GetChild("TxtName"):GetComponent("UBaseText")

	ClientTextUtils.setText(playerName, LuaUIUtils.getPlayerDisplayName(playerId, playerInfo.playerName))

	if playerId == pg.me.uid then
		ClientTextUtils.setText(playerName, pg.me.playerName)
	end
end

function LuaUIUtils.renderRenderAccess(button, data)
	if data.empty then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")

	iconUImage.url = data.icon

	rayBoxUWidget:SetActive(false)
	button:TryChangePage("Quality", data.quality)
end

function LuaUIUtils.resetPlayerState()
	local me = pg.me

	if not me then
		return
	end

	if not me:SWIM_ST() and not me:DEAD_ST() then
		local state = me:playAnimation(PlayableConst.MainMenu_Operate_End, true, nil, nil, 0)

		if not state then
			return
		end
	end

	if me.eModel then
		me.eModel.InSocialAnim = false
	end

	if me:isControllingPet() then
		local petEnt = me:getCurPetEntity()

		if petEnt and petEnt.eModel then
			petEnt.eModel.InSocialAnim = false
		end
	end
end

function LuaUIUtils.renderTitleTab(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local name1 = objectReference:GetRefValue("name1")
	local name2 = objectReference:GetRefValue("name2")

	ClientTextUtils.setText(name1, data.label)
	ClientTextUtils.setText(name2, data.label)
end

function LuaUIUtils.goToFromEvent(params)
	if params == nil then
		return
	end

	local type = params.type or 0
	local id = params.id or 0

	if id <= 0 then
		return
	end

	local callback1 = params.callback1
	local callback2 = params.callback2
	local callback3 = params.callback3
	local guideId = params.guideId

	local function uiOpenCb()
		if guideId ~= nil then
			pg.game.guide:clientStartGuide(guideId)
		end
	end

	if type == 1 then
		local data = ItemSourceData[id]

		LuaUIUtils.clueSeek(data, uiOpenCb)

		if callback1 then
			callback1()
		end
	elseif type == 2 then
		pg.me:doEvent(id, {
			uiOpenCb = uiOpenCb
		})

		if callback2 then
			callback2()
		end
	elseif type == 3 then
		pg.me:doEvent(id)

		if callback3 then
			callback3()
		end
	end
end

function LuaUIUtils.setShieldBar(ent, barMask, shieldHealthBar, isSelfFuse, rootChangePage)
	local barUI = isSelfFuse and barMask or shieldHealthBar

	if not ent then
		if barUI then
			barUI:SetActive(false)
		end

		return
	end

	local showShieldBar = false
	local nearlyZero = 0.01
	local showAni = isSelfFuse and CS.XGUI.EInvokeTime.Custom1
	local hideAni = isSelfFuse and CS.XGUI.EInvokeTime.Custom2 or CS.XGUI.EInvokeTime.Custom6

	if rootChangePage then
		showAni = nil
		hideAni = nil
	end

	local curPoint = 0
	local maxPoint = 0

	for i = #ent.shieldDataList, 1, -1 do
		local shieldData = ent.shieldDataList[i]

		if shieldData.curPoint > 0 then
			if not ent.shieldMaxPointMap then
				ent.shieldMaxPointMap = {}
			end

			local shieldKey = shieldData.buffInsId and shieldData.buffInsId ~= 0 and shieldData.buffInsId or i
			local perMaxPoint = math.max(ent.shieldMaxPointMap[shieldKey] or 0, shieldData.curPoint)

			ent.shieldMaxPointMap[shieldKey] = perMaxPoint

			if isSelfFuse or shieldData.buffInsId and shieldData.buffInsId ~= 0 then
				curPoint = curPoint + shieldData.curPoint
				maxPoint = perMaxPoint + maxPoint
			else
				curPoint = shieldData.curPoint
				maxPoint = perMaxPoint

				break
			end
		end
	end

	if curPoint > 0 then
		if barUI then
			local preBarUIActive = barUI.gameObjectActive

			barUI:SetActive(true)

			showShieldBar = true

			if not preBarUIActive then
				if showAni then
					barUI:InvokeCallback(showAni)
				end

				if rootChangePage then
					rootChangePage:TryChangePage("Shield", 1)
				end
			end
		end

		shieldHealthBar.maxHp = maxPoint

		shieldHealthBar:ProgressHp(curPoint)

		if curPoint <= nearlyZero and barUI then
			if hideAni then
				barUI:InvokeCallback(hideAni)
			end

			if rootChangePage then
				rootChangePage:TryChangePage("Shield", 0)
			end
		end

		return
	end

	curPoint = 0
	maxPoint = 0

	if Utils.isPet(ent) then
		local masterEntity = ent:getMasterEntity()

		for i = #masterEntity.shieldDataList, 1, -1 do
			local shieldData = masterEntity.shieldDataList[i]

			if shieldData.curPoint > 0 then
				if not masterEntity.shieldMaxPointMap then
					masterEntity.shieldMaxPointMap = {}
				end

				local shieldKey = shieldData.buffInsId and shieldData.buffInsId ~= 0 and shieldData.buffInsId or i
				local perMaxPoint = math.max(masterEntity.shieldMaxPointMap[shieldKey] or 0, shieldData.curPoint)

				masterEntity.shieldMaxPointMap[shieldKey] = perMaxPoint

				if isSelfFuse or shieldData.buffInsId and shieldData.buffInsId ~= 0 then
					curPoint = curPoint + shieldData.curPoint
					maxPoint = perMaxPoint + maxPoint
				else
					curPoint = shieldData.curPoint
					maxPoint = perMaxPoint

					break
				end
			end
		end

		if curPoint > 0 then
			if barUI then
				local preBarUIActive = barUI.gameObjectActive

				barUI:SetActive(true)

				showShieldBar = true

				if not preBarUIActive then
					if showAni then
						barUI:InvokeCallback(showAni)
					end

					if rootChangePage then
						rootChangePage:TryChangePage("Shield", 1)
					end
				end
			end

			shieldHealthBar.maxHp = maxPoint

			shieldHealthBar:ProgressHp(curPoint)

			if curPoint <= nearlyZero and barUI then
				barUI:SetActive(false)

				if hideAni then
					barUI:InvokeCallback(hideAni)
				end

				if rootChangePage then
					rootChangePage:TryChangePage("Shield", 0)
				end
			end

			return
		end
	end

	if not showShieldBar and barUI then
		barUI:SetActive(false)
	end
end

function LuaUIUtils.generalSetBtnTextL10NCont(uBtn, txtBindName, contKey)
	local btnRecObjRefrence = uBtn:GetComponent("ObjectReference")
	local txt = btnRecObjRefrence:GetRefValue(txtBindName)

	ClientTextUtils.setText(txt, pg.getGameString(contKey))
end

function LuaUIUtils.safeGetRefValue(objectReference, refKey)
	if not objectReference then
		return nil
	end

	local refValue = objectReference:GetRefValue(refKey)

	if not refValue then
		return nil
	end

	return refValue
end

function LuaUIUtils.safeSetGoLayer(gameObject, layer, isForbidRecursive)
	if gameObject then
		gameObject.layer = layer

		if not isForbidRecursive then
			local childCount = gameObject.transform.childCount

			for i = 0, childCount - 1 do
				local childGo = gameObject.transform:GetChild(i)

				LuaUIUtils.safeSetGoLayer(childGo.gameObject, layer, isForbidRecursive)
			end
		end
	end
end

function LuaUIUtils.safeDiv(a, b)
	if b == 0 then
		return 0
	end

	return a / b
end

function LuaUIUtils.setCommonConsoleBarList(transform, data)
	return
end

function LuaUIUtils.setCommonConsoleBarSingleList(transform, data)
	return
end

function LuaUIUtils.setKeyList(ulist, data)
	function ulist.luaRenderItem(button, index, data)
		local objectReference = button.transform:GetComponent("ObjectReference")
		local bottomButtonkeyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
		local bottomButtonbtnTipsUText = objectReference:GetRefValue("btnTipsUText")

		bottomButtonkeyHotKeyContent:SetHotKeyPaths(data.path)
		ClientTextUtils.setText(bottomButtonbtnTipsUText, data.label)
	end

	ulist:SetList(data)
end

function LuaUIUtils.tryAddDelayTimer(uiObj, delayTimerName, delaySecond, delayFinishCb)
	if not uiObj then
		return
	end

	LuaUIUtils.tryRemoveDelayTimer(uiObj, delayTimerName)

	local uiTimers = uiObj.uiTimers or {}

	uiTimers[delayTimerName] = TimerManager.addTimer(delaySecond, function()
		uiTimers[delayTimerName] = nil

		if delayFinishCb then
			delayFinishCb()
		end
	end)
end

function LuaUIUtils.tryRemoveDelayTimer(uiObj, delayTimerName)
	if not uiObj then
		return
	end

	local uiTimers = uiObj.uiTimers or {}

	if uiTimers[delayTimerName] then
		TimerManager.removeTimer(uiTimers[delayTimerName])

		uiTimers[delayTimerName] = nil
	end
end

function LuaUIUtils.getStarItemUrl(stage, isTag)
	if stage <= 6 then
		return AddressDataConst.UI_PET_STARTUP_STARRES_PREFIX .. tostring(stage) .. ".prefab"
	end

	if isTag then
		return AddressDataConst.UI_PET_STARTUP_MAX_STARRES_TAG
	end

	return AddressDataConst.UI_PET_STARTUP_MAX_STARRES
end

function LuaUIUtils.setSelectBoxRect(rectTransform, parentRect, startScreenPos, endScreenPos, startHintRectTrans, hintPivotXOffset, hintPivotYOffset)
	local uiCamera = CS.XGUI.UWidget.uiCamera
	local RectTransformUtility = CS.UnityEngine.RectTransformUtility
	local _, localStart = RectTransformUtility.ScreenPointToLocalPointInRectangle(parentRect, startScreenPos, uiCamera)
	local _, localEnd = RectTransformUtility.ScreenPointToLocalPointInRectangle(parentRect, endScreenPos, uiCamera)
	local xMin = Mathf.Min(localStart.x, localEnd.x)
	local yMin = Mathf.Min(localStart.y, localEnd.y)
	local xMax = Mathf.Max(localStart.x, localEnd.x)
	local yMax = Mathf.Max(localStart.y, localEnd.y)

	rectTransform.anchoredPosition = CS.UnityEngine.Vector2(xMin, yMin)
	rectTransform.sizeDelta = CS.UnityEngine.Vector2(xMax - xMin, yMax - yMin)

	if startHintRectTrans then
		local anchorX = localStart.x <= localEnd.x and 0 or 1
		local anchorY = localStart.y <= localEnd.y and 0 or 1
		local corner = CS.UnityEngine.Vector2(anchorX, anchorY)

		startHintRectTrans.anchorMin = corner
		startHintRectTrans.anchorMax = corner
		startHintRectTrans.anchoredPosition = CS.UnityEngine.Vector2.zero

		local pivotX = 0.5 + (anchorX * 2 - 1) * (hintPivotXOffset or 0)
		local pivotY = 0.5 + (anchorY * 2 - 1) * (hintPivotYOffset or 0)

		startHintRectTrans.pivot = CS.UnityEngine.Vector2(pivotX, pivotY)
	end
end

function LuaUIUtils.setSourceSeekButton(button, sourceId, isDirectGotoSource, cbFunc)
	if not sourceId then
		return
	end

	local seekData = ItemSourceData and ItemSourceData[sourceId]

	if not seekData then
		return
	end

	LuaUIUtils.itemSourceTrigger(button, seekData, isDirectGotoSource, sourceId, cbFunc)
end

local _tweenIdCache = {}

function LuaUIUtils.TweenId(name)
	local id = _tweenIdCache[name]

	if id then
		return id
	end

	local bxor = bit.bxor
	local band = bit.band
	local hash = 2166136261

	for i = 1, #name do
		hash = bxor(hash, name:byte(i))
		hash = band(hash * 16777619, 4294967295)
	end

	if hash >= 2147483648 then
		hash = hash - 4294967296
	end

	_tweenIdCache[name] = hash

	return hash
end

function LuaUIUtils.renderPlayerHeadAvatar(playerHeadTransform, headIconId)
	if not playerHeadTransform then
		return
	end

	local transform = playerHeadTransform.transform or playerHeadTransform
	local objectReference = transform:GetComponent("ObjectReference")
	local avatarUImage = objectReference and objectReference:GetRefValue("avatarUImage")
	local headIconData = PlayerHeadIconData[headIconId or pg.me and pg.me.headIcon]

	if avatarUImage and headIconData then
		avatarUImage.url = headIconData.res
	end
end

function LuaUIUtils.renderRainbowPetIcon(avatarRootTransform, worldTemplateId)
	if not avatarRootTransform or not worldTemplateId then
		return
	end

	local transform = avatarRootTransform.transform or avatarRootTransform
	local objectReference = transform:GetComponent("ObjectReference")
	local avatarUImage = objectReference and objectReference:GetRefValue("avatarUImage")

	if not avatarUImage then
		return
	end

	local puppetData = PuppetData[worldTemplateId]
	local petTemplateId = puppetData and puppetData.petPrototypeId or worldTemplateId
	local iconUrl = LuaUIUtils.getPetIconByTemplateId(petTemplateId, LuaUIUtils.PET_ICON)

	if iconUrl and iconUrl ~= "" then
		avatarUImage.url = iconUrl
	end
end

local function getRainbowPetNameText(templateId)
	local puppetData = PuppetData[templateId]
	local petData = PetData[templateId] or puppetData and PetData[puppetData.petPrototypeId]
	local petName = pg.getLocalizationText(puppetData and puppetData.name or petData and petData.name or "")

	return string.format(pg.getGameString("RAINBOW_PET"), petName)
end

function LuaUIUtils.setRainbowPetNameText(textComponent, templateId)
	if not textComponent then
		return
	end

	ClientTextUtils.setText(textComponent, getRainbowPetNameText(templateId))
end

function LuaUIUtils.setRainbowPetAppearText(textComponent, templateId)
	if not textComponent then
		return
	end

	ClientTextUtils.setText(textComponent, string.format(pg.getGameString("RAINBOW_PET_APPEAR"), getRainbowPetNameText(templateId)))
end

return LuaUIUtils
