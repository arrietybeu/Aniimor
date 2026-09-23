-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\UIStringPool.lua

local UIStringPool = {}
local twoDigitNumberTextCache = {}
local hudPetActionPathCache = {}
local hudSupportPetActionPathCache = {}
local hudFinalSkillBarNameCache = {}

function UIStringPool.getTwoDigitText(num)
	if twoDigitNumberTextCache[num] == nil then
		twoDigitNumberTextCache[num] = string.format("%02d", num)
	end

	return twoDigitNumberTextCache[num]
end

function UIStringPool.getHudPetActionPath(petIdx)
	if hudPetActionPathCache[petIdx] == nil then
		hudPetActionPathCache[petIdx] = "Hud/Pet" .. petIdx
	end

	return hudPetActionPathCache[petIdx]
end

function UIStringPool.getHudSupportPetActionPath(petIdx)
	if hudSupportPetActionPathCache[petIdx] == nil then
		hudSupportPetActionPathCache[petIdx] = "Skill/SupportSkill" .. petIdx
	end

	return hudSupportPetActionPathCache[petIdx]
end

function UIStringPool.getHudFinalSkillBarName(index)
	if hudFinalSkillBarNameCache[index] == nil then
		hudFinalSkillBarNameCache[index] = "energyRate" .. index
	end

	return hudFinalSkillBarNameCache[index]
end

return UIStringPool
