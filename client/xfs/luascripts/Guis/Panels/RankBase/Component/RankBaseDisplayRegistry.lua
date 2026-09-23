-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankBase\\Component\\RankBaseDisplayRegistry.lua

local RankConst = require("Const.RankConst")
local RankDisplayValueData = require("Data.rank_display_value_data")
local BuffDisplay = require("Guis.Panels.RankBase.Component.Display.RankBaseBuffDisplay")
local MemberDisplay = require("Guis.Panels.RankBase.Component.Display.RankBaseMemberDisplay")
local PetDisplay = require("Guis.Panels.RankBase.Component.Display.RankBasePetDisplay")
local PlayerDisplay = require("Guis.Panels.RankBase.Component.Display.RankBasePlayerDisplay")
local TextDisplay = require("Guis.Panels.RankBase.Component.Display.RankBaseTextDisplay")
local RankBaseDisplayRegistry = {}
local EMPTY_INFO = {}
local DISPLAY_INFO_TYPE = RankConst.DisplayInfoType
local TARGET_TYPE = RankConst.TargetType

function RankBaseDisplayRegistry.getRenderPlayerName(rankData, playerInfo, rawName)
	local hooks = RankBaseDisplayRegistry._platformHooks

	if hooks and hooks.getRenderPlayerName then
		return hooks.getRenderPlayerName(rankData, playerInfo, rawName)
	end

	return rawName
end

local function renderPlayerInfo(objectReference, rankData, playerInfo)
	return PlayerDisplay.renderPlayerInfo(objectReference, rankData, playerInfo, RankBaseDisplayRegistry.getRenderPlayerName)
end

local function createHandler(targetType, render, supportsAdditionalEntry)
	return {
		targetType = targetType,
		render = render,
		supportsAdditionalEntry = supportsAdditionalEntry == true
	}
end

local function createTextHandler(render)
	return createHandler(TARGET_TYPE.USDF_TEXT, render)
end

local function createPlayerInfoHandler(render, supportsAdditionalEntry)
	return createHandler(TARGET_TYPE.PLAYER_INFO, render, supportsAdditionalEntry)
end

local function createPetInfoHandler(render)
	return createHandler(TARGET_TYPE.PET_INFO, render)
end

local function createMemberLayoutHandler(targetType, render)
	return createHandler(targetType, render)
end

local function createIconLayoutHandler(render)
	return createHandler(TARGET_TYPE.ICON_LAYOUT, render)
end

local function renderEmptyText(objectReference)
	TextDisplay.renderText(objectReference, RankConst.EMPTY_VALUE_TEXT)

	return true
end

local DISPLAY_HANDLERS = {
	[DISPLAY_INFO_TYPE.PLAYER_INFO] = createPlayerInfoHandler(renderPlayerInfo, true),
	[DISPLAY_INFO_TYPE.TEAM_INFO] = createMemberLayoutHandler(TARGET_TYPE.PLAYER_TEAM_LAYOUT, MemberDisplay.renderTeamLayout),
	[DISPLAY_INFO_TYPE.PET_TEAM_INFO] = createMemberLayoutHandler(TARGET_TYPE.MEMBER_LAYOUT, MemberDisplay.renderPetLayout),
	[DISPLAY_INFO_TYPE.PLAYER_LEVEL] = createTextHandler(TextDisplay.renderPlayerLevelText),
	[DISPLAY_INFO_TYPE.PET_INFO] = createPetInfoHandler(PetDisplay.renderPetInfo),
	[DISPLAY_INFO_TYPE.BEST_SCORE] = createTextHandler(TextDisplay.renderScoreText),
	[DISPLAY_INFO_TYPE.BATTLE_BUFF_ICONS] = createIconLayoutHandler(BuffDisplay.renderBattleBuffLayout)
}
local SPECIAL_TEXT_HANDLER = createTextHandler(TextDisplay.renderSpecialText)
local EMPTY_TEXT_HANDLER = createTextHandler(renderEmptyText)

function RankBaseDisplayRegistry.getTitle(displayId, defaultText)
	if displayId == nil or displayId == 0 then
		return defaultText
	end

	local displayValueData = RankDisplayValueData[displayId]

	if not displayValueData then
		return ""
	end

	return pg.getLocalizationText(displayValueData.name)
end

function RankBaseDisplayRegistry.resolve(displayId, displayData, rankData)
	local displayType = displayData.showType
	local specialText = displayData.specialText

	if specialText ~= nil and specialText ~= 0 then
		return SPECIAL_TEXT_HANDLER, specialText
	end

	local rankInfo = rankData.Info or EMPTY_INFO
	local displayValue = rankInfo[tostring(displayId)]

	if displayType == DISPLAY_INFO_TYPE.BEST_SCORE and displayValue == nil then
		displayValue = rankData.Score
	end

	local isSelfPlayerInfo = displayType == DISPLAY_INFO_TYPE.PLAYER_INFO and rankData.MemberId == pg.me.uid

	if displayValue == nil and not isSelfPlayerInfo then
		return EMPTY_TEXT_HANDLER
	end

	return DISPLAY_HANDLERS[displayType], displayValue
end

function RankBaseDisplayRegistry.render(handler, objectReference, rankData, displayValue, petInfoTipPresenter)
	return handler.render(objectReference, rankData, displayValue, petInfoTipPresenter) == true
end

return RankBaseDisplayRegistry
