# Ledge-Border
#### Hi what does this do: 
Create conditional ledge borders around a player

This is similar to stuff like crouching in Minecraft where it doesn't let you fall off the edge


https://github.com/user-attachments/assets/a4832df4-b81a-49ab-9b66-e2469f4cee5e

https://github.com/user-attachments/assets/41fd238c-1458-43e6-92ba-8c955cf81b13


*these are just examples of what you can do with LedgeBorder! none of the animations or attacking/crouching functions are included

# Methods:

### LedgeBorder.new(plr: Player) 
 
  creates new oop class requiring Player instance, recommended to do this every time local character spawns in with a local script under StarterCharacterScripts

  *NOTE: LedgeBorder.isActive is set to true, so call LedgeBorder:set(false) if you need it initially off

```lua
local LedgeBorder = require(game.ReplicatedStorage.LedgeBorder)
local plr = game.Players.LocalPlayer

local myLedgeBorder = LedgeBorder.new(plr)
--myLedgeBorder:set(false)
```

### LedgeBorder:set(bool: boolean)

  enables/disables LedgeBorder:update() from running whenever it is called

```lua

local isCrouching = false
--myLedgeBorder:set(false) --make sure this is set to false

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
RunService.RenderStepped:Connect(function(deltaTime: number) 
	myLedgeBorder:update()
end)
```



```lua
while true do
	myLedgeBorder:update()
	task.wait()
end
```
  
