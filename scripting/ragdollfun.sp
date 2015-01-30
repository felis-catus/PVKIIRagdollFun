#include <sourcemod>
#pragma semicolon 1
#define PL_VERSION "0.4"

new Handle:cvar_enabled;
new Handle:cvar_admins;
new Handle:cvar_flag;
new Handle:cvar_midas4all;
new Handle:cvar_ragdolltype;

new bool:clientHasMidas[MAXPLAYERS+1];
new ragdollType;

public Plugin:myinfo = 
{
	name = "RagdollFun",
	author = "Felis, Spirrwell",
	description = "fun with ragdolls",
	version = PL_VERSION,
	url = "loli.dance"
}

public OnPluginStart()
{
	cvar_enabled = CreateConVar("sm_ragdollfun_enabled", "1", "Enable RagdollFun.");
	cvar_admins = CreateConVar("sm_ragdollfun_admins", "1", "Admins get the ragdoll effects.");
	cvar_flag = CreateConVar("sm_ragdollfun_flag", "b", "Admin flag required for ragdoll effects.");
	cvar_midas4all = CreateConVar("sm_ragdollfun_everyone", "0", "midas4all");
	cvar_ragdolltype = CreateConVar("sm_ragdollfun_ragdolltype", "6", "Ragdoll type, see readme for more info. 6 is default (midas)");
	
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", OnPlayerDeath);
	
	HookConVarChange(cvar_enabled, cvHookEnabled);
	HookConVarChange(cvar_ragdolltype, cvHookRagdollType);
	
	AutoExecConfig(true, "ragdollfun");
	
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
		LogAction(-1, -1, "Ragdoll type 12+ will crash the clients! Reverting to default.");
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
		
		if (ragdollType < 12)
		{
			SetEntProp(ragdoll, Prop_Send, "m_iDismemberment", ragdollType);
		}
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
	if (GetConVarBool(cvar_midas4all))
	{
		clientHasMidas[client] = true;
	}
	else if (GetConVarBool(cvar_admins))
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
