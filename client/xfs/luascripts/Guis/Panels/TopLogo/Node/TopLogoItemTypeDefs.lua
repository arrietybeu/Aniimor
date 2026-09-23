-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemTypeDefs.lua

local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoItemPet = require("Guis.Panels.TopLogo.Node.TopLogoItemPet")
local TopLogoItemEnvObj = require("Guis.Panels.TopLogo.Node.TopLogoItemEnvObj")
local TopLogoItemPlayer = require("Guis.Panels.TopLogo.Node.TopLogoItemPlayer")
local TopLogoItemPetBall = require("Guis.Panels.TopLogo.Node.TopLogoItemPetBall")
local TopLogoItemDialogueGraphEnt = require("Guis.Panels.TopLogo.Node.TopLogoItemDialogueGraphEnt")
local TopLogoEggTransmitter = require("Guis.Panels.TopLogo.Node.TopLogoEggTransmitter")
local TopLogoItemHatchBox = require("Guis.Panels.TopLogo.Node.TopLogoItemHatchBox")
local TopLogoItemWishingStar = require("Guis.Panels.TopLogo.Node.TopLogoItemWishingStar")
local TopLogoItemHomeObject = require("Guis.Panels.TopLogo.Node.TopLogoItemHomeObject")
local TopLogoCarBoard = require("Guis.Panels.TopLogo.Node.TopLogoCarBoard")
local TopLogoItemInteractable = require("Guis.Panels.TopLogo.Node.TopLogoItemInteractable")
local TopLogoItemPetFertility = require("Guis.Panels.TopLogo.Node.TopLogoItemPetFertility")
local TopLogoItemNPC = require("Guis.Panels.TopLogo.Node.TopLogoItemNPC")
local TopLogoItemEgg = require("Guis.Panels.TopLogo.Node.TopLogoItemEgg")
local TopLogoType = ClientConst.TopLogoType
local byType = {
	[TopLogoType.Pet] = TopLogoItemPet,
	[TopLogoType.EnvObj] = TopLogoItemEnvObj,
	[TopLogoType.Player] = TopLogoItemPlayer,
	[TopLogoType.PetBall] = TopLogoItemPetBall,
	[TopLogoType.DialogueGraph] = TopLogoItemDialogueGraphEnt,
	[TopLogoType.EggTransmitter] = TopLogoEggTransmitter,
	[TopLogoType.HomeFacilityHatchBox] = TopLogoItemHatchBox,
	[TopLogoType.HomeWishingStar] = TopLogoItemWishingStar,
	[TopLogoType.HomeFacility] = TopLogoItemHomeObject,
	[TopLogoType.HomeCarBoard] = TopLogoCarBoard,
	[TopLogoType.InteractableObject] = TopLogoItemInteractable,
	[TopLogoType.PetFertility] = TopLogoItemPetFertility,
	[TopLogoType.NPC] = TopLogoItemNPC,
	[TopLogoType.RobSpaceEgg] = TopLogoItemEgg
}
local defaultBootstrap = {
	defaultMaxDistance = UIConst.TopLogoEnterRange,
	requiresLongRangeLod = function()
		return UIConst.TopLogoEnterRange > UIConst.TopLogoLodNearRange
	end
}
local bootstrapByType = {
	[TopLogoType.Pet] = defaultBootstrap,
	[TopLogoType.EnvObj] = defaultBootstrap,
	[TopLogoType.Player] = defaultBootstrap,
	[TopLogoType.PetBall] = defaultBootstrap,
	[TopLogoType.DialogueGraph] = defaultBootstrap,
	[TopLogoType.EggTransmitter] = defaultBootstrap,
	[TopLogoType.HomeFacilityHatchBox] = defaultBootstrap,
	[TopLogoType.HomeWishingStar] = defaultBootstrap,
	[TopLogoType.HomeFacility] = defaultBootstrap,
	[TopLogoType.HomeCarBoard] = defaultBootstrap,
	[TopLogoType.InteractableObject] = defaultBootstrap,
	[TopLogoType.PetFertility] = defaultBootstrap,
	[TopLogoType.NPC] = defaultBootstrap,
	[TopLogoType.RobSpaceEgg] = defaultBootstrap
}

return {
	byType = byType,
	defaultClass = TopLogoItem,
	bootstrapByType = bootstrapByType,
	defaultBootstrap = defaultBootstrap
}
