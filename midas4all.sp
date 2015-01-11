#include <sourcemod>
#pragma semicolon 1
#define PL_VERSION "0.3"

new Handle:cvar_enabled;
new Handle:cvar_admins;
new Handle:cvar_flag;
new Handle:cvar_midas4all;
new Handle:cvar_ragdolltype;

new bool:clientHasMidas[MAXPLAYERS+1];
new ragdollType;

public Plugin:myinfo = 
{
	name = "midas4all",
	author = "Felis, Spirrwell",
	description = "fun with ragdolls",
	version = PL_VERSION,
	url = "loli.dance"
}

public OnPluginStart()
{
	cvar_enabled = CreateConVar("sm_midas4all_enabled", "1", "Enable midas4all.");
	cvar_admins = CreateConVar("sm_midas4all_admins", "1", "Admins get the midas touch.");
	cvar_flag = CreateConVar("sm_midas4all_flag", "b", "Admin flag required for midas.");
	cvar_midas4all = CreateConVar("sm_midas4all_everyone", "0", "midas4ALL");
	cvar_ragdolltype = CreateConVar("sm_midas4all_ragdolltype", "6", "Ragdoll type, see readme for more info. 6 is default (midas)");
	
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", OnPlayerDeath);
	
	HookConVarChange(cvar_enabled, cvHookEnabled);
	HookConVarChange(cvar_ragdolltype, cvHookRagdollType);
	
	AutoExecConfig(true, "midas4all");
	
	Reset();
}

public cvHookEnabled(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (StrEqual(newVal, "0", false))
	{
		Reset();
	}
}

public cvHookRagdollType(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new val = StringToInt(newVal, 10);
	if (val >= 12)
	{
		LogAction(-1, -1, "Ragdoll type 12+ will crash clients! Reverting to default.");
		ragdollType = 6;
		SetConVarInt(cvar_ragdolltype, 6, false, false); 
	}
	else
	{
		ragdollType = val;
	}
}

public OnMapStart()
{
	Reset();
}

public OnClientConnected(client)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	GiveMidas(client);
}

public OnClientDisconnect(client)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	clientHasMidas[client] = false;
}

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	GiveMidas(client);
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	new attackerId = GetEventInt(event, "attacker");
	new attacker = GetClientOfUserId(attackerId);
	
	new victimId = GetEventInt(event, "userid");
	new victim = GetClientOfUserId(victimId);
	
	if (clientHasMidas[attacker])
	{
		new ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
		
		if (ragdoll < 0)
		{
			ThrowError("Couldn't get the player's ragdoll.");
			return;
		}
		
		SetEntProp(ragdoll, Prop_Send, "m_iDismemberment", ragdollType);
	}
}

public bool:CheckAdminFlag(client)
{
	if (GetUserFlagBits(client) == 0)
		return false;
	
	decl String:strflag[8];
	GetConVarString(cvar_flag, strflag, 8);
	
	new flag = ReadFlagString(strflag);
	if (GetUserFlagBits(client) >= flag)
		return true;
	else
	return false;
}

public GiveMidas(client)
{
	if (GetConVarBool(cvar_admins))
	{
		if (CheckAdminFlag(client))
		{
			clientHasMidas[client] = true;
		}
		else
		{
			clientHasMidas[client] = false;
		}
	}
	else if (GetConVarBool(cvar_midas4all))
	{
		clientHasMidas[client] = true;
	}
	else
	{
		clientHasMidas[client] = false;
	}
}

public Reset()
{
	for (new i = 1; i < MaxClients; i++)
	{
		clientHasMidas[i] = false;
	}
	ragdollType = 6;
}