-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UICameraUtils.lua

local ClientSwitch = require("Common.ClientSwitch")
local PlayableConst = require("Common.Const.PlayableConst")
local VirtualCameraBlendFunction = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local SysConfigData = require("Data.sys_config_data")

return function(LuaUIUtils)
	function LuaUIUtils.get2dEllipsePosAndAngle(targetPos, semiMajorLen, semiMinorLen)
		local dirX, dirY
		local cameraAngleY = 0

		if ClientSwitch.EnableArrowTip3DSpaceMode then
			local playerPos = pg.me:getPosition()

			dirX = targetPos.x - playerPos.x
			dirY = targetPos.z - playerPos.z

			local _, yaw, _ = pg.global.cameraMgr:GetCameraRotationEuler()

			cameraAngleY = yaw
		else
			local targetViewportPosX, targetViewportPosY, targetViewportPosZ = pg.global.cameraMgr:GetTargetViewportPosXYZ(targetPos[1], targetPos[2], targetPos[3])

			dirX = targetViewportPosX - 0.5
			dirY = targetViewportPosY - 0.5

			if targetViewportPosZ < 0 then
				dirX = -dirX
				dirY = -dirY
			end
		end

		local angle = math.deg(math.atan2(dirY, dirX)) + cameraAngleY
		local posx = semiMajorLen * math.cos(math.rad(angle))
		local posy = semiMinorLen * math.sin(math.rad(angle))

		return posx, posy, angle
	end

	function LuaUIUtils.setArrowTipRtPosAndRot(arrowRt, arrowImgRt, targetPos, ratioX, ratioY, arrowImgAngleOffset)
		if ClientSwitch.EnableArrowTip3DSpaceMode then
			pg.global.uiMgr:SetArrowTipInEllipsePosAndRotBy3DSpaceMode(arrowRt, arrowImgRt, targetPos[1] or targetPos.x, targetPos[2] or targetPos.y, targetPos[3] or targetPos.z, ratioX, ratioY, arrowImgAngleOffset)
		else
			pg.global.uiMgr:SetArrowTipInEllipsePosAndRot(arrowRt, arrowImgRt, targetPos[1] or targetPos.x, targetPos[2] or targetPos.y, targetPos[3] or targetPos.z, ratioX, ratioY, arrowImgAngleOffset)
		end
	end

	function LuaUIUtils.setArrowTipRtPosAndRotByViewport(arrowRt, arrowImgRt, targetPos, dx, dy, vz, ratioX, ratioY, arrowImgAngleOffset)
		if ClientSwitch.EnableArrowTip3DSpaceMode then
			pg.global.uiMgr:SetArrowTipInEllipsePosAndRotBy3DSpaceMode(arrowRt, arrowImgRt, targetPos[1] or targetPos.x, targetPos[2] or targetPos.y, targetPos[3] or targetPos.z, ratioX, ratioY, arrowImgAngleOffset)
		else
			pg.global.uiMgr:SetArrowTipInEllipsePosAndRotByViewport(arrowRt, arrowImgRt, dx, dy, vz, ratioX, ratioY, arrowImgAngleOffset)
		end
	end

	function LuaUIUtils.openFishingCaptureVictoryCamera(blendTime)
		blendTime = blendTime or 0.65

		local nearHeight, farHeight = pg.pawn:getCameraHeightInfo()
		local offset = pg.pawn:getConfigData().funcMenuCameraOffsetFront

		offset = offset or {
			0,
			0,
			0
		}

		local pivotOffset = Vector3(offset[1], offset[2] + nearHeight, offset[3])
		local cameraPos = SysConfigData.FISHING_CAMERA_COORD
		local cameraRot = SysConfigData.FISHING_CAMERA_SPIN
		local fov = SysConfigData.FISHING_CAMERA_FOV

		pg.game.camera:cameraBlendToFixedWithTargetByActorId(cameraPos, cameraRot, fov, pg.me.actorId, blendTime, function()
			pg.me.eModel.modelModelView:SetLightIntensity(1)
		end, {
			inheritDir = false,
			blendExponent = 4,
			pivotOffset = pivotOffset,
			blendFunction = VirtualCameraBlendFunction.EaseOut
		})
	end

	function LuaUIUtils.getWristWatchCameraInfo()
		local MIN_CAMERA_ARM_LENGTH = 0.5
		local angle = pg.game.camera.playerCameraMode:getCameraDirToPlayerDirAngle()
		local nearHeight, farHeight = pg.pawn:getCameraHeightInfo()
		local isControllingPet = pg.game.controller:isInControlEnt()
		local pawnConfig = pg.pawn:getConfigData()
		local target = CSEntityManager:GetPositionAgentByActorId(pg.me.actorId)

		local function getCameraCandidate(useFront)
			local offset = useFront and pawnConfig.funcMenuCameraOffsetFront or pawnConfig.funcMenuCameraOffsetBack

			offset = offset or {
				0,
				0,
				0
			}

			return {
				cameraPos = useFront and pg.global.cameraMgr.vcManager:GetFuncMenuFrontPos(isControllingPet) or pg.global.cameraMgr.vcManager:GetFuncMenuBackPos(isControllingPet),
				cameraRot = useFront and pg.global.cameraMgr.vcManager:GetFuncMenuFrontRot(isControllingPet) or pg.global.cameraMgr.vcManager:GetFuncMenuBackRot(isControllingPet),
				fov = useFront and pg.global.cameraMgr.vcManager:GetFuncMenuFrontFov(isControllingPet) or pg.global.cameraMgr.vcManager:GetFuncMenuBackFov(isControllingPet),
				pivotOffset = Vector3(offset[1], offset[2] + nearHeight, offset[3])
			}
		end

		local function getAdjustedArmLength(candidate)
			if target == nil then
				return math.huge
			end

			return CS.FunPlus.WorldX.VirtualCamera.FixedWithTargetCameraMode.GetCollisionAdjustedArmLength(target, candidate.cameraPos, candidate.pivotOffset)
		end

		local initialUseFront = angle > 90
		local useFront = initialUseFront
		local candidate = getCameraCandidate(initialUseFront)
		local armLength = getAdjustedArmLength(candidate)
		local otherArmLength

		if armLength < MIN_CAMERA_ARM_LENGTH then
			local otherUseFront = not initialUseFront
			local otherCandidate = getCameraCandidate(otherUseFront)

			otherArmLength = getAdjustedArmLength(otherCandidate)

			if MIN_CAMERA_ARM_LENGTH <= otherArmLength then
				useFront = otherUseFront
				candidate = otherCandidate
			end
		end

		return candidate, useFront, initialUseFront, armLength, otherArmLength
	end

	function LuaUIUtils.openWristWatchCamera()
		local candidate, useFront, initialUseFront, armLength, otherArmLength = LuaUIUtils.getWristWatchCameraInfo()

		pg.game.camera:cameraBlendToFixedWithTargetByActorId(candidate.cameraPos, candidate.cameraRot, candidate.fov, pg.me.actorId, 0.65, function()
			if useFront then
				pg.me.eModel.modelModelView:SetLightIntensity(1)
			end
		end, {
			inheritDir = false,
			blendExponent = 4,
			pivotOffset = candidate.pivotOffset,
			blendFunction = VirtualCameraBlendFunction.EaseOut
		})

		return LuaUIUtils.openWristWatch(true)
	end

	function LuaUIUtils.openWristWatch(useCommonAnim)
		local me = pg.me

		if not pg.pawn or not pg.pawn:checkStaySocialAnim() then
			return
		end

		if pg.game.controller:isInControlMainPlayer() then
			if me.eModel and not me:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY) then
				me.eModel.InSocialAnim = true

				if not useCommonAnim then
					local state = me:playAnimation(PlayableConst.MainMenu_Idle_Start, true, nil, nil, 0)

					if not state then
						return false
					end

					me:setAnimationSequence(state, math.max(state.Length - 0.2, 0), function(stateTime)
						if stateTime > 0 then
							local loopState = me:playAnimation(PlayableConst.MainMenu_Idle_Loop, true, nil, true, 0)

							if loopState then
								loopState:SetLogicLoop(true)
							end
						end

						return true
					end)
				end

				me:refreshAppearanceCollideMenu(true)

				return true
			end
		elseif me:isControllingPet() then
			local petEnt = me:getCurPetEntity()

			if petEnt and petEnt.eModel then
				petEnt.eModel.InSocialAnim = true

				return true
			end
		end

		return false
	end

	function LuaUIUtils.closeWristWatchCamera()
		LuaUIUtils.resetPlayerState()
		pg.game.camera:cancelBlendToFixedWithTarget(0.5)
	end

	function LuaUIUtils.moveCameraShoulderWithOffset(offset, speed)
		pg.game.camera.playerCameraMode:setPlayerCameraTargetShoulder(offset, speed)
	end
end
