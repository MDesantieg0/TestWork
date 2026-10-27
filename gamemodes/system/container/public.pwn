forward Container:timer();
public Container:timer()
{
    for (new i = 0; i < MAX_CONTAINER; i ++)
    {
        if (ContainerInfo [ i ] [ cID ] <= 0 || ContainerInfo [ i ] [ cTime ] <= 0)
            continue;
        
        ContainerInfo [ i ] [ cTime ] --;
        
        if (ContainerInfo [ i ] [ cTime ] <= 0)
        {
            new query [ 128 ];
            mysql_format (dbHandle, query, sizeof query, "SELECT * FROM "TABLE_CONTAINER_BID" WHERE containerId = %i", ContainerInfo [ i ] [ cID ]);
            mysql_tquery (dbHandle, query, "CONTAINER_winner", "i", i);
            return 1;
        }
        
        Container:update (i);
    }

    return 1;
}

forward Container:loadType ();
public Container:loadType ()
{
    new rows = cache_num_rows (),
	    time = GetTickCount (),
		total;

	if (!rows)
	{
	    print ("[Container:loadType] Записи не найдены.");
	    return 1;
	}

	for (new i = 0; i < rows; i++)
	{
        cache_get_value_name_int (i, "id", ContainerType [ i ] [ ctID ]);
        cache_get_value_name (i, "typeName", ContainerType [ i ] [ ctName ]);
        //printf ("%i %i %s",ContainerType [ i ] [ ctID ], i, ContainerType [ i ] [ ctName ]);
        total ++;
	}

	printf ("[Container:loadType] Строк - %i. Загружено - %i. Затрачено: %i ms.", rows, total, GetTickCount()-time);
    return 1;
}

forward Container:load ();
public Container:load ()
{
    new rows = cache_num_rows (),
	    time = GetTickCount (),
		total;

	if (!rows)
	{
	    print ("[Container:load] Записи не найдены.");
	    return 1;
	}

	for (new i = 0; i < rows; i++)
	{
        cache_get_value_name_int (i, "id", ContainerInfo [ i ] [ cID ]);
        cache_get_value_name_int (i, "cType", ContainerInfo [ i ] [ cType ]);

        cache_get_value_name_int (i, "cModel", ContainerInfo [ i ] [ cModel ]);

        cache_get_value_name_float (i, "cPosX", ContainerInfo [ i ] [ cPosX ]);
        cache_get_value_name_float (i, "cPosY", ContainerInfo [ i ] [ cPosY ]);
        cache_get_value_name_float (i, "cPosZ", ContainerInfo [ i ] [ cPosZ ]);
        cache_get_value_name_float (i, "cPosRX", ContainerInfo [ i ] [ cPosRX ]);
        cache_get_value_name_float (i, "cPosRY", ContainerInfo [ i ] [ cPosRY ]);
        cache_get_value_name_float (i, "cPosRZ", ContainerInfo [ i ] [ cPosRZ ]);

        cache_get_value_name_int (i, "cVW", ContainerInfo [ i ] [ cVW ]);
        cache_get_value_name_int (i, "cInt", ContainerInfo [ i ] [ cInt ]);

        cache_get_value_name_int (i, "cTime", ContainerInfo [ i ] [ cTime ]);
        cache_get_value_name_int (i, "cStartPrice", ContainerInfo [ i ] [ cStartPrice ]);

        new query [ 128 ];
        mysql_format (dbHandle, query, sizeof query, "DELETE FROM "TABLE_CONTAINER_BID" WHERE containerId=%i", ContainerInfo [ i ] [ cID ]);
        mysql_tquery (dbHandle, query);

        Container:create (i);

		total ++;
	}

	printf ("[Container:load] Строк - %i. Загружено - %i. Затрачено: %i ms.", rows, total, GetTickCount()-time);
    return 1;
}

forward Container:winner (containerId);
public Container:winner (containerId)
{
    new text [ 256 ],
        rows = cache_num_rows();
    
    if (!rows)
    {
        format (text, sizeof text, "Аукцион на контейнер #%i завершился без ставок.", ContainerInfo [ containerId ] [ cID ]);
        Container:log (text);

        Container:destroy (containerId);
        return 1;
    }

    new win_number = random (ContainerInfo [ containerId ] [ cStavkaTotal ]),
        win_name [ MAX_PLAYER_NAME ],
        now_number = 0;
    
    for (new i = 0; i < rows; i++)
    {
        new count;
        cache_get_value_name_int (i, "count", count);
        now_number += count;

        if (win_number < now_number)
        {
            cache_get_value_name (i, "username", win_name);
            break;
        }
    }

    format (text, sizeof text, "Победитель контейнера #%i - %s (%i число)", ContainerInfo [ containerId ] [ cID ], win_name, win_number);
    
    SendClientMessageToAll (0xFFFFFFFF, text);
    Container:log (text);

    //Container:destroy (containerId);

    mysql_format (dbHandle, text, sizeof text, "SELECT * FROM "TABLE_CONTAINER_LOOT" WHERE iLootType=%i", ContainerInfo [ containerId ] [ cType ]);
    mysql_tquery (dbHandle, text, "CONTAINER_getWinLoot", "is", containerId, win_name);
    return 1;
}

forward Container:getWinLoot (containerId, const win_name[]);
public Container:getWinLoot (containerId, const win_name[])
{
    new text [ 256 ],
        rows = cache_num_rows();
    
    if (!rows)
    {
        format (text, sizeof text, "А призы то и не выставленны в тип #%i", ContainerInfo [ containerId ] [ cID ]);
        Container:log (text);

        Container:destroy (containerId);
        return 1;
    }

    new lootID [ 64 ],
        lootName [ 64 ] [ 32 ],
        lootAmount [ 64 ],
        Float:lootPercent [ 64 ],
        Float:total = 0.0;

    if (rows > 64) rows = 64;

    for (new i = 0; i < rows; i ++)
    {
        cache_get_value_name_int (i, "id", lootID [ i ]);
        cache_get_value_name (i, "iName", lootName [ i ]);
        cache_get_value_name_int (i, "iAmount", lootAmount [ i ]);
        cache_get_value_name_float (i, "iPercent", lootPercent [ i ]);

        total += lootPercent [ i ];
    }

    if (total <= 0.0)
    {
        format (text, sizeof text, "Тип #%i: суммарный шанс = 0", ContainerInfo [ containerId ] [ cID ]);
        Container:log (text);

        Container:destroy (containerId);
        return 1;
    }

    new Float:roll = frand (total);

    new winIndex = -1,
        Float:acc = 0.0;

    for (new i = 0; i < rows; i ++)
    {
        acc += lootPercent [ i ];
        if (roll < acc)
        {
            winIndex = i;
            break;
        }
    }

    if (winIndex == -1) winIndex = rows - 1;

    format (text, sizeof text,
        "Тип #%i: выпал предмет %s x%i (шанс %.2f%% из %.2f%%)",
        ContainerInfo [ containerId ] [ cID ],
        lootName [ winIndex ],
        lootAmount [ winIndex ],
        lootPercent [ winIndex ],
        total
    );
    Container:log (text);

    new bool: isPlayerOnline = false;
    foreach (Player, i)
    {
        if (strcmp (PlayerInfo [ i ] [ pName ], win_name, false))
            continue;

        isPlayerOnline = true;
        SendClientMessageEx (i, -1, "Вы получили %s x%i", lootName [ winIndex ], lootAmount [ winIndex ]);
        break;
    }

    if (!isPlayerOnline)
    {
        mysql_format (dbHandle, text, sizeof text, "INSERT INTO "TABLE_CONTAINER_WIN" (`username`,lootid,conteinerId) VALUES ('%e',%i,%i)",
            win_name,
            lootID [ winIndex ],
            ContainerInfo [ containerId ] [ cID ]
        );
        mysql_tquery (dbHandle, text);
    }

    Container:destroy (containerId);
    return 1;
}

forward Container:insert (index);
public Container:insert (index)
{
    ContainerInfo [ index ] [ cID ] = cache_insert_id();
    
    Container:create (index);
    
    new query [ 128 ];
    format (query, sizeof query, "Стартовал аукцион на контейнер #%i", ContainerInfo [ index ] [ cID ]);
    Container:log (query);
    return 1;
}

forward Container:loadPercent (playerid, containerId);
public Container:loadPercent (playerid, containerId)
{
    if (!cache_num_rows())
        return 1;
    
    new total,
        my_sum;

    cache_get_value_name_int (0, "total", total);
    cache_get_value_name_int (0, "my_sum", my_sum);

    if (total <= 0)
    {
        PlayerTextDrawSetString (playerid, PTD_container [ playerid ] [ 2 ], TranslateText ("Мой шанс победить: 0%"));
        return 1;
    }

    new Float:chance = (float (my_sum) / float (total)) * 100.0;
    
    #if defined debug_server
        SendClientMessageEx (playerid, -1, "[Container:loadPercent] total:%i, my_sum:%i, chance:%.02f", total, my_sum, chance);
    #endif

    new text [ 128 ];
    format (text, sizeof text, "Мой шанс победить: %0.2f%%", chance);
    PlayerTextDrawSetString (playerid, PTD_container [ playerid ] [ 2 ], TranslateText (text));
    return 1;
}

forward Container:getPlayer (playerid);
public Container:getPlayer (playerid)
{
    new rows = cache_num_rows();
    
    if (!rows)
        return 1;
    
    new query [ 256 ];

    for (new i = 0; i < rows; i ++)
    {
        new itemname [ 32 ],
            lootid,
            amount;
        
        cache_get_value_name_int (i, "lootid", lootid);
        cache_get_value_name_int (i, "iAmount", amount);
    
        cache_get_value_name (i, "iName", itemname);
        
        SendClientMessageEx (playerid, -1, "Вы выйграли один из аукционов и получили %s x%i", itemname, amount);
    }
    
    mysql_format (dbHandle, query, sizeof query, "DELETE FROM "TABLE_CONTAINER_WIN" WHERE username='%e'", PlayerInfo [ playerid ] [ pName ]);
    mysql_tquery (dbHandle, query);
    return 1;
}