![https://i.imgur.com/aJzMNYV.png](https://i.imgur.com/aJzMNYV.png)


#### ***True Darkness*** attempts to bring Baldur’s Gate 3 one step closer to an authentic D&D experience by implementing the spell as close to 5e "Rules As Written" as technically possible and introducing a comprehensive rework of sight.

### Requires [Norbyte's Script Extender](https://github.com/Norbyte/bg3se/releases)

### Nexus: https://www.nexusmods.com/baldursgate3/mods/13542

![https://i.imgur.com/69Lh9Dc.png](https://i.imgur.com/69Lh9Dc.png)
> *Magical darkness spreads from a point you choose within range to fill a 15-foot radius sphere for the duration. The darkness spreads around corners. A creature with darkvision can’t see through this darkness, and nonmagical light can’t illuminate it.*

Darkness is no longer a cloud that can be moved by wind and is instead spreading from a point you choose to fill a sphere just like in 5e. You can choose anything to be that point, including a wall to cover multiple stories, which allows for much more tactical thinking.

All creatures inside the sphere are heavily obscured and blinded, unless they posses an ability to see in magical darkness such as Devil's Sight, Truesight, or Blind Fighting. The mod calculates how far a creature can see with their ability according to the rules, applies advantages and disadvantages correctly, and forbids creatures without those abilities to cast spells that require sight when the target is inside the sphere. Those include both the spells that target creatures like Hold Person or Healing Word and spells that target a point in space like Misty Step or Call Lightning.

Additionally, the duration of Darkness has been increased to 10 minutes.

**Discrepancies**:
* *The spell fills a 17ft radius sphere due to a game limitation. It uses metric system and only allows whole numbers in this case (15ft is ~4.6m).*
* *The sphere not only spreads around corners, but also through walls, as it's not a complex physical simulation that can be blocked by them.*

> *If the point you choose is on an object you are holding or one that isn't being worn or carried, the darkness emanates from the object and moves with it. Completely covering the source of the darkness with an opaque object, such as a bowl or a helm, blocks the darkness.*

Darkness can be cast on a weapon you're holding or any self-standing item, and will move together with them at all times while the spell lasts, unless it's fully covered by being in an inventory or any other container. Sheathing a weapon by switching between melee and ranged doesn't count as covering it.

From there on, you're free to do whatever you want with the item like throw around Scratch's Ball that had Darkness cast on it, allowing to reposition it at will or, more traditionally, cast it on your weapon as a warlock with Devil's Sight and give yourself guaranteed advantage on attacks.

> *If any of this spell’s area overlaps with an area of light created by a spell of 2nd level or lower, the spell that created the light is dispelled.*

When Darkness overlaps any magical light of 2nd level or below like Faerie Fire, Light cantrip, or Continual Flame from 5e spells, that light is dispelled. Additionally, Darkness is dispelled by Daylight.

**Discrepancies***:
*
* Magical light above 2nd level can't illuminate Darkness.
* At the moment, Darkness dispels light if its base level is 2nd or below regardless of the actual casting level.

> ***Arrow of Darkness**
When loosed from a bow, this arrow casts darkness on itself. The darkness lasts for 10 minutes. ([reference](https://www.5esrd.com/database/magicitem/arrow-of-darkness/))*

When Arrow of Darkness hits its target, a sphere of Darkness will spread from the arrow as if the spell was cast on it. The arrow can be picked up, stowed, and thrown as a regular item. Destroying the arrow stops the spell.

![https://i.imgur.com/WR8JdDY.png](https://i.imgur.com/WR8JdDY.png)

In order for the new Darkness to work correctly, some other changes and additions were necessary, which were extended to the rest of the game.

### Blinded
Limited range for spells and ranged attacks has been removed. Instead, the mod forbids using spells that require sight when blinded, including when targeting yourself.

### Heavily Obscured
Introduced a new status that's applied when a creature is inside a thick cloud or fog created by a spell. Baldur's Gate 3 simply marks the area as darkness, for example inside Hunger of Hadar, which means that a creature standing close to it would be able to see creatures inside, creating advantage.

### Blinded & Heavily Obscured
While heavily obscured, you have advantage on your attacks due to being unseen, but disadvantage due to being blinded. The opposite is true when attacking a heavily obscured creature from outside the area. Either way, you only roll one die, unless one of the creatures has Blindsight or a similar ability.

### Hunger of Hadar
Devil's Sight does not grant an ability to see inside HoH, as it creates a sphere of ***blackness***, and not magical darkness.

### Clouds
Fog Cloud, Stinking Cloud, and Cloudkill now apply both Blinded and Heavily Obscured conditions. Also fixed Cloudkill dealing damage multiple times per turn while I was at it.

### Sleet Storm
Similarly, Sleet Storm now applies both Blinded and Heavily obscured conditions. To simulate it better, a fog cloud also appears inside of it.

![https://i.imgur.com/WdmiSTI.png](https://i.imgur.com/WdmiSTI.png)

### REQUIREMENTS
### [Norbyte's Script Extender](https://github.com/Norbyte/bg3se/releases)

### INSTALLATION
### [LaughingLeader's Mod Manager](https://github.com/LaughingLeader/BG3ModManager/releases)

### SUPPORT & RECOMMENDATIONS
* [Zerd's Rules As Written (RAW)](https://www.nexusmods.com/baldursgate3/mods/1329) - The mods complement each other and ***True Darkness*** was, generally, made to be used together with RAW.
* [5e Spells](https://www.nexusmods.com/baldursgate3/mods/125) - All the spells introduced by the mod that require sight work correctly.
* [Combat Extender](https://www.nexusmods.com/baldursgate3/mods/5207) - New Darkness spells support correct AI casting (*Target_Darkness* for container, *Target_Darkness_Object*, and *Target_Darkness_Point*).
* Mods that introduce Blind Fighting should all function correctly, regardless of the mod's implementation.

### COMPATIBILITY
As the intention of ***True Darkness*** is to bring Baldur's Gate 3 closer to the 5e ruleset, it has been tested with other mods that share this goal and shouldn't conflict with any of them.

For any other mods, the most likely incompatibilities are cloud spells, since they change surfaces. If you'd like to make sure that the changes introduced by ***True Darkness*** are working as intended, place the mod close to the bottom of your load order. Whichever mod is lower determines which version is used.

Feel free to let me know if you find a mod that you think should be made compatible and isn't.

![https://i.imgur.com/Xi8Lz8d.png](https://i.imgur.com/Xi8Lz8d.png)

[jjdoorframe](https://next.nexusmods.com/profile/jjdoorframe) - Implementation, VFX, the whole thing

[Zerd](https://next.nexusmods.com/profile/ZerdLR) - Original method of adding target conditions for spells, general inspiration for making it RAW
