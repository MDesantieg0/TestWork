stock Container:connect (playerid)
{
    new query [ 256 ];
    mysql_format (dbHandle, query, sizeof query, "SELECT w.*, l.iName, l.iAmount FROM "TABLE_CONTAINER_WIN" w INNER JOIN "TABLE_CONTAINER_LOOT" l ON l.id = w.lootid WHERE w.username = '%e' AND w.status = 0", PlayerInfo [ playerid ] [ pName ]);
    mysql_tquery (dbHandle, query, "CONTAINER_getPlayer", "i", playerid);

    PTD_container[playerid][0] = CreatePlayerTextDraw(playerid, 312.000000, 173.000000, "_");
	PlayerTextDrawFont(playerid, PTD_container[playerid][0], 1);
	PlayerTextDrawLetterSize(playerid, PTD_container[playerid][0], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, PTD_container[playerid][0], 400.000000, 365.500000);
	PlayerTextDrawSetOutline(playerid, PTD_container[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, PTD_container[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, PTD_container[playerid][0], 2);
	PlayerTextDrawColor(playerid, PTD_container[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, PTD_container[playerid][0], 255);
	PlayerTextDrawBoxColor(playerid, PTD_container[playerid][0], 50);
	PlayerTextDrawUseBox(playerid, PTD_container[playerid][0], 0);
	PlayerTextDrawSetProportional(playerid, PTD_container[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, PTD_container[playerid][0], 0);

	PTD_container[playerid][1] = CreatePlayerTextDraw(playerid, 312.000000, 196.000000, "LAST STAVKA");
	PlayerTextDrawFont(playerid, PTD_container[playerid][1], 1);
	PlayerTextDrawLetterSize(playerid, PTD_container[playerid][1], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, PTD_container[playerid][1], 400.000000, 365.500000);
	PlayerTextDrawSetOutline(playerid, PTD_container[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, PTD_container[playerid][1], 0);
	PlayerTextDrawAlignment(playerid, PTD_container[playerid][1], 2);
	PlayerTextDrawColor(playerid, PTD_container[playerid][1], -1);
	PlayerTextDrawBackgroundColor(playerid, PTD_container[playerid][1], 255);
	PlayerTextDrawBoxColor(playerid, PTD_container[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, PTD_container[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, PTD_container[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, PTD_container[playerid][1], 0);

	PTD_container[playerid][2] = CreatePlayerTextDraw(playerid, 312.000000, 219.000000, "_");
	PlayerTextDrawFont(playerid, PTD_container[playerid][2], 1);
	PlayerTextDrawLetterSize(playerid, PTD_container[playerid][2], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, PTD_container[playerid][2], 400.000000, 365.500000);
	PlayerTextDrawSetOutline(playerid, PTD_container[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, PTD_container[playerid][2], 0);
	PlayerTextDrawAlignment(playerid, PTD_container[playerid][2], 2);
	PlayerTextDrawColor(playerid, PTD_container[playerid][2], -1);
	PlayerTextDrawBackgroundColor(playerid, PTD_container[playerid][2], 255);
	PlayerTextDrawBoxColor(playerid, PTD_container[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, PTD_container[playerid][2], 0);
	PlayerTextDrawSetProportional(playerid, PTD_container[playerid][2], 1);
	PlayerTextDrawSetSelectable(playerid, PTD_container[playerid][2], 0);
    return 1;
}

stock Container:disconnect (playerid)
{
    for (new i = 0; i < 3; i ++)
        PlayerTextDrawDestroy (playerid, PTD_container [ playerid ] [ i ]);
    
    return 1;
}

stock Container:destroy (containerId)
{
    if (IsValidDynamicObject (ContainerInfo [ containerId ] [ cObject ]))
        DestroyDynamicObject (ContainerInfo [ containerId ] [ cObject ]);
    
    if (IsValidDynamic3DTextLabel (ContainerInfo [ containerId ] [ cLabel ]))
        DestroyDynamic3DTextLabel (ContainerInfo [ containerId ] [ cLabel ]);
    
    if (IsValidDynamicArea (ContainerInfo [ containerId ] [ cArea ]))
   		DestroyDynamicArea (ContainerInfo [ containerId ] [ cArea ]);

    ContainerInfo [ containerId ] [ cObject ] = INVALID_OBJECT_ID;
    ContainerInfo [ containerId ] [ cLabel ] = Text3D:INVALID_3DTEXT_ID;

    ContainerInfo [ containerId ] [ cLastStavkaCash ] =
    ContainerInfo [ containerId ] [ cStavkaTotal ] =
    ContainerInfo [ containerId ] [ cArea ] = 0;
 
    ContainerInfo [ containerId ] [ cLastStavka ] [ 0 ] = EOS;
    
    if (ContainerInfo [ containerId ] [ cID ] > 0)
    {
        new query [ 128 ];

        mysql_format (dbHandle, query, sizeof query, "DELETE FROM "TABLE_CONTAINER_BID" WHERE containerId=%i", ContainerInfo [ containerId ] [ cID ]);
        mysql_tquery (dbHandle, query);
    
        mysql_format (dbHandle, query, sizeof query, "DELETE FROM "TABLE_CONTAINER" WHERE id=%i", ContainerInfo [ containerId ] [ cID ]);
        mysql_tquery (dbHandle, query);
    }


    return 1;
}

stock Container:update (containerId)
{
    new text [ 128 ],
        mm = ContainerInfo [ containerId ] [ cTime ] / 60,
        ss = ContainerInfo [ containerId ] [ cTime ] % 60,
        type_name [ 32 ];

    Container:getTypeName (ContainerInfo [ containerId ] [ cType ], type_name);

    format (text, sizeof text, "%s контейнер\nСтавка: %i\nДо конца: %02d:%02d",
        type_name,
        ContainerInfo [ containerId ] [ cStartPrice ],
        mm,
        ss
    );

    if (IsValidDynamic3DTextLabel (ContainerInfo [ containerId ] [ cLabel ]))
        UpdateDynamic3DTextLabelText (ContainerInfo [ containerId ] [ cLabel ], 0xFFCC00FF, text);

    Container:updateTD (containerId);
    return 1;
}

stock Container:create (i)
{
    ContainerInfo [ i ] [ cObject ] =
		CreateDynamicObject (ContainerInfo [ i ] [ cModel ], ContainerInfo [ i ] [ cPosX ],  ContainerInfo [ i ] [ cPosY ], ContainerInfo [ i ] [ cPosZ ], ContainerInfo [ i ] [ cPosRX ], ContainerInfo [ i ] [ cPosRY ], ContainerInfo [ i ] [ cPosRZ ], ContainerInfo [ i ] [ cVW ], ContainerInfo [ i ] [ cInt ]);

    ContainerInfo [ i ] [ cLabel ] = 
        CreateDynamic3DTextLabel ("_", 0xFFCC00FF, ContainerInfo [ i ] [ cPosX ], ContainerInfo [ i ] [ cPosY ], ContainerInfo [ i ] [ cPosZ ], 20.0, .worldid=ContainerInfo [ i ] [ cVW ], .interiorid=ContainerInfo [ i ] [ cInt ]);
        
    ContainerInfo [ i ] [ cArea ] = 
        CreateDynamicSphere (ContainerInfo [ i ] [ cPosX ], ContainerInfo [ i ] [ cPosY ], ContainerInfo [ i ] [ cPosZ ], 4.0, ContainerInfo [ i ] [ cVW ], ContainerInfo [ i ] [ cInt ]);
        
    Streamer_SetIntData (STREAMER_TYPE_AREA, ContainerInfo [ i ] [ cArea ], E_STREAMER_EXTRA_ID, i);
    return 1;
}

stock Container:getTypeName (sqlid, name[], size = sizeof (name))
{
    for (new i = 0; i < MAX_CONTAINER_TYPE; i ++)
    {
        if (ContainerType [ i ] [ ctID ] != sqlid)
            continue;
        
        strmid (name, ContainerType [ i ] [ ctName ], 0, size, size);
        return 1;
    }

    strmid (name, "Неизвестный", 0, size, size);
    return 0;
}

stock Container:updateTD (containerId)
{
    foreach (Player, i)
    {
        if (!PlayerInfo [ i ] [ tOpenContainer ] || PlayerInfo [ i ] [ tLastArea ] != ContainerInfo [ containerId ] [ cArea ])
            continue;
        
        Container:updatePlayerTD (i, containerId);
    }
    return 1;
}

stock Container:updatePlayerTD (playerid, containerId)
{
    #if defined debug_server
        SendClientMessageEx (playerid, -1, "[Container:updatePlayerTD] containerId:%i", containerId);
    #endif

    new text [ 128 ],
        mm = ContainerInfo [ containerId ] [ cTime ] / 60,
        ss = ContainerInfo [ containerId ] [ cTime ] % 60;

    format (text, sizeof text, "Время: %02d:%02d", mm, ss);
    PlayerTextDrawSetString (playerid, PTD_container [ playerid ] [ 0 ], TranslateText (text));

    if (strlen (ContainerInfo [ containerId ] [ cLastStavka ]) < 3)
        format (text, sizeof text, "Ваша ставка будет первой");
    else
        format (text, sizeof text, "Последняя ставка %s", ContainerInfo [ containerId ] [ cLastStavka ]);
        
    PlayerTextDrawSetString (playerid, PTD_container [ playerid ] [ 1 ], TranslateText (text));
    return 1;
}

stock Container:updatePlayerChange (playerid, extraId)
{
    new query [ 256 ];
    mysql_format (dbHandle, query, sizeof query,
        "SELECT (SELECT SUM(`count`) FROM "TABLE_CONTAINER_BID" WHERE containerId = %i) AS total, \
        (SELECT SUM(`count`) FROM "TABLE_CONTAINER_BID" WHERE containerId = %i AND `username` = '%s') AS my_sum",
        ContainerInfo [ extraId ] [ cID ],
        ContainerInfo [ extraId ] [ cID ],
        PlayerInfo [ playerid ] [ pName ]
    );

    mysql_tquery (dbHandle, query, "CONTAINER_loadPercent", "ii", playerid, extraId);
    return 1;
}

stock Container:enterArea (playerid, areaid, extraId)
{
    if ((extraId >= 0 && extraId < MAX_CONTAINER) && ContainerInfo [ extraId ] [ cArea ] == areaid && ContainerInfo [ extraId ] [ cID ] != 0)
	{
        Container:updatePlayerTD (playerid, extraId);

        for (new i = 0; i < sizeof (PTD_container[]); i ++)
            PlayerTextDrawShow (playerid, PTD_container [ playerid ] [ i ]);

        Container:updatePlayerChange (playerid, extraId);
        PlayerInfo [ playerid ] [ tOpenContainer ] = true;
        return 1;
    }

    return 0;
}

stock Container:exitArea (playerid)
{
    for (new i = 0; i < sizeof (PTD_container[]); i ++)
        PlayerTextDrawHide (playerid, PTD_container [ playerid ] [ i ]);
    
    PlayerInfo [ playerid ] [ tOpenContainer ] = false;
    return 1;
}

stock Container:log (const text[])
{
	new query [ 1024 ];

	mysql_format (dbHandle, query, sizeof query, "INSERT INTO "TABLE_CONTAINER_LOG" (`text`,createdAt) VALUES ('%e',%d)", text, gettime());
	mysql_tquery (dbHandle, query);
    
    return 1;
}