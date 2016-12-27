#include <sourcemod>

#pragma semicolon 1

#define PL_VERSION "0.7"
#define MAX_RAGDOLLTYPES 12
#define DEFAULT_RAGDOLLTYPE 6

new Handle:cvar_enabled;
new Handle:cvar_keyvalues;
new Handle:cvar_admins;
new Handle:cvar_flag;
new Handle:cvar_midas4all;
new Handle:cvar_ragdolltype;

new bool:clientHasRagdoll[MAXPLAYERS+1];
new clientRagdollType[MAXPLAYERS+1];

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
	cvar_keyvalues = CreateConVar("sm_ragdollfun_keyvalues", "0", "Use KeyValues to get a ragdoll type for each player. This will ignore all other cvars!");
	cvar_admins = CreateConVar("sm_ragdollfun_admins", "1", "Admins get the ragdoll effects.");
	cvar_flag = CreateConVar("sm_ragdollfun_flag", "b", "Admin flag required for ragdoll effects.");
	cvar_midas4all = CreateConVar("sm_ragdollfun_everyone", "0", "midas4all");
	cvar_ragdolltype = CreateConVar("sm_ragdollfun_ragdolltype", "6", "Ragdoll type, see readme for more info. 6 is default (midas)");
	
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", OnPlayerDeath);
	
	HookConVarChange(cvar_enabled, cvHookEnabled);
	HookConVarChange(cvar_keyvalues, cvHookKeyValues);
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

public cvHookKeyValues(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	for (new i = 1; i < MaxClients; i++)
	{
		GiveRagdoll(i);
	}
}

public cvHookRagdollType(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new val = StringToInt(newVal, 10);
	if (val >= MAX_RAGDOLLTYPES)
	{
		LogAction(-1, -1, "Ragdoll type over the max amount, this would crash the clients. Reverting to default.");
		
		for (new i = 1; i < MaxClients; i++)
			clientRagdollType[i] = DEFAULT_RAGDOLLTYPE;
		
		SetConVarInt(cvar_ragdolltype, DEFAULT_RAGDOLLTYPE, false, false); 
	}
	else
	{
		for (new i = 1; i < MaxClients; i++)
			clientRagdollType[i] = val;
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
	
	GiveRagdoll(client);
}

public OnClientDisconnect(client)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	clientHasRagdoll[client] = false;
	clientRagdollType[client] = DEFAULT_RAGDOLLTYPE;
}

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	GiveRagdoll(client);
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	new attackerId = GetEventInt(event, "attacker");
	new attacker = GetClientOfUserId(attackerId);
	
	new victimId = GetEventInt(event, "userid");
	new victim = GetClientOfUserId(victimId);
	
	if (clientHasRagdoll[attacker] && clientRagdollType[attacker] < MAX_RAGDOLLTYPES)
	{
		new ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
		
		if (ragdoll == -1)
		{
			ThrowError("Couldn't get the player's ragdoll.");
			return;
		}
		
		SetEntProp(ragdoll, Prop_Send, "m_iDismemberment", clientRagdollType[attacker]);
	}
}

public GetRagdollTypeForSteamID(const String:steamid[])
{
	new Handle:kv = CreateKeyValues("RagdollFun");
	decl String:path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/ragdollfun.txt");
	FileToKeyValues(kv, path);
	
	if (!KvJumpToKey(kv, steamid))
		return -1;
	
	new type = KvGetNum(kv, "type");
	CloseHandle(kv);
	return type;
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

public GiveRagdoll(client)
{
	if (!IsClientInGame(client))
		return;
	
	if (GetConVarBool(cvar_keyvalues))
	{
		decl String:steamID[64];
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
		new type = GetRagdollTypeForSteamID(steamID);
		
		if (type != -1 && type < MAX_RAGDOLLTYPES)
		{
			clientHasRagdoll[client] = true;
			clientRagdollType[client] = type;
		}
	}
	else
	{
		clientRagdollType[client] = GetConVarInt(cvar_ragdolltype);
		
		if (GetConVarBool(cvar_midas4all))
		{
			clientHasRagdoll[client] = true;
		}
		else if (GetConVarBool(cvar_admins))
		{
			if (CheckAdminFlag(client))
			{
				clientHasRagdoll[client] = true;
			}
			else
			{
				clientHasRagdoll[client] = false;
			}
		}
		else
		{
			clientHasRagdoll[client] = false;
		}
	}
}

public Reset()
{
	for (new i = 1; i < MaxClients; i++)
	{
		clientHasRagdoll[i] = false;
		clientRagdollType[i] = DEFAULT_RAGDOLLTYPE;
	}
}
