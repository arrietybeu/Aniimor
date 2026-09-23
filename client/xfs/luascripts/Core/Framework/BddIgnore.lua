-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\BddIgnore.lua

pg.bddIgnore = {
	formula_data = true,
	dye_config_data = true,
	custom_default_register_map = true,
	trigger_map_data = true,
	CharacterStateConstImp = true,
	stamina_config_data = true,
	scene_block_info = true,
	puppet_state_conflict_data = true,
	skill_state_conflict_data = true,
	state_conflict_data = true,
	ecs_editor_export_chem_material_data = true,
	anim_state_lookat_priority_data = true,
	anim_tag_lookat_priority_data = true
}
pg.bddIgnoreFolders = {
	["GroupBehaviour."] = true,
	["AICtrData."] = true,
	["BehaviacData."] = true,
	["DialogueGraph."] = true,
	["Input."] = true
}
pg.bddIgnoreLuaPatterns = {
	["%f[%w_]scene_route_data_[^.]+$"] = true,
	["%f[%w_]scene_entity_data_[^.]+$"] = true
}
pg.bddLineCached = {
	custom_trigger_data = true,
	custom_trigger_map_data = true
}

function pg.isBddIgnoreData(module_name)
	module_name = string.gsub(module_name, "Data.", "", 1)

	if pg.bddIgnore[module_name] then
		return true
	end

	for folder, flag in pairs(pg.bddIgnoreFolders) do
		if flag and string.startsWith(module_name, folder) then
			return true
		end
	end

	return false
end
