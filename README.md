# Warlock Healthstone Tracker
Track healthstones traded to other players and their consumption.

***See the [companion addon](https://www.curseforge.com/wow/addons/warlock-healthstone-tracker-blizzui) that shows healthstones using Blizzard party and raid frames.***


## Features
* Show simple list of players that need a healthstone
* Exposes simple callback plugin interface for enhancing display of healthstone tracking.


## Future improvements
* Track offline players and automatically remove their healthstones after 15 minutes.
* Address ephemeral caching limitation


## Limitations
* **Healthstone consumption is based on combat log** - If you are in a different zone, corpse running, or simply too far away the addon will not see the healthstone was consumed.
* **Local cache** - The cache of player healthstones is not saved across game sessions and will be lost upon logout and `/reload`
