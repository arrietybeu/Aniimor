-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\TextHelper\\TextHelperBase.lua

local TextHelperBase = {}
local TEXT_HELPER_BASE_MOD = "GameApp.Interaction.TextHelper.TextHelperBase"

package.loaded[TEXT_HELPER_BASE_MOD] = TextHelperBase

local components = {}
local registerSeq = 0

function TextHelperBase.register(component)
	assert(type(component.meetCondition) == "function", "TextHelperBase.register: meetCondition must be a function")
	assert(type(component.getProcessedText) == "function", "TextHelperBase.register: getProcessedText must be a function")

	registerSeq = registerSeq + 1
	component._registerOrder = registerSeq
	components[#components + 1] = component

	table.sort(components, function(a, b)
		local pa, pb = a.priority or 0, b.priority or 0

		if pa ~= pb then
			return pb < pa
		end

		return (a._registerOrder or 0) < (b._registerOrder or 0)
	end)
end

function TextHelperBase.getSpecificText(ent, interactData, oriText)
	for _, cmp in ipairs(components) do
		if cmp.meetCondition(ent, interactData) then
			return cmp.getProcessedText(oriText, ent, interactData)
		end
	end

	return oriText
end

require("GameApp.Interaction.TextHelper.Component.LeylineFlowerTextHelper")

return TextHelperBase
