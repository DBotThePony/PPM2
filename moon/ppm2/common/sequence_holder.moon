
--
-- Copyright (C) 2017-2020 DBotThePony

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


class PPM2.SequenceHolder extends PPM2.ModifierBase
	@__inherited: (child) =>
		super(child)
		return if not child.SEQUENCES
		seq.numid = i for i, seq in ipairs child.SEQUENCES
		child.SEQUENCES_TABLE = {seq.name, seq for _, seq in ipairs child.SEQUENCES}
		child.SEQUENCES_TABLE[seq.numid] = seq for _, seq in ipairs child.SEQUENCES

	@NEXT_HOOK_ID = 0
	@SequenceObject = PPM2.SequenceBase

	new: =>
		super()
		@isValid = true
		@hooks = {}
		@@NEXT_HOOK_ID += 1
		@fid = @@NEXT_HOOK_ID
		@hookID = "PPM2.#{@@__name}.#{@@NEXT_HOOK_ID}"
		@lastThink = RealTimeL()
		@lastThinkDelta = 0
		@currentSequences = {}
		@currentSequencesIterable = {}

	StartSequence: (seqID = '', time) =>
		return false if not @@SEQUENCES_TABLE
		return false if not @isValid
		return @currentSequences[seqID] if @currentSequences[seqID]
		return false if not @@SEQUENCES_TABLE[seqID]
		SequenceObject = @@SequenceObject
		@currentSequences[seqID] = SequenceObject(@, @@SEQUENCES_TABLE[seqID])
		@currentSequences[seqID]\SetTime(time) if time
		@currentSequencesIterable = [seq for i, seq in pairs @currentSequences]
		return @currentSequences[seqID]

	RestartSequence: (seqID = '', time) =>
		return false if not @isValid
		if @currentSequences[seqID]
			@currentSequences[seqID]\Reset()
			@currentSequences[seqID]\SetTime(time)
			return @currentSequences[seqID]
		return @StartSequence(seqID, time)

	PauseSequence: (seqID = '') =>
		return false if not @isValid
		return @currentSequences[seqID]\Pause() if @currentSequences[seqID]
		return false

	ResumeSequence: (seqID = '') =>
		return false if not @isValid
		return @currentSequences[seqID]\Resume() if @currentSequences[seqID]
		return false

	StopSequence: (...) => @EndSequence(...)
	EndSequence: (seqID = '', callStop = true) =>
		return false if not @isValid
		return false if not @currentSequences[seqID]
		@currentSequences[seqID]\Stop() if callStop
		@currentSequences[seqID] = nil
		@currentSequencesIterable = [seq for i, seq in pairs @currentSequences]
		return true

	ResetSequences: =>
		return false if not @@SEQUENCES
		return false if not @isValid
		seq\Stop() for _, seq in ipairs @currentSequencesIterable
		@currentSequences = {}
		@currentSequencesIterable = {}
		@StartSequence(seq.name) for _, seq in ipairs @@SEQUENCES when seq.autostart

	Reset: => @ResetSequences()

	RemoveHooks: =>
		for _, iHook in ipairs @hooks
			hook.Remove iHook, @hookID

	PlayerRespawn: =>
		return if not @isValid
		@ResetSequences()

	HasSequence: (seqID = '') =>
		return false if not @isValid
		@currentSequences[seqID] and true or false

	GetSequence: (seqID = '') => @currentSequences[seqID]

	Hook: (id, func) =>
		return if not @isValid
		newFunc = (...) ->
			if not IsValid(@GetEntity()) or @GetData()\GetData() ~= @GetEntity()\GetPonyData()
				@RemoveHooks()
				return
			func(@, ...)
			return nil
		hook.Add id, @hookID, newFunc
		table.insert(@hooks, id)

	Think: (ent = @GetEntity()) =>
		return if not @IsValid()
		delta = RealTimeL() - @lastThink
		@lastThink = RealTimeL()
		@lastThinkDelta = delta
		return if not IsValid(ent) or ent\IsDormant()
		for _, seq in ipairs @currentSequencesIterable
			if not seq\IsValid()
				@EndSequence(seq\GetName(), false)
				break
			seq\Think(delta)
		@TriggerLerpAll(delta * 10)
		return delta

	Remove: =>
		seq\Stop() for _, seq in ipairs @currentSequencesIterable
		@isValid = false
		@RemoveHooks()
