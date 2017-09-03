
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

do
	import GetModel, IsDormant, GetPonyData, IsValid from FindMetaTable('Entity')
	callback = ->
		for ply in *player.GetAll()
			if not IsDormant(ply)
				model = GetModel(ply)
				ply.__ppm2_lastmodel = ply.__ppm2_lastmodel or model
				if ply.__ppm2_lastmodel ~= model
					data = GetPonyData(ply)
					if data and data.ModelChanges
						oldModel = ply.__ppm2_lastmodel
						ply.__ppm2_lastmodel = model
						data\ModelChanges(oldModel, model)

		for task in *PPM2.NetworkedPonyData.RenderTasks
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
		for ply in *player.GetAll()
			if not IsDormant(ply) and IsPonyCached(ply)
				data = GetPonyData(ply)
				data\Think() if data
		for task in *PPM2.NetworkedPonyData.RenderTasks
			ply = task.ent
			if IsValid(ply) and not IsDormant(ply) and IsPonyCached(ply)
				task\Think()

do
	catchError = (err) ->
		PPM2.Message 'Slow Update Error: ', err
		PPM2.Message debug.traceback()

	import Alive from FindMetaTable('Player')
	import IsPonyCached, IsDormant, GetPonyData from FindMetaTable('Entity')
	timer.Create 'PPM2.SlowUpdate', CLIENT and 0.5 or 5, 0, ->
		for ply in *player.GetAll()
			if not IsDormant(ply) and Alive(ply) and IsPonyCached(ply) and GetPonyData(ply)
				data = GetPonyData(ply)
				xpcall(data.SlowUpdate, catchError, data, CLIENT) if data.SlowUpdate
		for task in *PPM2.NetworkedPonyData.RenderTasks
			if IsValid(task.ent) and task.ent\IsPony()
				xpcall(task.SlowUpdate, catchError, task, CLIENT) if task.SlowUpdate

DISABLE_HOOFSTEP_SOUND_CLIENT = CreateConVar('ppm2_cl_no_hoofsound', '0', {FCVAR_ARCHIVE}, 'Disable hoofstep sound play time') if CLIENT
DISABLE_HOOFSTEP_SOUND = CreateConVar('ppm2_no_hoofsound', '0', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Disable hoofstep sound play time')

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

ENABLE_TOOLGUN = CreateConVar('ppm2_sv_ragdoll_toolgun', '0', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow toolgun usage on player death ragdolls')
ENABLE_PHYSGUN = CreateConVar('ppm2_sv_ragdoll_physgun', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow physgun usage on player death ragdolls')

hook.Add 'CanTool', 'PPM2.DeathRagdoll', (ply = NULL, tr = {Entity: NULL}, tool = '') -> false if IsValid(tr.Entity) and tr.Entity\GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN\GetBool()
hook.Add 'PhysgunPickup', 'PPM2.DeathRagdoll', (ply = NULL, ent = NULL) -> false if IsValid(ent) and ent\GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_PHYSGUN\GetBool()
hook.Add 'CanProperty', 'PPM2.DeathRagdoll', (ply = NULL, mode = '', ent = NULL) -> false if IsValid(ent) and ent\GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN\GetBool()
hook.Add 'CanDrive', 'PPM2.DeathRagdoll', (ply = NULL, ent = NULL) -> false if IsValid(ent) and ent\GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN\GetBool()
