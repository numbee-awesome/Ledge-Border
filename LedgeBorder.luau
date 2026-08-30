--local FLOOR_MIDCASTS_AMT = 2 --Amount of raycasts that cast downward to detect the floor along the Frame's midsection.

--local MAX_OFFSET = 6 --Amount of studs the Frame is offset from player.
--local BOTTOM_OFFSET = 1.25 --Max amount of studs blockcast will detect below player.
--local FLOOR_OFFSET = nil --Max amount of studs that floor raycasts will detect, otherwise uses BOTTOM_OFFSET
----local MIN_BOTTOM_OFFSET = .1

--local ANGLE_TOLERANCE = 10 --Subtracts this value from Humanoid's MaxSlopeAngle to determine the max angle that Borders ignore.
--local PLATE_SPEED = .8

local function newBorderPart(tbl, nm)
	local _p = Instance.new("Part")
	_p.Anchored = true
	_p.Size = Vector3.new(1.5,3,.5)
	_p.CollisionGroup = "LedgeBorder"
	_p.Transparency = 1
	_p.Name = nm
	table.insert(tbl, _p)
	
	_p.Parent = workspace.Terrain

	return _p
end

local function getHeight(hum: Humanoid)
	local height = 6 --assumes r6
	
	if hum.RigType == Enum.HumanoidRigType.R15 then 
		local hrp = hum.Parent:WaitForChild("HumanoidRootPart")
		height = ((0.5 * hrp.Size.Y) + hum.HipHeight) * 2
	end
	
	return height
end

local function getAngleY(normal)
	return math.deg(math.acos(normal:Dot(Vector3.yAxis)))
end

local LedgeBorder = {}
LedgeBorder.__index = LedgeBorder

function LedgeBorder.new(plr: Player) 
	local self = setmetatable({}, LedgeBorder)
	
	self._hum = plr.Character.Humanoid
	self._height = getHeight(self._hum)
	self._hrp = plr.Character:WaitForChild("HumanoidRootPart")
	
	for i, v in plr.Character:GetChildren() do
		if v:IsA("BasePart") or v:IsA("MeshPart") and v.CollisionGroup ~= "Characters" then
			v.CollisionGroup = "Characters"
		end
	end
	
	self._ledgeBorders = {}
	
	self._front = newBorderPart(self._ledgeBorders, "front")
	self._back = newBorderPart(self._ledgeBorders, "back")
	
	self._right = newBorderPart(self._ledgeBorders, "right")
	self._left = newBorderPart(self._ledgeBorders, "left")
	
	self._corner1 = newBorderPart(self._ledgeBorders, "c1")
	self._corner2 = newBorderPart(self._ledgeBorders, "c2")
	self._corner3 = newBorderPart(self._ledgeBorders, "c3")
	self._corner4 = newBorderPart(self._ledgeBorders, "c4")
	
	self._params = RaycastParams.new()
	self._params.RespectCanCollide = true
	self._params.CollisionGroup = "Characters"
	self._params.FilterDescendantsInstances = {plr.Character, self._ledgeBorders}
	self._params.FilterType = Enum.RaycastFilterType.Exclude
	
	self.FLOOR_MIDCASTS_AMT = 2 --Amount of raycasts that cast downward to detect the floor along the Frame's midsection.

	self.MAX_OFFSET = 6 --Amount of studs the Frame is offset from player.
	self.BOTTOM_OFFSET = 1.25 --Max amount of studs blockcast will detect below player.
	self.FLOOR_OFFSET = nil --Max amount of studs that floor raycasts will detect, otherwise uses BOTTOM_OFFSET
	--self.MIN_BOTTOM_OFFSET = .1

	self.ANGLE_TOLERANCE = 10 --Subtracts this value from Humanoid's MaxSlopeAngle to determine the max angle that Borders ignore.
	self.PLATE_SPEED = .8
	
	self.isActive = true
	
	return self
end


function LedgeBorder:set(bool: boolean)
	self.isActive = bool
	if self.isActive == false then
		--
		for _, border in self._ledgeBorders do
			--border.Transparency = 1
			border.CanCollide = false
			border.CanQuery = false
			border.CanTouch = false
			
		end
		
	else
		--
		for _, border in self._ledgeBorders do
			--border.Transparency = 0.9
			border.CanCollide = true
			border.CanQuery = true
			border.CanTouch = true
		end
	end
end

function LedgeBorder:castLedge(ledgeFrame: Part, pos: CFrame)
	
	local flrOffset = self.FLOOR_OFFSET or self.BOTTOM_OFFSET
	local maxAngle = self._hum.MaxSlopeAngle - self.ANGLE_TOLERANCE
	local hitFloor = false
	local ledgeLocation = pos
	local _downCastAmt = (ledgeFrame.Size.Y + (self._height - ledgeFrame.Size.Y)/2 + flrOffset)
	
	local flrCheck = workspace:Raycast(pos.Position + pos:vectorToWorldSpace(Vector3.new(0,ledgeFrame.Size.Y/2,ledgeFrame.Size.Z/2)), -ledgeFrame.CFrame.UpVector * _downCastAmt, self._params)
	local flrRight = workspace:Raycast(pos.Position + pos:vectorToWorldSpace(ledgeFrame.Size/2), -ledgeFrame.CFrame.UpVector * _downCastAmt, self._params)
	local flrLeft = workspace:Raycast(pos.Position + pos:vectorToWorldSpace(ledgeFrame.Size/2*Vector3.new(-1,1,1)), -ledgeFrame.CFrame.UpVector * _downCastAmt, self._params)
	
	local floorCasts = {flrCheck, flrLeft, flrRight}
	
	if #floorCasts == 0 then
		local midSections = {}
		local leftPos = pos.Position + pos:vectorToWorldSpace(Vector3.new(-ledgeFrame.Size.X/2,ledgeFrame.Size.Y/2,ledgeFrame.Size.Z/2))
		for i = 1, self.FLOOR_MIDCASTS_AMT do
			local section = i / (self.FLOOR_MIDCASTS_AMT + 1)  -- This will create evenly spaced sections
			local position = leftPos + pos:VectorToWorldSpace(Vector3.new(ledgeFrame.Size.X * section, 0, 0))
			local cast = workspace:Raycast(position,-ledgeFrame.CFrame.UpVector * _downCastAmt, self._params)
			if cast then
				hitFloor = true
				break
			end
		end
	else
		hitFloor = true
	end
	
	if not hitFloor then
		local ledgeCast = workspace:Blockcast(pos + Vector3.new(0, -(self._height/4 + self.BOTTOM_OFFSET), 0), Vector3.new(ledgeFrame.Size.X, self._height/2, ledgeFrame.Size.Z), -ledgeFrame.CFrame.LookVector * self.MAX_OFFSET, self._params)
		
		if ledgeCast and getAngleY(ledgeCast.Normal) > maxAngle then
			local newPos = pos + pos:vectorToWorldSpace(Vector3.new(0,0,ledgeCast.Distance))
			
			ledgeLocation = newPos
		end
	end
	--ledgeFrame.CFrame = ledgeLocation
	ledgeFrame.CFrame = ledgeFrame.CFrame:Lerp(ledgeLocation, self.PLATE_SPEED)
end

function LedgeBorder:update()
	if not self.isActive then
		return
	end
	
	local MAX_OFFSET = self.MAX_OFFSET
	
	local FRONT_POSITION = CFrame.new(self._hrp.Position) + Vector3.new(0,0,-1) * MAX_OFFSET
	
	local RIGHT_POSITION = CFrame.new(self._hrp.Position) * CFrame.Angles(0, -math.pi/2, 0) + Vector3.new(1,0,0) * MAX_OFFSET
	local LEFT_POSITION = CFrame.new(self._hrp.Position) * CFrame.Angles(0, math.pi/2, 0) + Vector3.new(-1,0,0) * MAX_OFFSET
	
	local BACK_POSITION = CFrame.new(self._hrp.Position) * CFrame.Angles(0, math.pi, 0) + Vector3.new(0,0,1) * MAX_OFFSET
	
	local CORNER1_POSITION = CFrame.new(self._hrp.Position) * CFrame.Angles(0, math.pi/4, 0) + Vector3.new(-1,0,-1).Unit * MAX_OFFSET
	local CORNER2_POSITION = CFrame.new(self._hrp.Position) * CFrame.Angles(0, -math.pi/4, 0) + Vector3.new(1,0,-1).Unit * MAX_OFFSET
	local CORNER3_POSITION = CFrame.new(self._hrp.Position) * CFrame.Angles(0, 3*math.pi/4, 0) + Vector3.new(-1,0,1).Unit * MAX_OFFSET
	local CORNER4_POSITION = CFrame.new(self._hrp.Position) * CFrame.Angles(0, -3*math.pi/4, 0) + Vector3.new(1,0,1).Unit * MAX_OFFSET

	self:castLedge(self._front, FRONT_POSITION)
	self:castLedge(self._right, RIGHT_POSITION)
	self:castLedge(self._left, LEFT_POSITION)
	self:castLedge(self._back, BACK_POSITION)
	
	self:castLedge(self._corner1, CORNER1_POSITION)
	self:castLedge(self._corner2, CORNER2_POSITION)
	self:castLedge(self._corner3, CORNER3_POSITION)
	self:castLedge(self._corner4, CORNER4_POSITION)
end

return LedgeBorder