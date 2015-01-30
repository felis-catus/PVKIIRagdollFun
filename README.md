PVKIIRagdollFun (midas4all)
=========

With this simple plugin, when a player is killed by admin the ragdoll will turn into gold, electric or even ghostly!

Special thanks to Spirrwell for finding out how to do this.

Installation
-------
- Move midas4all.smx to ../addons/sourcemod/plugins. Done!

CVARs
-------
```
// Admins get the midas touch.
// -
// Default: "1"
sm_midas4all_admins "1"

// Enable midas4all.
// -
// Default: "1"
sm_midas4all_enabled "1"

// midas4ALL
// -
// Default: "0"
sm_midas4all_everyone "0"

// Admin flag required for midas.
// -
// Default: "b"
sm_midas4all_flag "b"

// Ragdoll type, see readme for more info. 6 is default (midas)
// -
// Default: "6"
sm_midas4all_ragdolltype "6"
```

Ragdoll Types
-------
NOTE: Dismemberment only works on Berserker.

- 1: Dismemberment head
- 2: Dismemberment left arm
- 3: Dismemberment right arm
- 4: ? (normal ragdoll)
- 5: Frozen ragdoll
- 6: Midas touch (default)
- 7: Electric
- 8: Electric Dissolve
- 9: Burnt ragdoll (broken)
- 10: Static ragdoll (PVK2_DEATH_STONE)
- 11: Ghost death (lts_gravedanger)

12+ crashes the client.
