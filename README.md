# Ledge-Border
#### Hi what does this do: 
Create conditional ledge borders around a player

This is similar to stuff like crouching in Minecraft where it doesn't let you fall off the edge

# Methods:

### LedgeBorder.new(plr: Player) 
 
  creates new oop class requiring Player instance, recommended to do this every time local character spawns in with a local script under StarterCharacterScripts

### LedgeBorder:set(bool: boolean)

  enables/disables LedgeBorder:update() from running whenever it is called

### LedgeBorder:castLedge(ledgeFrame: Part, pos: CFrame)

  internal method for LedgeBorder class to modify its own ledgeFrames

### LedgeBorder:update()

  hook this up to any sort of loop, runservice, etc. to make the ledge borders update cframe coordinates when LedgeBorder class is enabled
  
