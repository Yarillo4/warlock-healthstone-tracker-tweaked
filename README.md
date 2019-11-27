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
* [#1] - Reset to Defaults doesn't work the second time *fixed in 1.0.4-beta*
* [#2] - List view remains locked after Reset to Defaults *fixed in 1.0.4-beta*
* [#5] - No-lib zip still includes libraries
* [#17] - Hidden dependencies on AceGUI-3.0 and AceConfigDialog-3.0 *fixed in 1.0.4-alpha2*
* [#19] - Disabling then Enabling List view shows out of date information *fixed in 1.0.4-beta3*
* [#20] - List view not visible after resetting defaults when List view was disabled *fixed in 1.0.4-alpha4*

[#1]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/1
[#2]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/2
[#5]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/5
[#17]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/17
[#19]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/19
[#20]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/20


## Future improvements
* [#11] - Track offline players and automatically remove their healthstones after 15 minutes.
* [#12] - Implement cache syncing among party / raid members *added in 1.0.4-beta*
* [#13] - Clicking a name in List View should target the player
* [#18] - Update configuration cache when a player eats a healthstone and group changed *added in 1.0.4-alpha2*

[#11]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/11
[#12]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/12
[#13]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/13
[#18]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/18


## Limitations
* **Healthstone consumption is based on combat log** - If you are in a different zone, corpse running, or simply too far away the addon will not see the healthstone was consumed.
