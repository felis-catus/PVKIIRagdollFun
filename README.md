RagdollFun
=========

Originally named "midas4all", this simple plugin gives you ability to use ragdoll effects on player deaths. You can set different ragdolls for each player, or use a single type for all admins/players.

Special thanks to Spirrwell for finding out how to do this.

Download
-------
https://github.com/felis-catus/PVKIIRagdollFun/releases/download/v1.0/RagdollFun.zip

Installation
-------
- Extract to ../pvkii/addons/sourcemod. Done!

CVARs
-------
```
// Admins get the ragdoll effects.
// -
// Default: "1"
sm_ragdollfun_admins "1"

// Enable RagdollFun.
// -
// Default: "1"
sm_ragdollfun_enabled "1"

// Everyone gets ragdoll effects.
// -
// Default: "0"
sm_ragdollfun_everyone "0"

// Admin flag required for ragdoll effects.
// -
// Default: "b"
sm_ragdollfun_flag "b"

// Use KeyValues to get a ragdoll type for each player. This will ignore all other cvars!
// -
// Default: "0"
sm_ragdollfun_keyvalues "0"

// Ragdoll type, see readme for more info. 6 is default (midas)
// -
// Default: "6"
sm_ragdollfun_ragdolltype "6"
```

Ragdoll Types
-------
NOTE: Dismemberment only works on Berserker.

- 1: Dismemberment head
- 2: Dismemberment left arm
- 3: Dismemberment right arm
- 4: Implode (won't work yet)
- 5: Frozen ragdoll
- 6: Midas touch (default)
- 7: Electric
- 8: Electric Dissolve
- 9: Burnt ragdoll (broken)
- 10: Static ragdoll (PVK2_DEATH_STONE)
- 11: Ghost death

How to set ragdoll types for each player
-------
Important: You need to set sm_ragdollfun_keyvalues to 1 to make this work.

Go to ../addons/sourcemod/configs and open the file "ragdollfun.txt", from there you can set ragdoll types for each SteamID.

Example:
```
"STEAM_0:1:47279666"
{
	"type"  "6"
}

// You can also use Steam3 IDs
"[U:1:94559333]"
{
	"type"  "6"
}
```

