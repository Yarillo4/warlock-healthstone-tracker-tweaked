# Warlock Healthstone Tracker
Track healthstones traded to other players and their consumption.


## Features
* Show healthstone icon next to party unit frames when player has healthstone [Blizzard default UI]
* Hide healthstone icon upon consumption


## Future improvements
* Show healthstone icon next to raid unit frames
* Track healthstone creation
* Track offline players and automatically remove their healthstones after 15 minutes.
* Address ephemeral caching limitation


## Limitations
* **Healthstone consumption is based on combat log** - If you are in a different zone, corpse running, or simply too far away the addon will not see the healthstone was consumed.
* **Local cache** - The cache of player healthstones is not saved across game sessions and will be lost upon logout and `/reload`
