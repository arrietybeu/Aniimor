-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\GuideHandlerRegistry.lua

local ActivityConst = require("Common.Const.ActivityConst")
local MockBattleGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.MockBattleGuideHandler")
local LeylineTreeGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.LeylineTreeGuideHandler")
local WaterAreaGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.WaterAreaGuideHandler")
local InterlinkGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.InterlinkGuideHandler")
local FishingCaptureGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.FishingCaptureGuideHandler")
local PetHatchGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.PetHatchGuideHandler")
local TeaPartyGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.TeaPartyGuideHandler")
local SeasonPageGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.SeasonPageGuideHandler")
local StarPlanGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.StarPlanGuideHandler")
local MysteriousMerchantHandler = require("Guis.Panels.Event.Component.CommonGuide.MysteriousMerchantHandler")
local RedBookGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.RedBookGuideHandler")
local TikTokPetGuideHandler = require("Guis.Panels.Event.Component.CommonGuide.TikTokPetGuideHandler")
local GuideHandlerRegistry = {
	[ActivityConst.EventType.MockBattle] = MockBattleGuideHandler,
	[ActivityConst.EventType.LeylineTreeGuide] = LeylineTreeGuideHandler,
	[ActivityConst.EventType.WaterArea] = WaterAreaGuideHandler,
	[ActivityConst.EventType.Interlink] = InterlinkGuideHandler,
	[ActivityConst.EventType.FishingCapture] = FishingCaptureGuideHandler,
	[ActivityConst.EventType.PetHatch] = PetHatchGuideHandler,
	[ActivityConst.EventType.TeaParty] = TeaPartyGuideHandler,
	[ActivityConst.EventType.SeasonPage] = SeasonPageGuideHandler,
	[ActivityConst.EventType.StarPlanGuidePage] = StarPlanGuideHandler,
	[ActivityConst.EventType.MysteriousMerchant] = MysteriousMerchantHandler,
	[ActivityConst.EventType.RedBook] = RedBookGuideHandler,
	[ActivityConst.EventType.LittleFirePersonGuide] = TikTokPetGuideHandler
}

return GuideHandlerRegistry
