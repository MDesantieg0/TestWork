
CMD:create_container (playerid, params[])
{
    new type,
        model,
        cash;
    
    if (sscanf (params, "ddd", type, model, cash))
        return SendClientMessageEx (playerid, -1, "/create_container [type] [model] [cash]");
    
    if (type < 0 || type > MAX_CONTAINER_TYPE)
        return SendClientMessageEx (playerid, -1, "/create_container [!type] [model] [cash]");

    if (cash <= 0)
        return SendClientMessageEx (playerid, -1, "/create_container [type] [model] [!cash]");

    new index = -1;
    for (new i = 0; i < MAX_CONTAINER; i ++)
    {
        if (ContainerInfo [ i ] [ cID ] > 0)
            continue;
        
        index = i;
        break;
    }

    if (index == -1)
        return SendClientMessageEx (playerid, -1, "Создано уже слишком много");

    GetPlayerPos (playerid, ContainerInfo [ index ] [ cPosX ], ContainerInfo [ index ] [ cPosY ], ContainerInfo [ index ] [ cPosZ ]);
    
    ContainerInfo [ index ] [ cType ] = ContainerType [ type ] [ ctID ];

    ContainerInfo [ index ] [ cModel ] = model;
    ContainerInfo [ index ] [ cVW ] = GetPlayerVirtualWorld (playerid);
    ContainerInfo [ index ] [ cInt ] = GetPlayerInterior (playerid);
    ContainerInfo [ index ] [ cStartPrice ] = cash;
    ContainerInfo [ index ] [ cTime ] = random (10) + 2;

    new query [ 256 ];

    mysql_format (dbHandle, query, sizeof query, "INSERT INTO "TABLE_CONTAINER" (cModel,`cPosX`,`cPosY`,`cPosZ`,cVW,cInt,cType,cStartPrice,cTime) VALUES (%i,'%f','%f','%f',%i,%i,%i,%i,%i)",
        model,
        ContainerInfo [ index ] [ cPosX ],
        ContainerInfo [ index ] [ cPosY ],
        ContainerInfo [ index ] [ cPosZ ],
        ContainerInfo [ index ] [ cVW ],
        ContainerInfo [ index ] [ cInt ],
        ContainerInfo [ index ] [ cType ],
        cash,
        ContainerInfo [ index ] [ cTime ]
    );
    mysql_pquery (dbHandle, query, "CONTAINER_insert", "i", index);
    return 1;
}

CMD:stavka (playerid, params[])
{
    if (PlayerInfo [ playerid ] [ tLastArea ] == -1)
        return SendClientMessageEx (playerid, -1, "Вы должны быть около контейнера");
    
    new cash;

    if (sscanf (params, "d", cash))
        return SendClientMessageEx (playerid, -1, "/stavka [сумма]");
    
    if (cash < 0)
        return SendClientMessageEx (playerid, -1, "/stavka [сумма]");

    new extraId = Streamer_GetIntData (STREAMER_TYPE_AREA, PlayerInfo [ playerid ] [ tLastArea ], E_STREAMER_EXTRA_ID);

    if (ContainerInfo [ extraId ] [ cStavkaTotal ] + cash < ContainerInfo [ extraId ] [ cStavkaTotal ] || ContainerInfo [ extraId ] [ cStavkaTotal ] + cash < 0)
        return SendClientMessageEx (playerid, -1, "Больше ставить нельзя!");

    ContainerInfo [ extraId ] [ cStavkaTotal ] += cash;

    if (ContainerInfo [ extraId ] [ cStartPrice ] > cash)
        return SendClientMessageEx (playerid, -1, "Сумма ставки не может быть меньше минимальной %i!", ContainerInfo [ extraId ] [ cStartPrice ]);

    format (ContainerInfo [ extraId ] [ cLastStavka ], MAX_PLAYER_NAME, PlayerInfo [ playerid ] [ pName ]);
    Container:updateTD (extraId);

    new query [ 128 ];
    mysql_format (dbHandle, query, sizeof query, "INSERT INTO "TABLE_CONTAINER_BID" (containerId,`username`,count) VALUES (%i,'%s',%i)",
        ContainerInfo [ extraId ] [ cID ],
        PlayerInfo [ playerid ] [ pName ],
        cash
    );
    mysql_tquery (dbHandle, query);

    foreach (Player, i)
    {
        if (!PlayerInfo [ i ] [ tOpenContainer ] || PlayerInfo [ i ] [ tLastArea ] != ContainerInfo [ extraId ] [ cArea ])
            continue;

        Container:updatePlayerChange (i, extraId);        
    }

    format (query, sizeof query, "%s сделал ставку %i на контейнер #%i", PlayerInfo [ playerid ] [ pName ], cash, ContainerInfo [ extraId ] [ cID ]);
    Container:log (query);
    return 1;
}