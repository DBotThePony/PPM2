
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http\//www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

class PonyDataInstance extends PPM2.NetworkedObject
	@MAX_WEIGHT = 1.3
	@MIN_WEIGHT = 0.7
	@Setup()
	@NetworkVar('Weight', (-> math.Clamp(net.ReadFloat(), @MIN_WEIGHT, @MAX_WEIGHT)))

	new: (data) =>
		@SetupData(data) if data
	
	SetupData: (data) =>


class PonyDataController
	new: (ply = NULL, instance) =>
