# Warlock Healthstone Tracker
Track healthstones traded to other players and their consumption.

***See the [companion addon](https://www.curseforge.com/wow/addons/warlock-healthstone-tracker-blizzui) that shows healthstones using Blizzard party and raid frames.***


## Features
* Track healthstones created, traded, and consumed
* Show simple list of players that need a healthstone
* Filter list view by role select and/or class
* Sync healthstone status among party / raid members
* Exposes simple callback plugin interface for other addons to display healthstone tracking.


## Known Issues
* [#5] - No-lib zip still includes libraries

[#5]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/5


## Future improvements
* [#11] - Track offline players and automatically remove their healthstones after 15 minutes.
* [#13] - Clicking a name in List View should target the player

[#11]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/11
[#13]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/13


## Limitations
* **Healthstone consumption is based on combat log** - If you are in a different zone, corpse running, or simply too far away the addon will not see the healthstone was consumed.
