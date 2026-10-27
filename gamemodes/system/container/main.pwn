#if defined _container_system
    #endinput
#endif
#define _container_system

#define MAX_CONTAINER       100
#define MAX_CONTAINER_TYPE  5

#define TABLE_CONTAINER         "game__container"
#define TABLE_CONTAINER_TYPE    "game__container_type"
#define TABLE_CONTAINER_LOOT    "game__container_loot"
#define TABLE_CONTAINER_BID     "game__container_bid"
#define TABLE_CONTAINER_LOG     "game__container_log"
#define TABLE_CONTAINER_WIN     "game__container_loot_winner"

enum E_CONTAINER_TYPE_INFO
{
    ctID,
    ctName [ 32 ]
}
new ContainerType [ MAX_CONTAINER_TYPE ] [ E_CONTAINER_TYPE_INFO ];

enum E_CONTAINER_INFO
{
    cID,
    cType,

    cModel,
    Float:cPosX,
    Float:cPosY,
    Float:cPosZ,

    Float:cPosRX,
    Float:cPosRY,
    Float:cPosRZ,
    
    cVW,
    cInt,

    cArea,
    cObject,
    Text3D:cLabel,

    cTime,
    cStartPrice,

    cLastStavka [ MAX_PLAYER_NAME ],
    cLastStavkaCash,
    
    cStavkaTotal,
}
new ContainerInfo [ MAX_CONTAINER ] [ E_CONTAINER_INFO ];

new PlayerText:PTD_container [ MAX_PLAYERS ] [ 3 ];

stock Container:Init()
{
    for (new i = 0; i < MAX_CONTAINER; i ++)
    {
        ContainerInfo [ i ] [ cLabel ] = Text3D:INVALID_3DTEXT_ID;
        ContainerInfo [ i ] [ cObject ] = INVALID_OBJECT_ID;
    }

    SetTimer ("CONTAINER_timer", 1000, true);

    mysql_tquery (dbHandle, "SELECT * FROM "TABLE_CONTAINER_TYPE"", "CONTAINER_loadType");
    mysql_tquery (dbHandle, "SELECT * FROM "TABLE_CONTAINER"", "CONTAINER_load");
    return 1;
}

#include "gamemodes/system/container/stock.pwn"
#include "gamemodes/system/container/cmd.pwn"
#include "gamemodes/system/container/public.pwn"