// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <Pawn.CMD>
#include <sscanf2>
#include <foreach>

#define debug_server true

new MySQL:dbHandle;
enum ENUM_E_PLAYER_INFO
{
	pName [ MAX_PLAYER_NAME ],

	bool:tOpenContainer,
	tLastArea,
}
new PlayerInfo [ MAX_PLAYERS ] [ ENUM_E_PLAYER_INFO ];
stock Float:frand (Float:limit)
	return float (random (floatround (limit, floatround_floor))) + float (random (1000)) / 1000.0;

#define Container:%0(%1) CONTAINER_%0(%1)
#include "gamemodes/system/container/main.pwn"

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	// Don't use these lines if it's a filterscript
	SetGameModeText("Blank Script");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

	dbHandle = mysql_connect_file();
	mysql_log (ALL);
	
	if (mysql_errno () != 0) printf ("[BD] Íå óäàëîñü ïîäêëþ÷èòüñÿ ê ÁÄ.");
	else
	{
		printf ("[BD] Ïîäêëþ÷åíèå óñïåøíî.");

        mysql_set_charset ("cp1251");
	    mysql_query (dbHandle, "SET NAMES cp1251;", false);
		mysql_query (dbHandle, "SET SESSION character_set_server='utf8';", false);

	    new name [ 32 ];
		mysql_get_charset (name, 32, dbHandle);
		printf ("[BD] Êîäèðîâêà: %s", name);
	}

	#if defined _container_system
		Container:Init();
	#endif
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	PlayerInfo [ playerid ] [ tOpenContainer ] = false;
	PlayerInfo [ playerid ] [ tLastArea ] = -1;

	GetPlayerName (playerid, PlayerInfo [ playerid ] [ pName ], MAX_PLAYER_NAME);
	SendClientMessageEx (playerid, -1, "%s", PlayerInfo [ playerid ] [ pName ]);
	#if defined _container_system
		Container:connect (playerid);
	#endif

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#if defined _container_system
		Container:disconnect (playerid);
	#endif
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}


public OnPlayerEnterDynamicArea (playerid, areaid)
{
	new extraId = Streamer_GetIntData (STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID);

	#if defined debug_server
		SendClientMessageEx (playerid, -1, "[OnPlayerEnterDynamicArea] areaid:%i, extraId:%i", areaid, extraId);
	#endif

	PlayerInfo [ playerid ] [ tLastArea ] = areaid;

	#if defined _container_system
		if (Container:enterArea (playerid, areaid, extraId))
			return 1;
	#endif

	return 1;
}

public OnPlayerLeaveDynamicArea (playerid, areaid)
{
	new extraId = Streamer_GetIntData (STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID);

	#if defined debug_server
		SendClientMessageEx (playerid, -1, "[OnPlayerLeaveDynamicArea] areaid:%i, extraId:%i", areaid, extraId);
	#endif

	PlayerInfo [ playerid ] [ tLastArea ] = -1;

	#if defined _container_system
		if (Container:exitArea (playerid))
			return 1;
	#endif
	return 1;
}

stock SendClientMessageEx (playerid, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 12)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 12); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string
		#emit PUSH.C args
		#emit SYSREQ.C format

		SendClientMessage (playerid, color, string);

		#emit LCTRL 5
		#emit SCTRL 4
		#emit RETN
	}
	return SendClientMessage (playerid, color, str);
}

stock TranslateText (const string[])
{
	new result [ 300 ];
	for (new i = 0, j = strlen (string); i < j; i++)
	{
		switch(string[i])
		{
			case 'à': result[i] = 'a';
			case 'À': result[i] = 'A';
			case 'á': result[i] = '—';
			case 'Á': result[i] = '€';
			case 'â': result[i] = '¢';
			case 'Â': result[i] = '‹';
			case 'ã': result[i] = '™';
			case 'Ã': result[i] = '‚';
			case 'ä': result[i] = 'š';
			case 'Ä': result[i] = 'ƒ';
			case 'å': result[i] = 'e';
			case 'Å': result[i] = 'E';
			case '¸': result[i] = 'e';
			case '¨': result[i] = 'E';
			case 'æ': result[i] = '›';
			case 'Æ': result[i] = '„';
			case 'ç': result[i] = 'Ÿ';
			case 'Ç': result[i] = 'ˆ';
			case 'è': result[i] = 'œ';
			case 'È': result[i] = '…';
			case 'é': result[i] = '';
			case 'É': result[i] = '…';
			case 'ê': result[i] = 'k';
			case 'Ê': result[i] = 'K';
			case 'ë': result[i] = 'ž';
			case 'Ë': result[i] = '‡';
			case 'ì': result[i] = '¯';
			case 'Ì': result[i] = 'M';
			case 'í': result[i] = '®';
			case 'Í': result[i] = '­';
			case 'î': result[i] = 'o';
			case 'Î': result[i] = 'O';
			case 'ï': result[i] = '£';
			case 'Ï': result[i] = 'Œ';
			case 'ð': result[i] = 'p';
			case 'Ð': result[i] = 'P';
			case 'ñ': result[i] = 'c';
			case 'Ñ': result[i] = 'C';
			case 'ò': result[i] = '¦';
			case 'Ò': result[i] = '';
			case 'ó': result[i] = 'y';
			case 'Ó': result[i] = 'Y';
			case 'Ô': result[i] = '';
			case 'ô': result[i] = '';
			case 'õ': result[i] = 'x';
			case 'Õ': result[i] = 'X';
			case 'Ö': result[i] = '‰';
			case 'ö': result[i] = '‰';
			case '÷': result[i] = '¤';
			case '×': result[i] = '';
			case 'ø': result[i] = '¥';
			case 'Ø': result[i] = 'Ž';
			case 'ù': result[i] = '¡';
			case 'Ù': result[i] = 'Š';
			case 'ü': result[i] = '©';
			case 'Ü': result[i] = '’';
			case 'ú': result[i] = '';
			case 'Ú': result[i] = '§';
			case 'û': result[i] = '¨';
			case 'Û': result[i] = '‘';
			case 'ý': result[i] = 'ª';
			case 'Ý': result[i] = '“';
			case 'þ': result[i] = '«';
			case 'Þ': result[i] = '”';
			case 'ÿ': result[i] = '¬';
			case 'ß': result[i] = '•';
			default: result[i] = string[i];
		}
	}
	return result;
}