# Ledge-Border
#### Hi what does this do: 
Create conditional ledge borders around a player

This is similar to stuff like crouching in Minecraft where it doesn't let you fall off the edge

# Methods:

### LedgeBorder.new(plr: Player) 
 
  creates new oop class requiring Player instance, recommended to do this every time local character spawns in with a local script under StarterCharacterScripts

```lua
local LedgeBorder = require(game.ReplicatedStorage.LedgeBorder)
local plr = game.Players.LocalPlayer

local myLedgeBorder = LedgeBorder.new(plr)
```

### LedgeBorder:set(bool: boolean)

  enables/disables LedgeBorder:update() from running whenever it is called

```lua

local myLedgeBorder = LedgeBorder.new(game.Players.LocalPlayer)
myLedgeBorder:set(false)
local isCrouching = false

game.UserInputService.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.C then
		isCrouching = if isCrouching then false else true
		myLedgeBorder:set(isCrouching)
	end
end)

```

### LedgeBorder:update()

  hook this up to any sort of loop, runservice, etc. to make the ledge borders update cframe coordinates when LedgeBorder class is enabled


```lua
local RunService = game:GetService("RunService")

local LedgeBorder = require(game.ReplicatedStorage.LedgeBorder)
local myLedgeBorder = LedgeBorder.new(game.Players.LocalPlayer)


RunService.RenderStepped:Connect(function(deltaTime: number) 
	myLedgeBorder:update(deltaTime)
end)
```



```lua
local LedgeBorder = require(game.ReplicatedStorage.LedgeBorder)
local myLedgeBorder = LedgeBorder.new(game.Players.LocalPlayer)

while true do
 myLedgeBorder:update()
 task.wait()
end
```
  
