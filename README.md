# Warlock Healthstone Tracker
Track healthstones traded to other players and their consumption.

***See the [companion addon](https://www.curseforge.com/wow/addons/warlock-healthstone-tracker-blizzui) that shows healthstones using Blizzard party and raid frames.***


## Features
* Show simple list of players that need a healthstone
* Track healthstones created, traded, and consumed
* Exposes simple callback plugin interface for other addons to display healthstone tracking.


## Known Issues
* [#1] - Reset to Defaults doesn't work the second time
* [#2] - List view remains locked after Reset to Defaults
* [#4] - List view showed party member "Unknown" *fixed in v1.0.1-beta*
* [#5] - No-lib zip still includes libraries *fixed in v1.0.1-beta*
* [#6] - Healthstones are not being tracked upon create *fixed in v1.0.1-beta*

[#1]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/1
[#2]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/2
[#4]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/4
[#5]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/5
[#6]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/6


## Future improvements
* Track offline players and automatically remove their healthstones after 15 minutes.
* Address ephemeral caching limitation


## Limitations
* **Healthstone consumption is based on combat log** - If you are in a different zone, corpse running, or simply too far away the addon will not see the healthstone was consumed.
* **Local cache** - The cache of player healthstones is not saved across game sessions and will be lost upon logout and `/reload`
