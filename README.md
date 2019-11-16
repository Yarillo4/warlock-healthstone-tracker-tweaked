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
* [#5] - No-lib zip still includes libraries
* [#14] - List view names overflow the borders *(fixed in 1.0.2-beta2)*

[#1]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/1
[#2]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/2
[#5]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/5
[#14]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/14


## Future improvements
* [#11] - Track offline players and automatically remove their healthstones after 15 minutes.
* [#10] - Address ephemeral caching limitation *(fixed in 1.0.2.beta)*
* [#12] - Implement cache syncing among party / raid members
* [#13] - Clicking a name in List View should target the player

[#10]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/10
[#11]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/11
[#12]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/12
[#13]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/13

## Limitations
* **Healthstone consumption is based on combat log** - If you are in a different zone, corpse running, or simply too far away the addon will not see the healthstone was consumed.
* **Local cache** - The cache of player healthstones is not saved across game sessions and will be lost upon logout and `/reload`
