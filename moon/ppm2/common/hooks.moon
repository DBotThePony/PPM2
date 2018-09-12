
--
-- Copyright (C) 2017-2018 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


DLib.nw.PoolBoolean('PPM2.InEditor', false)

do
	import GetModel, IsDormant, GetPonyData, IsValid from FindMetaTable('Entity')
	callback = ->
		for _, ply in ipairs player.GetAll()
			if not IsDormant(ply)
				model = GetModel(ply)
				ply.__ppm2_lastmodel = ply.__ppm2_lastmodel or model
				if ply.__ppm2_lastmodel ~= model
					data = GetPonyData(ply)
					if data and data.ModelChanges
						oldModel = ply.__ppm2_lastmodel
						ply.__ppm2_lastmodel = model
						data\ModelChanges(oldModel, model)

		for _, task in ipairs PPM2.NetworkedPonyData.RenderTasks
			ply = task.ent
			if IsValid(ply) and not IsDormant(ply)
				model = GetModel(ply)
				ply.__ppm2_lastmodel = ply.__ppm2_lastmodel or model
				if ply.__ppm2_lastmodel ~= model
					data = GetPonyData(ply)
					if data and data.ModelChanges
						oldModel = ply.__ppm2_lastmodel
						ply.__ppm2_lastmodel = model
						data\ModelChanges(oldModel, model)
	timer.Create 'PPM2.ModelWatchdog', 1, 0, ->
		status, err = pcall callback
		print('PPM2 Error: ' .. err) if not status

do
	import GetModel, IsDormant, GetPonyData, IsValid, IsPonyCached from FindMetaTable('Entity')

	hook.Add 'Think', 'PPM2.PonyDataThink', ->
		for _, ply in ipairs player.GetAll()
			if not IsDormant(ply) and IsPonyCached(ply)
				data = GetPonyData(ply)
				data\Think() if data and data.Think
		for _, task in ipairs PPM2.NetworkedPonyData.RenderTasks
			ply = task.ent
			if IsValid(ply) and not IsDormant(ply) and IsPonyCached(ply) and task.Think
				task\Think()

	hook.Add 'RenderScreenspaceEffects', 'PPM2.PonyDataRenderScreenspaceEffects', ->
		for _, ply in ipairs player.GetAll()
			if not IsDormant(ply) and IsPonyCached(ply)
				data = GetPonyData(ply)
				data\RenderScreenspaceEffects() if data and data.RenderScreenspaceEffects
		for _, task in ipairs PPM2.NetworkedPonyData.RenderTasks
			ply = task.ent
			if IsValid(ply) and not IsDormant(ply) and IsPonyCached(ply) and task.RenderScreenspaceEffects
				task\RenderScreenspaceEffects()

do
	catchError = (err) ->
		PPM2.Message 'Slow Update Error: ', err
		PPM2.Message debug.traceback()

	import Alive from FindMetaTable('Player')
	import IsPonyCached, IsDormant, GetPonyData from FindMetaTable('Entity')
	timer.Create 'PPM2.SlowUpdate', CLIENT and 0.5 or 5, 0, ->
		for _, ply in ipairs player.GetAll()
			if not IsDormant(ply) and Alive(ply) and IsPonyCached(ply) and GetPonyData(ply)
				data = GetPonyData(ply)
				xpcall(data.SlowUpdate, catchError, data, CLIENT) if data.SlowUpdate
		for _, task in ipairs PPM2.NetworkedPonyData.RenderTasks
			if IsValid(task.ent) and task.ent\IsPony()
				xpcall(task.SlowUpdate, catchError, task, CLIENT) if task.SlowUpdate

DISABLE_HOOFSTEP_SOUND_CLIENT = CreateConVar('ppm2_cl_no_hoofsound', '0', {FCVAR_ARCHIVE}, 'Disable hoofstep sound play time') if CLIENT
DISABLE_HOOFSTEP_SOUND = CreateConVar('ppm2_no_hoofsound', '0', {FCVAR_REPLICATED}, 'Disable hoofstep sound play time')

hook.Add 'PlayerStepSoundTime', 'PPM2.Hooks', (stepType = STEPSOUNDTIME_NORMAL, isWalking = false) =>
	return if not IsValid(@) or not @IsPonyCached() or CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT\GetBool() or DISABLE_HOOFSTEP_SOUND\GetBool()
	rate = @GetPlaybackRate() * .5
	if @Crouching()
		switch stepType
			when STEPSOUNDTIME_NORMAL
				return not isWalking and (300 / rate) or (600 / rate)
			when STEPSOUNDTIME_ON_LADDER
				return 500 / rate
			when STEPSOUNDTIME_WATER_KNEE
				return not isWalking and (400 / rate) or (800 / rate)
			when STEPSOUNDTIME_WATER_FOOT
				return not isWalking and (350 / rate) or (700 / rate)
	else
		switch stepType
			when STEPSOUNDTIME_NORMAL
				return not isWalking and (150 / rate) or (300 / rate)
			when STEPSOUNDTIME_ON_LADDER
				return 500 / rate
			when STEPSOUNDTIME_WATER_KNEE
				return not isWalking and (250 / rate) or (500 / rate)
			when STEPSOUNDTIME_WATER_FOOT
				return not isWalking and (175 / rate) or (350 / rate)

ENABLE_TOOLGUN = CreateConVar('ppm2_sv_ragdoll_toolgun', '0', {FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow toolgun usage on player death ragdolls')
ENABLE_PHYSGUN = CreateConVar('ppm2_sv_ragdoll_physgun', '1', {FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow physgun usage on player death ragdolls')

hook.Add 'CanTool', 'PPM2.DeathRagdoll', (ply = NULL, tr = {Entity: NULL}, tool = '') -> false if IsValid(tr.Entity) and tr.Entity\GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN\GetBool()
hook.Add 'PhysgunPickup', 'PPM2.DeathRagdoll', (ply = NULL, ent = NULL) -> false if IsValid(ent) and ent\GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_PHYSGUN\GetBool()
hook.Add 'CanProperty', 'PPM2.DeathRagdoll', (ply = NULL, mode = '', ent = NULL) -> false if IsValid(ent) and ent\GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN\GetBool()
hook.Add 'CanDrive', 'PPM2.DeathRagdoll', (ply = NULL, ent = NULL) -> false if IsValid(ent) and ent\GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN\GetBool()
