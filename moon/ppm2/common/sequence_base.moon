
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


class PPM2.SequenceBase
	new: (parent, data) =>
		{
			'name': @name
			'repeat': @dorepeat
			'frames': @frames
			'time': @time
			'func': @func
			'reset': @resetfunc
			'create': @createfunc
		} = data

		@valid = false
		@paused = false
		@pausedSequences = {}
		@deltaAnim = 1
		@speed = 1
		@scale = 1
		@frame = 0
		@start = CurTimeL()
		@finish = @start + @time
		@parent = parent

	GetEntity: => @parent\GetEntity()
	Launch: =>
		@valid = true
		@createfunc() if @createfunc
		@resetfunc() if @resetfunc

	__tostring: => "[#{@@__name}:#{@name}]"

	SetTime: (newTime = @time, refresh = true) =>
		@frame = 0
		@start = CurTimeL() if refresh
		@time = newTime
		@finish = @start + @time

	SetInfinite: (val) => @dorepeat = val
	SetIsInfinite: (val) => @dorepeat = val
	GetInfinite: => @dorepeat
	GetIsInfinite: => @dorepeat

	Reset: =>
		@frame = 0
		@start = CurTimeL()
		@finish = @start + @time
		@deltaAnim = 1
		@resetfunc() if @resetfunc

	GetName: => @name
	GetRepeat: => @dorepeat
	GetFrames: => @frames
	GetFrame: => @frames
	GetTime: => @time
	GetThinkFunc: => @func
	GetCreatFunc: => @createfunc
	GetSpeed: => @speed
	GetAnimationSpeed: => @speed
	GetScale: => @scale
	IsValid: => @valid

	Think: (delta = 0) =>
		if @paused
			@finish += delta
			@start += delta
		else
			if @HasFinished()
				@Stop()
				return false

			@deltaAnim = (@finish - CurTimeL()) / @time
			if @deltaAnim < 0
				@deltaAnim = 1
				@frame = 0
				@start = CurTimeL()
				@finish = @start + @time
			@frame += 1

			if @func
				status = @func(delta, 1 - @deltaAnim)
				if status == false
					@Stop()
					return false

		return true

	Pause: =>
		return false if @paused
		@paused = true
		return true

	Resume: =>
		return false if not @paused
		@paused = false
		return true

	PauseSequence: (id = '') =>
		@pausedSequences[id] = true
		@parent\PauseSequence(id) if @parent

	ResumeSequence: (id = '') =>
		@pausedSequences[id] = false
		@parent\ResumeSequence(id) if @parent

	Stop: =>
		for id, bool in pairs @pausedSequences
			@controller\ResumeSequence(id) if bool
		@valid = false

	Remove: => @Stop()

	HasFinished: =>
		return false if @dorepeat
		return CurTimeL() > @finish
