## v1.2.6 - 2020-07-30
#### Changed
* Updated TOC version 11305

---

## v1.2.6-beta - 2020-07-30
#### Changed
* Updated TOC version 11305

---

## v1.2.6-alpha - 2020-07-29
#### Changed
* Updated TOC version 11305

---

## v1.2.5 - 2020-03-10
#### Changed
* Updated TOC version 11304

---

## v1.2.5-beta - 2020-03-10
#### Changed
* Updated TOC version 11304

---

## v1.2.5-alpha - 2020-03-10
#### Changed
* Updated TOC version 11304

---

## v1.2.4 - 2020-01-18
#### Fixed
* [#22] - Raid sync not functioning
* Nil issue on trade
#### Changed
* Distributed cache is always enabled
#### Known Issues
* [#5] - No-lib zip still includes libraries

---

## v1.2.1 - 2019-12-14
#### Added
* [#13] - Clicking a name in List View now targets the player
#### Fixed
* [#21] - ListView attempted to call protected function during combat lockdown
* Additional temporary secure frame status of List view while in combat
#### Changed
* Update for 1.13.03 game version
#### Known Issues
* [#5] - No-lib zip still includes libraries

---

## v1.1.0 - 2019-11-29
#### Added
* [#12] - Implement cache syncing among party / raid members
* [#16] - Cache override configuration pane should color player names to their class
* [#18] - Update configuration cache when a player eats a healthstone and group changed
#### Fixed
* [#1] - Reset to Defaults doesn't work the second time
* [#2] - List view remains locked after Reset to Defaults
* [#17] - Hidden dependencies on AceGUI-3.0 and AceConfigDialog-3.0
* [#19] - Disabling then Enabling List view shows out of date information
* [#20] - List view not visible after resetting defaults when List view was disabled
#### Changed
* List view now shows player class color
* Cache override configuration now has a single section used for both party and raids
* Upon zoning in search your bags for healthstones
* Refactored debugging, removing the option on release versions
#### Known Issues
* [#5] - No-lib zip still includes libraries

---

## v1.0.3 - 2019-11-21
#### Added
* [#15] - List view raid filters
#### Known Issues
* [#1] - Reset to Defaults doesn't work the second time
* [#2] - List view remains locked after Reset to Defaults
* [#5] - No-lib zip still includes libraries
* [#19] - Disabling then Enabling List view shows out of date information
* [#20] - List view not visible after resetting defaults when List view was disabled

---

## v1.0.2 - 2019-11-17
#### Added
* [#10] - Address ephemeral caching limitation
#### Fixed
* [#14] - List view names overflow the borders
#### Known Issues
* [#1] - Reset to Defaults doesn't work the second time
* [#2] - List view remains locked after Reset to Defaults
* [#5] - No-lib zip still includes libraries
* [#19] - Disabling then Enabling List view shows out of date information
* [#20] - List view not visible after resetting defaults when List view was disabled

---

## v1.0.1 - 2019-11-14
#### Fixed
* [#4] - List view showed party member "Unknown"
* [#6] - Healthstones are not being tracked upon create
* [#7] - List view may show player names more than once
* [#8] - Healthstones traded away are not removed from trade source
#### Known Issues
* [#1] - Reset to Defaults doesn't work the second time
* [#2] - List view remains locked after Reset to Defaults
* [#5] - No-lib zip still includes libraries
* [#14] - List view names overflow the borders
* [#19] - Disabling then Enabling List view shows out of date information
* [#20] - List view not visible after resetting defaults when List view was disabled

---

## v1.0.0 - 2019-11-04
#### Added
* Track healthstone consumption
* Track healthstone traded
* Track healthstone creation
* Show simple list of players that need a healthstone
* Expose simple callback plugin interface for other addons to display healthstone tracking.
#### Fixed
* [#3] - List View not locked upon /reload
#### Known Issues
* [#1] - Reset to Defaults doesn't work the second time
* [#2] - List view remains locked after Reset to Defaults
* [#4] - List view showed party member "Unknown"
* [#5] - No-lib zip still includes libraries
* [#6] - Healthstones are not being tracked upon create
* [#7] - List view may show player names more than once
* [#8] - Healthstones traded away are not removed from trade source
* [#14] - List view names overflow the borders
* [#19] - Disabling then Enabling List view shows out of date information
* [#20] - List view not visible after resetting defaults when List view was disabled

[#1]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/1
[#2]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/2
[#3]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/3
[#4]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/4
[#5]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/5
[#6]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/6
[#7]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/7
[#8]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/8
[#10]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/10
[#12]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/12
[#13]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/13
[#14]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/14
[#15]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/15
[#16]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/16
[#17]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/17
[#18]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/18
[#19]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/19
[#20]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/20
[#21]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/21
[#22]: https://www.curseforge.com/wow/addons/warlock-healthstone-tracker/issues/22
