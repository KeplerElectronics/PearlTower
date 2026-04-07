--[[

The MIT License (MIT)

Copyright (c) 2013 Patrick Rabier

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

--
-- LOVE2D ANIMATION
--

--
-- This file will be loaded through love.filesystem.load
-- This file describes the different states and frames of the animation
--

--[[

	Each sprite sheet contains one or multiple states
	Each states is represented as a line in the image file
	The following object describes the different states
	Switching between different states can be done through code

	members ->
		imageSrc : path to the image (png, tga, bmp or jpg)
		defaultState : the first state
		states : a table containing each state

	(State)
	Each state contains the following members ->
		frameCount : the number of frames in the state
		offsetX : starting from the left, the position (in px) of the first frame of the state (aka on the line)
		offsetY : starting from the top, the position of the line (px)
		framwW : the width of each frame in the state
		frameH : the height of each frame in the state
		nextState : the state which will follow after the last frame is reached
		switchDelay : the time between each frame (seconds as floating point)

]]

return {
	imageSrc = "Sprites/PlayerAnim.png",
	defaultState = "idle",
	states = {
		idleRight = {
			frameCount = 4,
			offsetY = 0,
			frameW = 32,
			frameH = 32,
			nextState = "idleRight",
			switchDelay = 0.25
		},
		idleLeft = {
			frameCount = 4,
			offsetY = 0,
			offsetX = 128,
			frameW = 32,
			frameH = 32,
			nextState = "idleLeft",
			switchDelay = 0.25
		},
		idleRightUp = {
			frameCount = 1,
			offsetY = 32,
			frameW = 32,
			frameH = 32,
			nextState = "idleRightUp",
			switchDelay = 0.25
		},
		idleLeftUp = {
			frameCount = 1,
			offsetY = 32,
			offsetX = 128,
			frameW = 32,
			frameH = 32,
			nextState = "idleLeftUp",
			switchDelay = 0.25
		},
		runRight = {
			frameCount = 4,
			offsetY = 64,
			frameW = 32,
			frameH = 32,
			nextState = "runRight",
			switchDelay = 0.1
		},
		runLeft = {
			frameCount = 4,
			offsetY = 96,
			frameW = 32,
			frameH = 32,
			nextState = "runLeft",
			switchDelay = 0.1
		},
		runRightUp = {
			frameCount = 4,
			offsetY = 64,
			offsetX = 128,
			frameW = 32,
			frameH = 32,
			nextState = "runRightUp",
			switchDelay = 0.1
		},
		runLeftUp = {
			frameCount = 4,
			offsetY = 96,
			offsetX = 128,
			frameW = 32,
			frameH = 32,
			nextState = "runLeftUp",
			switchDelay = 0.1
		},
		crouchLeft = {
			frameCount = 8,
			offsetY = 128,
			frameW = 32,
			frameH = 32,
			nextState = "crouchLeft",
			switchDelay = 0.1
		},
		crouchRight = {
			frameCount = 8,
			offsetY = 160,
			frameW = 32,
			frameH = 32,
			nextState = "crouchRight",
			switchDelay = 0.1
		},
		jumpLeft= {
			frameCount = 4,
			offsetY = 192,
			frameW = 32,
			frameH = 32,
			nextState = "jumpLeft",
			switchDelay = 0.3
		},
		jumpRight = {
			frameCount = 4,
			offsetY = 224,
			frameW = 32,
			frameH = 32,
			nextState = "jumpRight",
			switchDelay = 0.3
		},
		sleep = {
			frameCount = 8,
			offsetY = 256,
			frameW = 32,
			frameH = 32,
			nextState = "sleepidle",
			switchDelay = 0.1
		},
		sleepidle = {
			frameCount = 1,
			offsetY = 288,
			frameW = 32,
			frameH = 32,
			nextState = "sleepidle",
			switchDelay = 1
		}
	}
}
