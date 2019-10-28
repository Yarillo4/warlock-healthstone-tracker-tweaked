# Warlock Healthstone Tracker


## Features
* Show healthstone icon next to party members when player has healthstone [Blizzard default UI]
* Hide healthstone icon upon consumption


## Future improvements
* Show healthstone icon next to raid members
* Track healthstone creation
* Track offline players and automatically remove their healthstones after 15 minutes.
* Automatically remove players we haven't had contact with in 15 minutes.


## Limitations
* **Healthstone consumption is based on combat log** - If you are in a different zone, corpse running, or simply too far away the addon will not see the healthstone was consumed.
* **Local cache** - The cache of player healthstones is not saved across game sessions and will be lost upon logout and `/reload`
