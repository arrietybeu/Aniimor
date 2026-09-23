-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetTransmog\\PetTransmogSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local CommonSwitch = require("Common.CommonSwitch")
local PetTransmogSystem = Class.LightClass("PetTransmogSystem", SystemBase)

function PetTransmogSystem:onCtor()
	return
end

function PetTransmogSystem:onInit()
	return
end

function PetTransmogSystem:onClear()
	return
end

function PetTransmogSystem:onDestroy()
	return
end

function PetTransmogSystem:requestRoll(petId, lockHoles)
	pg.me:rollTransmog(petId, lockHoles or {})
end

function PetTransmogSystem:requestSaveTempToCustom(petId, tempIndex, imageKey)
	pg.me:saveTempToCustom(petId, tempIndex, imageKey)
end

function PetTransmogSystem:requestReplaceCustom(petId, tempIndex, customIndex, imageKey)
	pg.me:replaceCustomScheme(petId, tempIndex, customIndex, imageKey)
end

function PetTransmogSystem:requestDelCustom(petId, customIndex)
	pg.me:delCustomScheme(petId, customIndex)
end

function PetTransmogSystem:requestUseCustom(petId, customIndex)
	pg.me:useCustomScheme(petId, customIndex)
end

function PetTransmogSystem:requestuseCurrTransmogScheme(petId, imageKey)
	pg.me:useCurrTransmogScheme(petId, imageKey)
end

function PetTransmogSystem:requestreplaceAndUseCurrTransmogScheme(petId, customSchemeIndex, imageKey)
	pg.me:replaceAndUseCurrTransmogScheme(petId, customSchemeIndex, imageKey)
end

function PetTransmogSystem:requestLockSchemeHole(petId, lockHoles)
	pg.me:lockTransmogSchemeHole(petId, lockHoles or {})
end

function PetTransmogSystem:requestSetUseItemFlag(petId, flag)
	pg.me:setUseItemFlag(petId, flag == true)
end

function PetTransmogSystem.canPetTransmog(petId)
	if not CommonSwitch.Pet_Transmog then
		return false
	end

	local pet = pg.me and petId and pg.me:getPetInfo(petId)

	return pet ~= nil and PetTransmogUtils.isTemplateTransmogable(pet.templateId)
end

return PetTransmogSystem
