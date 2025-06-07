/*
            » Release : valqorr's Death-Match System
			» Credits: -
																			  */

//===================================[INCLUDE]==================================

#include a_samp
#include sscanf2
#include zcmd
#include menu

//====================================[MACRO]===================================

static stock
	g_szBuffer[4096]
;

#define formatEx(%0,%1) \
	(format(g_szBuffer, sizeof(g_szBuffer), %0, %1), g_szBuffer)

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define Function%0(%1) \
	%0(%1); public %0(%1)

#define ALPHA (1)
#define BRAVO (2)

//==================================[VARIABLE]==================================

enum PlayerFlags(<<= 1) {
	e_Loggedin = 0b1,
	e_IsSpawned,
	e_Screen,
	buyWeap,
	flashGang,
	connectPlayer
};

static
	PlayerFlags: g_Flags[MAX_PLAYERS]
;

enum GameFlags(<<= 1) {
	i_Start = 0b1,
	AlphaExist,
	BravoExist,
	TeamBuying
};

enum PlayerData {
	e_iTeam,
	iTimer,
	iTimer2,
	gMinute,
	gSeconds
};

enum GameInfo {
	Text: g_Box,
	Text: g_Info,
	Text: g_cP,
	Text: g_scoreTable,
	TeamScore[2],
	TeamCount[2],
 	iDown,
 	gangZone[2]
};

enum CheckpointState {
	g_NULL,
	g_GIVE,
	g_GIVEBACK
};


static
 	GameFlags: ae_Flags,
	i_Info[GameInfo],
	g_PlayerStats[MAX_PLAYERS][PlayerData],
	cTimer, sTimer,
	CheckpointState: g_Check[MAX_PLAYERS]
;

enum GameMessages {
	LANG_PLAYER_ADMIN,
	LANG_CMD_SYNTAX,
	CMD_SETEAM_ALL,
	LANG_CMD_STARTBASE,
	LANG_PLAYER_CONNECT,
	BASE_IS_FAILED,
	ALPHA_WIN_MESSAGE,
	BRAVO_WIN_MESSAGE,
	ALREADY_STARTBASE,
	WAIT_CMD_ONEMINUTE,
	CMD_ISRANGE_USE,
	BUY_PLAYER_WEAPON,
	LANG_CMD2_SYNTAX,
	GIVE_GANG_ALL,
	GET_GANK_ALL
};

static const
	g_Messages[GameMessages][] = {
	    "{ee5555}<!> {FFFFFF}Error - {ee5555}You do not have permission to use this command.",
	    "{ee5555}<!> {FFFFFF}Usage - {ee5555}/setteam [playerid] [teamid]",
	    "{ee5555}<!> {FFFFFF}Notice - {ee5555}Admin {FFDB00}%s set %s's team to {FFDB00}%d",
	    "{ee5555}<!> {FFFFFF}Error - {ee5555}Match has already started.",
	    "{ee5555}<!> {FFFFFF}Error - {ee5555}Invalid player ID.",
	    "{ee5555}<!> {FFFFFF}Notice - {ee5555}Teams are tied. {FFDB00}+2 minutes {ee5555}overtime.",
	    "{ee5555}<!> {FFFFFF}Notice - {FFDB00}Team Alpha {ee5555}won the match. Congratulations!",
	    "{ee5555}<!> {FFFFFF}Notice - {FFDB00}Team Bravo {ee5555}won the match. Congratulations!",
	    "{ee5555}<!> {FFFFFF}Error - {ee5555}Match has not started yet.",
	    "{ee5555}<!> {FFFFFF}Error - {ee5555}You can only use this command once every {FFDB00}1 minute.",
	    "{ee5555}<!> {FFFFFF}Error - {ee5555}This command can only be used at your spawn location.",
		"{ee5555}<!> {FFFFFF}Error - {ee5555}You must die before buying weapons again.",
		"{ee5555}<!> {FFFFFF}Usage - {ee5555}/spawn [playerid]",
		"{ee5555}<!> {FFFFFF}Notice - {FFDB00}%s {ee5555}has captured the %s zone.",
		"{ee5555}<!> {FFFFFF}Notice - {FFDB00}%s {ee5555}has reclaimed their zone."
	};

//===================================[CALLBACK]=================================

main() {

}

public OnGameModeInit() {
	LoadTextDraws();
    LoadVehicles();
    SetGameModeText("Survivor 1.0");
    UsePlayerPedAnims();
    ShowPlayerMarkers(false);
    i_Info[gangZone][1] = GangZoneCreate(-2814.368, 1261.211, -2499.065, 1518.124);
    i_Info[gangZone][0] = GangZoneCreate(-2720.945, -385.3699, -2452.354, -198.5239);
    ae_Flags = GameFlags: 0;
	for(new i, j = GetMaxPlayers(); i != j; ++i) {
		LoadTextDraws2(i);
	}
	SetWorldTime(0);
	ae_Flags |= AlphaExist;
	ae_Flags |= BravoExist;
	AntiDeAMX();
	return 1;
}

public OnPlayerConnect(playerid) {
	SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
	g_Flags[playerid] = PlayerFlags: 0;
	for(new i = 0; i < _: PlayerData; ++i) {
	    g_PlayerStats[playerid][PlayerData: i] = 0;
	}
	g_Check[playerid] = g_NULL;
	g_Flags[playerid] |= connectPlayer;
	OnConnect(playerid);
	return 1;
}

public OnPlayerSpawn(playerid) {
	if(g_Flags[playerid] & connectPlayer) {
		SetPlayerMapIcon(playerid, 1, -2623.4971,1403.5027,7.1016, 0, 0xE3901EAA, MAPICON_GLOBAL);
		SetPlayerMapIcon(playerid, 0, -2593.9907,-278.3583,18.3193, 0, 0x2687C2AA, MAPICON_GLOBAL);
	    GangZoneShowForPlayer(playerid, i_Info[gangZone][1], 0xE3901E96);
	    GangZoneShowForPlayer(playerid, i_Info[gangZone][0], 0x2687C296);
	    g_Flags[playerid] &= ~connectPlayer;
	}
    ResetPlayerWeapons(playerid);
	if(ae_Flags & i_Start) {
		if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
			if(ae_Flags & AlphaExist) {
			    SetPlayerPos(playerid, -2592.7009,-277.9066,18.6161);
			    if(ae_Flags & BravoExist) {
			    	SetPlayerCheckpoint(playerid, -2662.3447,1474.5598,7.1875, 3);
			    	g_Check[playerid] = g_GIVE;
				}
			} else {
				SetPlayerPos(playerid, -1934.3866,797.7922,55.7188);
				SetPlayerCheckpoint(playerid, -2523.6179,-297.7274,38.9477, 3);
				GivePlayerWeapon(playerid, 24, 150);
				g_Check[playerid] = g_GIVEBACK;
			}
			SetPlayerColor(playerid, 0x2687C2AA);
			SetPlayerSkin(playerid, 1);
		} else if(g_PlayerStats[playerid][e_iTeam] == BRAVO) {
			if(ae_Flags & BravoExist) {
			    SetPlayerPos(playerid, -2623.0657,1404.8541,7.1016);
			    if(ae_Flags & AlphaExist) {
			    	SetPlayerCheckpoint(playerid, -2523.6179,-297.7274,38.9477, 3);
			    	g_Check[playerid] = g_GIVE;
				}
			} else {
				SetPlayerPos(playerid, -1669.1128,1015.0798,7.9219);
				SetPlayerCheckpoint(playerid, -2662.3447,1474.5598,7.1875, 3);
				GivePlayerWeapon(playerid, 24, 150);
				g_Check[playerid] = g_GIVEBACK;
			}
			SetPlayerColor(playerid, 0xE3901EAA);
			SetPlayerSkin(playerid, 217);
		} else goto get;
	} else {
 		TextDrawSetString(i_Info[g_Info], "~w~Please wait, teams are getting ready..");
		get: {
			SetCameraBehindPlayer(playerid);
			g_Flags[playerid] &= ~e_IsSpawned;
			SetPlayerCameraPos(playerid, -2544.2937,1391.9769,24.5625);
			SetPlayerCameraLookAt(playerid, -2590.9844,1395.8748,24.5625);
			SetPlayerPos(playerid, -2544.2937,1391.9769,27.5625);
			TogglePlayerControllable(playerid, false);
			TextDrawShowForPlayer(playerid, i_Info[g_Box]);
			TextDrawShowForPlayer(playerid, i_Info[g_Info]);
			KillTimer(g_PlayerStats[playerid][iTimer]);
   			g_PlayerStats[playerid][iTimer] = SetTimerEx("getScreen", 10 * 1000, true, "i", playerid);
		}
		return 0;
	}
	SetCameraBehindPlayer(playerid);
	TextDrawShowForPlayer(playerid, i_Info[g_scoreTable]);
	TextDrawShowForPlayer(playerid, i_Info[g_cP]);
	g_Flags[playerid] |= e_IsSpawned;
	TogglePlayerControllable(playerid, true);
	KillTimer(g_PlayerStats[playerid][iTimer]);
	for(new i, j = GetMaxPlayers(); i != j; ++i) {
	    if(g_PlayerStats[playerid][e_iTeam] != g_PlayerStats[i][e_iTeam]) {
			ShowPlayerNameTagForPlayer(i, playerid, false);
		}
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
	if(killerid == INVALID_PLAYER_ID) {
		SendDeathMessage(INVALID_PLAYER_ID, playerid, reason);
	} else {
		SendDeathMessage(killerid, playerid, reason);
	}
	g_Flags[playerid] &= ~e_IsSpawned;
	g_Flags[playerid] &= ~buyWeap;
	if(g_Flags[playerid] & flashGang) {
	    OnPlayerLeaveCheckpoint(playerid);
	}
	if(killerid != INVALID_PLAYER_ID) {
		if(g_PlayerStats[playerid][e_iTeam] != g_PlayerStats[killerid][e_iTeam]) {
		    i_Info[TeamScore][g_PlayerStats[killerid][e_iTeam] - 1] += 1;
		    TextDrawSetString(i_Info[g_scoreTable], formatEx("~b~Alpha: ~w~%d - ~b~Bravo: ~w~%d", i_Info[TeamScore][0], i_Info[TeamScore][1]));
		}
	}
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid) {
	if(g_PlayerStats[playerid][e_iTeam] != g_PlayerStats[forplayerid][e_iTeam]) {
    	ShowPlayerNameTagForPlayer(forplayerid, playerid, 0);
	}
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid) {
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    OnKey(playerid, newkeys);
}

public OnPlayerText(playerid, text[]) {
    if(!OnText(playerid, text)) return 0;
	if(text[0] == '!') {
	    if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
		    for(new i, j = GetMaxPlayers(); i != j; ++i) {
		        if(g_PlayerStats[i][e_iTeam] == ALPHA) {
		            SendClientMessage(i, 0xFFFA00FF, formatEx("Team chat -> %s(%i) : {FFFFFF}%s", getName(playerid), playerid, text[1]));
		        }
		    }
		    return 0;
		}
	    if(g_PlayerStats[playerid][e_iTeam] == BRAVO) {
		    for(new i, j = GetMaxPlayers(); i != j; ++i) {
		        if(g_PlayerStats[i][e_iTeam] == BRAVO) {
		            SendClientMessage(i, 0x00A4FFFF, formatEx("Team chat -> %s(%i) : {FFFFFF}%s", getName(playerid), playerid, text[1]));
		        }
		    }
		    return 0;
		}
	}
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid) {
	if(issuerid != INVALID_PLAYER_ID) {
	    if(!IsPlayerInAnyVehicle(issuerid)) {
	        if(g_PlayerStats[playerid][e_iTeam] != g_PlayerStats[issuerid][e_iTeam]) {
		   		PlayerPlaySound(playerid, 17802, 0.0, 0.0, 0.0);
		    	PlayerPlaySound(issuerid, 17802, 0.0, 0.0, 0.0);
		    	static
					Float: fHealth
				;
		    	if(weaponid != 0 && weaponid != 1 && weaponid != 5 && weaponid != 18 && weaponid != 28 && weaponid != 4 && weaponid != 32 && weaponid != 1) {
					GetPlayerHealth(playerid, fHealth);
					SetPlayerHealth(playerid, (random(2) == 1) ? (-1) : _: (fHealth - amount));
		    	}
			} else {
			    new
			        Float: health;
				GetPlayerHealth(playerid, health);
			    SetPlayerHealth(playerid, health + amount);
			}
		}
	}
	return 1;
}

public OnMenuItem(playerid, menuid, key) {
	if(menuid == 0) {
		if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
		    if(!IsPlayerInRangeOfPoint(playerid, 10.0, -2592.7009,-277.9066,18.6161)) {
		        return SendClientMessage(playerid, -1, (g_Messages[CMD_ISRANGE_USE]));
		    }
		} else if(!IsPlayerInRangeOfPoint(playerid, 10.0, -2623.0657,1404.8541,7.1016)) {
	 		return SendClientMessage(playerid, -1, (g_Messages[CMD_ISRANGE_USE]));
	   	}
		switch(key) {
			case 1: {
			    if(g_Flags[playerid] & buyWeap) {
			        return SendClientMessage(playerid, -1, (g_Messages[BUY_PLAYER_WEAPON]));
			    }
			    static const
			        iWeapons1[2][] = {
			            {3, 17, 22, 25, 29},
			            {1, 1, 150, 80, 120}
			        };
				ResetPlayerWeapons(playerid);
				for(new i = 0, j = 5; i != j; ++i) {
					GivePlayerWeapon(playerid, iWeapons1[0][i], iWeapons1[1][i]);
				}
				g_Flags[playerid] |= buyWeap;
			}
			case 2: {
			    if(g_Flags[playerid] & buyWeap) {
			        return SendClientMessage(playerid, -1, (g_Messages[BUY_PLAYER_WEAPON]));
			    }
			    static const
			        iWeapons2[2][] = {
						{5, 18, 23, 26, 28, 33},
						{1, 1, 150, 20, 80, 20}
			        };
                ResetPlayerWeapons(playerid);
				for(new i, j = 6; i != j; ++i) {
					GivePlayerWeapon(playerid, iWeapons2[0][i], iWeapons2[1][i]);
				}
				g_Flags[playerid] |= buyWeap;
			}
			case 3: {
			    if(g_Flags[playerid] & buyWeap) {
			        return SendClientMessage(playerid, -1, (g_Messages[BUY_PLAYER_WEAPON]));
			    }
			    static const
			        iWeapons3[2][] = {
						{4, 16, 24, 27, 32, 34},
						{1, 1, 150, 40, 80, 40}
			        };
                ResetPlayerWeapons(playerid);
				for(new i, j = 6; i != j; ++i) {
					GivePlayerWeapon(playerid, iWeapons3[0][i], iWeapons3[1][i]);
				}
				g_Flags[playerid] |= buyWeap;
			}
			case 4: SetPlayerHealth(playerid, 100);
			case 5: SetPlayerArmour(playerid, 100);
			case 6: GivePlayerWeapon(playerid, 44, 1);
			case 7: GivePlayerWeapon(playerid, 45, 1);
			case 8: GivePlayerWeapon(playerid, 46, 1);
		}
		HidePlayerMenu(playerid);
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
	if(!IsPlayerInAnyVehicle(playerid)) {
	    if(g_Check[playerid] == g_GIVE) {
			if(!(ae_Flags & TeamBuying)) {
   				TextDrawSetString(i_Info[g_cP], (g_PlayerStats[playerid][e_iTeam] == ALPHA) ? ("~y~CP-1 : 10/0 - CP-2 : 10/0   ~r~ |  ~w~ALPHA  ~r~BRAVO")
				   	: ("~y~CP-1 : 10/0 - CP-2 : 10/0   ~r~ |  ~r~ALPHA  ~w~BRAVO"));
                g_PlayerStats[playerid][gMinute] = 10;
                g_PlayerStats[playerid][gSeconds] = 0;
				if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
					GangZoneFlashForAll(i_Info[gangZone][1], 0xDB1428AA);
					g_PlayerStats[playerid][iTimer2] = SetTimerEx("giveGang", 1000, true, "id", playerid, 1);
				} else {
				    GangZoneFlashForAll(i_Info[gangZone][0], 0xDB1428AA);
				    g_PlayerStats[playerid][iTimer2] = SetTimerEx("giveGang", 1000, true, "id", playerid, 0);
				}
				ae_Flags |= TeamBuying;
				g_Flags[playerid] |= flashGang;
			}
	    }
	    if(g_Check[playerid] == g_GIVEBACK) {
			if(!(ae_Flags & TeamBuying)) {
   				TextDrawSetString(i_Info[g_cP], (g_PlayerStats[playerid][e_iTeam] == ALPHA) ? ("~y~CP-1 : 10/0 - CP-2 : 10/0   ~r~ |  ~r~ALPHA  ~w~BRAVO")
				   	: ("~y~CP-1 : 10/0 - CP-2 : 10/0   ~r~ |  ~w~ALPHA  ~r~BRAVO"));
                g_PlayerStats[playerid][gMinute] = 1;
                g_PlayerStats[playerid][gSeconds] = 0;
				if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
					GangZoneFlashForAll(i_Info[gangZone][0], 0xDB1428AA);
					g_PlayerStats[playerid][iTimer2] = SetTimerEx("getGang", 1000, true, "id", playerid);
				} else {
				    GangZoneFlashForAll(i_Info[gangZone][1], 0xDB1428AA);
				    g_PlayerStats[playerid][iTimer2] = SetTimerEx("getGang", 1000, true, "id", playerid);
				}
				ae_Flags |= TeamBuying;
				g_Flags[playerid] |= flashGang;
			}
	    }
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid) {
	if(g_Check[playerid] == g_GIVE) {
	    if(g_Flags[playerid] & flashGang) {
		    if(ae_Flags & TeamBuying) {
				TextDrawSetString(i_Info[g_cP], "~y~CP-1 : 10/0 - CP-2 : 10/0   ~r~ |  ~w~ALPHA  BRAVO");
		   		ae_Flags &= ~TeamBuying;
		   		KillTimer(g_PlayerStats[playerid][iTimer2]);
		   		g_Flags[playerid] &= ~flashGang;
		   		if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
		   			GangZoneStopFlashForAll(i_Info[gangZone][1]);
				} else {
		   			GangZoneStopFlashForAll(i_Info[gangZone][0]);
				}
			}
		}
   	}

	if(g_Check[playerid] == g_GIVEBACK) {
	    if(g_Flags[playerid] & flashGang) {
		    if(ae_Flags & TeamBuying) {
				TextDrawSetString(i_Info[g_cP], "~y~CP-1 : 10/0 - CP-2 : 10/0   ~r~ |  ~w~ALPHA  BRAVO");
		   		ae_Flags &= ~TeamBuying;
		   		KillTimer(g_PlayerStats[playerid][iTimer2]);
		   		g_Flags[playerid] &= ~flashGang;
		   		if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
		   			GangZoneStopFlashForAll(i_Info[gangZone][0]);
				} else {
		   			GangZoneStopFlashForAll(i_Info[gangZone][1]);
				}
			}
		}
   	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	if(g_Flags[playerid] & flashGang) {
	    OnPlayerLeaveCheckpoint(playerid);
	    g_Flags[playerid] &= ~flashGang;
	}
	SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);
    i_Info[TeamCount][g_PlayerStats[playerid][e_iTeam] - 1] -= 1;
	return 1;
}

//===================================[COMMANDS]=================================

CMD:setteam(playerid, params[]) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, (g_Messages[LANG_PLAYER_ADMIN]));
	if(sscanf(params, "ud", params[0], params[1])) {
	    return SendClientMessage(playerid, -1, (g_Messages[LANG_CMD_SYNTAX]));
	}

	if(params[0] == INVALID_PLAYER_ID) {
	    return SendClientMessage(playerid, -1, (g_Messages[LANG_PLAYER_CONNECT]));
	}

	if(params[1] < 1 || params[1] > 2) {
	    return SendClientMessage(playerid, -1, (g_Messages[LANG_CMD_SYNTAX]));
	}

	g_PlayerStats[params[0]][e_iTeam] = params[1];
	i_Info[TeamCount][params[1] - 1] += 1;
	SendClientMessageToAll(-1, (formatEx(g_Messages[CMD_SETEAM_ALL], getName(playerid), getName(params[0]), params[1])));
	return 1;
}
CMD:music(playerid,params[]) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, (g_Messages[LANG_PLAYER_ADMIN]));
 	if(sscanf(params, "s[1024]", params[0])) {
		return SendClientMessage(playerid, -1 ,"{ee5555}<!> {FFFFFF}Correct usage - {ee5555}' /music [url]'");
 	}
	PlayAudioStreamForPlayer(playerid,params[0]);
	return 1;
}

CMD:startbase(playerid, params[]) {
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, (g_Messages[LANG_PLAYER_ADMIN]));
	if(ae_Flags & i_Start)
	    return SendClientMessage(playerid, -1, (g_Messages[LANG_CMD_STARTBASE]));

	i_Info[iDown] = 10;
	TextDrawSetString(i_Info[g_Info], "~w~Round starts in ~r~10 ~w~seconds remaining");
	cTimer = SetTimer("countDown", 1000, true);
	return 1;
}

CMD:stopbase(playerid, params[]) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, (g_Messages[LANG_PLAYER_ADMIN]));
	if(!(ae_Flags & i_Start))
	    return SendClientMessage(playerid, -1, (g_Messages[ALREADY_STARTBASE]));
	KillTimer(cTimer);
	KillTimer(sTimer);
    stopDown();
	return 1;
}

CMD:gunmenu(playerid, params[]) {
	if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
	    if(!IsPlayerInRangeOfPoint(playerid, 10.0, -2592.7009,-277.9066,18.6161)) {
	        return SendClientMessage(playerid, -1, (g_Messages[CMD_ISRANGE_USE]));
	    }
	} else if(!IsPlayerInRangeOfPoint(playerid, 10.0, -2623.0657,1404.8541,7.1016)) {
 		return SendClientMessage(playerid, -1, (g_Messages[CMD_ISRANGE_USE]));
   	}
   	if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
   	    if(!(ae_Flags & AlphaExist)) {
   	        return 0;
   	    }
   	}

   	if(g_PlayerStats[playerid][e_iTeam] == BRAVO) {
   	    if(!(ae_Flags & BravoExist)) {
   	        return 0;
   	    }
   	}

	new e_items[][] = {
		{"~r~<!> ~w~Weapons-~y~1"},     {"~w~Nightstick~n~Tear Gas~n~Pistol~n~Shotgun~n~MP5"},
		{"~r~<!> ~w~Weapons-~b~2"},     {"~w~Baseball Bat~n~Molotov Coctail~n~Silenced Pistol~n~Sawnoff Shotgun~n~Micro Uzi~n~Country Rifle"},
		{"~r~<!> ~w~Weapons-~r~3"},     {"~w~Knife~n~Grenade~n~Desert Eagle~n~Combat Shotgun~n~Tec-9~n~Sniper Rifle"},
		{"~r~<!> ~w~Ekipmanlar"	 },     {"~y~4: ~w~Health~n~~y~5: ~w~Armour~n~~y~6: ~w~Night Vis Goggles~n~~y~7: ~w~Thermal Goggles~n~~y~8: ~w~Parachute"}
	};
	ShowPlayerMenu(playerid, 0, e_items);
	SendClientMessage(playerid, -1, "{FFDB00}-> {FFFFFF}Press LMB to exit the menu.");
	return 1;
}

CMD:spawn(playerid, params[]) {
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, (g_Messages[LANG_PLAYER_ADMIN]));
	if(sscanf(params, "u", params[0])) {
	    return SendClientMessage(playerid, -1, (g_Messages[LANG_CMD2_SYNTAX]));
	}

	if(!IsPlayerConnected(params[0])) {
	    return SendClientMessage(playerid, -1, (g_Messages[LANG_PLAYER_CONNECT]));
	}

	OnPlayerSpawn(params[0]);
	KillTimer(g_PlayerStats[params[0]][iTimer]);
	return 1;
}

//=====================================[F/S]====================================

stock distanceBetweenPoints2D(Float: x1, Float: y1, Float: x2, Float: y2) {
   return _: (floatsqroot((floatpower(floatabs((x2 - x1)), 2)) + floatpower(floatabs((y1 - y2)), 2)));
}

stock IsVehicleInRangeOfPoint(iVehID, Float: fRad, Float: fX, Float: fY, Float: fZ) {
	return !!(GetVehicleDistanceFromPoint(iVehID, fX, fY, fZ) < fRad);
}

giveGang(playerid, gang); public giveGang(playerid, gang) {
	if(g_PlayerStats[playerid][gMinute] != 0) {
		if(g_PlayerStats[playerid][gSeconds] != 10) {
		    g_PlayerStats[playerid][gSeconds] += 1;
		} else {
		    g_PlayerStats[playerid][gSeconds] = 0;
		    g_PlayerStats[playerid][gMinute] -= 1;
		}
		if(!gang) {
	        TextDrawSetString(i_Info[g_cP], formatEx("~y~CP-1 : %d/%d - CP-2 : %s   ~r~ |  ~r~ALPHA  ~w~BRAVO", g_PlayerStats[playerid][gMinute], g_PlayerStats[playerid][gSeconds], (ae_Flags & AlphaExist) ? ("10/0") : ("1/0")));
		} else {
		    TextDrawSetString(i_Info[g_cP], formatEx("~y~CP-1 : %s - CP-2 : %d/%d   ~r~ |  ~w~ALPHA  ~r~BRAVO", (ae_Flags & BravoExist) ? ("10/0") : ("1/0"), g_PlayerStats[playerid][gMinute], g_PlayerStats[playerid][gSeconds]));
		}
	} else {
	    GangZoneStopFlashForAll(i_Info[gangZone][gang]);
	    GangZoneShowForAll(i_Info[gangZone][gang], GetPlayerColor(playerid));
	    static const
			Float: iPositions[4][3] = {
				{-2523.6179,-297.7274,38.9477},
				{-2662.3447,1474.5598,7.1875},
				{-2593.9907,-278.3583,18.3193},
				{-2623.4971,1403.5027,7.1016}
			};
	    ae_Flags &= (!gang) ? (~AlphaExist) : (~BravoExist);
		g_Flags[playerid] &= ~flashGang;
		KillTimer(g_PlayerStats[playerid][iTimer2]);
		ae_Flags &= ~TeamBuying;
	    for(new i, j = GetMaxPlayers(); i != j; ++i) {
	        if(IsPlayerConnected(i)) {
		        if(g_PlayerStats[i][e_iTeam] == g_PlayerStats[playerid][e_iTeam]) {
		    		DisablePlayerCheckpoint(i);
		    		g_Check[i] = g_NULL;
				} else {
					SetPlayerCheckpoint(i, iPositions[gang][0], iPositions[gang][1], iPositions[gang][2], 3);
                    g_Check[i] = g_GIVEBACK;
				}
				RemovePlayerMapIcon(i, gang);
				SetPlayerMapIcon(i, gang, iPositions[gang + 2][0], iPositions[gang + 2][1], iPositions[gang + 2][2], 0, GetPlayerColor(playerid), MAPICON_GLOBAL);
			}
			if(!gang) {
				TextDrawSetString(i_Info[g_cP], formatEx("~y~CP-1 : 1/0 - CP-2 : %s   ~r~ |  ~w~ALPHA  BRAVO", (ae_Flags & BravoExist) ? ("10/0") : ("1/0")));
			} else {
				TextDrawSetString(i_Info[g_cP], formatEx("~y~CP-1 : %s - CP-2 : 1/0   ~r~ |  ~w~ALPHA  BRAVO", (ae_Flags & AlphaExist) ? ("10/0") : ("1/0")));
			}
		}
		SendClientMessageToAll(-1, (formatEx(g_Messages[GIVE_GANG_ALL], (gang) ? ("ALPHA") : ("BRAVO"), (gang) ? ("BRAVO") : ("ALPHA"))));
	}
}

getGang(playerid); public getGang(playerid) {
	if(g_PlayerStats[playerid][gMinute] != 10) {
		if(g_PlayerStats[playerid][gSeconds] != 10) {
		    g_PlayerStats[playerid][gSeconds] += 1;
		} else {
		    g_PlayerStats[playerid][gSeconds] = 0;
		    g_PlayerStats[playerid][gMinute] += 1;
		}
		if(g_PlayerStats[playerid][e_iTeam] == 2) {
	        TextDrawSetString(i_Info[g_cP], formatEx("~y~CP-1 : %s - CP-2 : %d/%d   ~r~ |  ~w~ALPHA  ~r~BRAVO", (ae_Flags & AlphaExist) ? ("10/0") : ("1/0"), g_PlayerStats[playerid][gMinute], g_PlayerStats[playerid][gSeconds]));
		} else if(g_PlayerStats[playerid][e_iTeam] == 1) {
		    TextDrawSetString(i_Info[g_cP], formatEx("~y~CP-1 : %d/%d - CP-2 : %s   ~r~ |  ~r~ALPHA  ~w~BRAVO", g_PlayerStats[playerid][gMinute], g_PlayerStats[playerid][gSeconds], (ae_Flags & BravoExist) ? ("10/0") : ("1/0")));
		}
	} else {
	    GangZoneStopFlashForAll(i_Info[gangZone][g_PlayerStats[playerid][e_iTeam] - 1]);
	    GangZoneShowForAll(i_Info[gangZone][g_PlayerStats[playerid][e_iTeam] - 1], GetPlayerColor(playerid));
	    ae_Flags |= (g_PlayerStats[playerid][e_iTeam] == ALPHA) ? (AlphaExist) : (BravoExist);
		g_Flags[playerid] &= ~flashGang;
		KillTimer(g_PlayerStats[playerid][iTimer2]);
		ae_Flags &= ~TeamBuying;
	    static const
			Float: iPositions[4][3] = {
				{-2523.6179,-297.7274,38.9477},
				{-2662.3447,1474.5598,7.1875},
				{-2623.4971,1403.5027,7.1016},
				{-2593.9907,-278.3583,18.3193}
			};
	    for(new i, j = GetMaxPlayers(); i != j; ++i) {
	        if(IsPlayerConnected(i)) {
		        if(g_PlayerStats[i][e_iTeam] == g_PlayerStats[playerid][e_iTeam]) {
		    		DisablePlayerCheckpoint(i);
		    		g_Check[i] = g_GIVE;
		    		SetPlayerCheckpoint(i, iPositions[g_PlayerStats[playerid][e_iTeam]][0], iPositions[g_PlayerStats[playerid][e_iTeam]][1], iPositions[g_PlayerStats[playerid][e_iTeam]][2], 3);
				}
				RemovePlayerMapIcon(i, g_PlayerStats[playerid][e_iTeam] - 1);
				SetPlayerMapIcon(i, g_PlayerStats[playerid][e_iTeam] - 1, iPositions[g_PlayerStats[playerid][e_iTeam] + 2][0], iPositions[g_PlayerStats[playerid][e_iTeam] + 2][1], iPositions[g_PlayerStats[playerid][e_iTeam] + 2][2], 0, GetPlayerColor(playerid), MAPICON_GLOBAL);
			}
			if(g_PlayerStats[playerid][e_iTeam] == ALPHA) {
				TextDrawSetString(i_Info[g_cP], formatEx("~y~CP-1 : 10/0 - CP-2 : %s   ~r~ |  ~w~ALPHA  BRAVO", (ae_Flags & AlphaExist) ? ("10/0") : ("1/0")));
			} else {
				TextDrawSetString(i_Info[g_cP], formatEx("~y~CP-1 : %s - CP-2 : 10/0   ~r~ |  ~w~ALPHA  BRAVO", (ae_Flags & BravoExist) ? ("10/0") : ("1/0")));
			}
		}
		SendClientMessageToAll(-1, (formatEx(g_Messages[GET_GANK_ALL], (g_PlayerStats[playerid][e_iTeam] == ALPHA) ? ("ALPHA") : ("BRAVO"))));
	}
}

LoadTextDraws(); public LoadTextDraws() {
	i_Info[g_Box] = TextDrawCreate(661.000000, 437.000000, "~n~");
	TextDrawBackgroundColor(i_Info[g_Box], 255);
	TextDrawFont(i_Info[g_Box], 1);
	TextDrawLetterSize(i_Info[g_Box], 0.500000, 2.099997);
	TextDrawColor(i_Info[g_Box], -1);
	TextDrawSetOutline(i_Info[g_Box], 0);
	TextDrawSetProportional(i_Info[g_Box], 1);
	TextDrawSetShadow(i_Info[g_Box], 1);
	TextDrawUseBox(i_Info[g_Box], 1);
	TextDrawBoxColor(i_Info[g_Box], 100);
	TextDrawTextSize(i_Info[g_Box], -5.000000, 7.000000);

	i_Info[g_Info] = TextDrawCreate(208.000000, 437.000000, "~w~Round ends in ~r~10 ~w~seconds remaining");
	TextDrawBackgroundColor(i_Info[g_Info], 255);
	TextDrawFont(i_Info[g_Info], 1);
	TextDrawLetterSize(i_Info[g_Info], 0.369998, 0.899999);
	TextDrawColor(i_Info[g_Info], -1);
	TextDrawSetOutline(i_Info[g_Info], 0);
	TextDrawSetProportional(i_Info[g_Info], 1);
	TextDrawSetShadow(i_Info[g_Info], 1);

	i_Info[g_scoreTable] = TextDrawCreate(513.000000, 102.000000, "~b~Team: ~w~0 ~r~- ~b~Bravo: ~w~0");
	TextDrawBackgroundColor(i_Info[g_scoreTable], 255);
	TextDrawFont(i_Info[g_scoreTable], 1);
	TextDrawLetterSize(i_Info[g_scoreTable], 0.300000, 0.899999);
	TextDrawColor(i_Info[g_scoreTable], -1);
	TextDrawSetOutline(i_Info[g_scoreTable], 0);
	TextDrawSetProportional(i_Info[g_scoreTable], 1);
	TextDrawSetShadow(i_Info[g_scoreTable], 1);

	i_Info[g_cP] = TextDrawCreate(6.000000, 437.000000, "~y~CP-1 : 10/0 - CP-2 : 10/0   ~r~ |  ~w~ALPHA  BRAVO");
	TextDrawBackgroundColor(i_Info[g_cP], 255);
	TextDrawFont(i_Info[g_cP], 1);
	TextDrawLetterSize(i_Info[g_cP], 0.230000, 0.799999);
	TextDrawColor(i_Info[g_cP], -1);
	TextDrawSetOutline(i_Info[g_cP], 0);
	TextDrawSetProportional(i_Info[g_cP], 1);
	TextDrawSetShadow(i_Info[g_cP], 1);
}

LoadVehicles(); public LoadVehicles() {
    AddStaticVehicle(402,-2834.7319,1320.2560,6.9326,312.2821,0,0); //
	AddStaticVehicle(521,-2846.0586,1307.8232,6.6669,359.1556,1,3); //
	AddStaticVehicle(482,-2967.7227,457.8125,5.0350,319.0941,0,0); //
	AddStaticVehicle(500,-2674.1619,-278.7180,7.2802,47.4354,1,1); //
	AddStaticVehicle(451,-2674.7102,629.9014,14.1596,90.3188,154,154); //
	AddStaticVehicle(462,-2345.2126,729.9675,41.5796,90.2069,6,6); //
	AddStaticVehicle(400,-2511.3516,761.5134,35.2642,271.1436,11,11); //
	AddStaticVehicle(411,-1950.9666,266.7154,40.7757,213.1144,161,161); //
	AddStaticVehicle(404,-1979.1416,431.8273,25.2035,359.2283,1,1); //
	AddStaticVehicle(540,-2053.4692,403.6382,35.0331,179.9299,1,1); //
	AddStaticVehicle(560,-1659.9968,1214.3923,13.3763,315.2688,161,161); //
	AddStaticVehicle(579,-1891.5464,780.0931,41.6736,358.8253,3,3); //
	AddStaticVehicle(410,-1672.2294,1058.3202,7.5771,336.3454,4,4); //
}

getScreen(playerid); public getScreen(playerid) {
	if(!(g_Flags[playerid] & e_IsSpawned)) {
		if(g_Flags[playerid] & e_Screen) {
		    g_Flags[playerid] &= ~e_Screen;
		    SetCameraBehindPlayer(playerid);
		    SetPlayerCameraPos(playerid, -2544.2937,1391.9769,24.5625);
		    SetPlayerPos(playerid, -2544.2937,1391.9769,27.5625);
		    SetPlayerCameraLookAt(playerid, -2590.9844,1395.8748,24.5625);
		} else {
		    g_Flags[playerid] |= e_Screen;
		    SetCameraBehindPlayer(playerid);
		    SetPlayerCameraPos(playerid, -2677.4922,-282.3828,14.9433);
		    SetPlayerPos(playerid, -2677.4922,-282.3828,25.9433);
		    SetPlayerCameraLookAt(playerid, -2656.9268,-280.7535,14.9433);
		}
	}
}

countDown(); public countDown() {
    i_Info[iDown] -= 1;
    TextDrawSetString(i_Info[g_Info], formatEx("~w~Round starts in ~r~%d ~w~seconds remaining", i_Info[iDown]));
    if(!i_Info[iDown]) {
		ae_Flags |= i_Start;
		for(new i, j = GetMaxPlayers(); i != j; ++i) {
			if(IsPlayerConnected(i)) {
			    SpawnPlayer(i);
			}
		}
		sTimer = SetTimer("stopDown", 10 * 60000, true);
  		TextDrawSetString(i_Info[g_Info], "~w~Round ends in ~b~10 ~w~minutes remaining");
		KillTimer(cTimer);
	}
}

stopDown(); public stopDown() {
	if(i_Info[TeamScore][0] == i_Info[TeamScore][1]) {
 		SendClientMessageToAll(-1, (g_Messages[BASE_IS_FAILED]));
   		TextDrawSetString(i_Info[g_Info], "~w~Round ends in ~r~2 ~w~minutes remaining");
        KillTimer(sTimer);
        sTimer = SetTimer("stopDown", 2 * 60000, true);
	}
    else if(i_Info[TeamScore][0] > i_Info[TeamScore][1]) {
    	SendClientMessageToAll(-1, (g_Messages[ALPHA_WIN_MESSAGE]));
     	ae_Flags &= ~i_Start;
      	for(new i, j = GetMaxPlayers(); i != j; ++i) {
     		OnPlayerSpawn(i);
     		g_Flags[i] &= ~buyWeap;
        }
        KillTimer(sTimer);
        i_Info[TeamScore][0] = 0;
        i_Info[TeamScore][1] = 0;
    }

	else if(i_Info[TeamScore][1] > i_Info[TeamScore][0]) {
 		SendClientMessageToAll(-1, (g_Messages[BRAVO_WIN_MESSAGE]));
   		ae_Flags &= ~i_Start;
     	for(new i, j = GetMaxPlayers(); i != j; ++i) {
     		OnPlayerSpawn(i);
     		g_Flags[i] &= ~buyWeap;
       	}
        KillTimer(sTimer);
        i_Info[TeamScore][0] = 0;
        i_Info[TeamScore][1] = 0;
   	}
   	TextDrawSetString(i_Info[g_scoreTable], formatEx("~b~Alpha: ~w~%d - ~b~Bravo: ~w~%d", i_Info[TeamScore][0], i_Info[TeamScore][1]));
}

stock getName(playerid) {
	static
	    g_szName[MAX_PLAYER_NAME]
	;

	g_szName[0] = EOS;
	GetPlayerName(playerid, g_szName, sizeof(g_szName));
	return g_szName;
}
AntiDeAMX(){
	new a[][] =
	{
		"Unarmed (Fist)",
		"Brass K"
	};
	#pragma unused a
}
