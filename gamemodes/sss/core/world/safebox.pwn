
/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


#define MAX_SAFEBOX_TYPE	(8)
#define MAX_SAFEBOX_NAME	(32)


enum E_SAFEBOX_TYPE_DATA
{
ItemType:	box_itemtype,
			box_size
}

enum
{
			E_BOX_LEGACY_NULL,
			E_BOX_CONTAINER_ID,
			E_BOX_GEID
}


new
			box_SkipGEID;

static
			box_GEID_Index,
			box_GEID[ITM_MAX],
			box_TypeData[MAX_SAFEBOX_TYPE][E_SAFEBOX_TYPE_DATA],
			box_TypeTotal,
			box_ItemTypeBoxType[ITM_MAX_TYPES] = {-1, ...},
			box_ContainerSafebox[CNT_MAX];

static
			box_CurrentBoxItem[MAX_PLAYERS];

static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'safebox'...");

	if(box_GEID_Index > 0)
	{
		printf("ERROR: box_GEID_Index has been modified prior to loading safeboxes.");
		for(;;){}
	}

	for(new i; i < CNT_MAX; i++)
		box_ContainerSafebox[i] = INVALID_ITEM_ID;

	HANDLER = debug_register_handler("safebox", 4);
}

hook OnScriptExit()
{
	new ret;

	foreach(new i : itm_Index)
	{
		ret = CheckForDuplicateGEID(i);

		if(ret > 0)
			printf("[EXIT] BOX %d (GEID: %d) DUPLICATE ID RETURN: %d", i, box_GEID[i], ret);
	}
}

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/world/safebox.pwn");

	box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core

==============================================================================*/


DefineSafeboxType(ItemType:itemtype, size)
{
	if(box_TypeTotal == MAX_SAFEBOX_TYPE)
		return -1;

	SetItemTypeMaxArrayData(itemtype, 2);

	box_TypeData[box_TypeTotal][box_itemtype]	= itemtype;
	box_TypeData[box_TypeTotal][box_size]		= size;

	box_ItemTypeBoxType[itemtype] = box_TypeTotal;

	return box_TypeTotal++;
}


/*==============================================================================

	Internal

==============================================================================*/


hook OnItemCreate(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreate] in /gamemodes/sss/core/world/safebox.pwn");

	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new
				name[ITM_MAX_NAME],
				containerid;

			GetItemTypeName(itemtype, name);

			containerid = CreateContainer(name, box_TypeData[box_ItemTypeBoxType[itemtype]][box_size]);

			box_ContainerSafebox[containerid] = itemid;

			if(!box_SkipGEID)
			{
				box_GEID_Index++;
				box_GEID[itemid] = box_GEID_Index;
			}

			SetItemArrayDataSize(itemid, 3);
			SetItemArrayDataAtCell(itemid, containerid, E_BOX_CONTAINER_ID);
			SetItemArrayDataAtCell(itemid, box_GEID[itemid], E_BOX_GEID);
		}
	}
}

hook OnItemCreateInWorld(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreateInWorld] in /gamemodes/sss/core/world/safebox.pwn");

	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
			SetButtonText(GetItemButtonID(itemid), "Hold "KEYTEXT_INTERACT" to pick up~n~Press "KEYTEXT_INTERACT" to open");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemDestroy] in /gamemodes/sss/core/world/safebox.pwn");

	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new containerid = GetItemArrayDataAtCell(itemid, E_BOX_CONTAINER_ID);

			RemoveSafeboxItem(itemid);

			DestroyContainer(containerid);
			box_ContainerSafebox[containerid] = INVALID_ITEM_ID;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Player interaction

==============================================================================*/


hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/world/safebox.pwn");

	if(IsItemTypeSafebox(GetItemType(itemid)))
	{
		if(IsValidContainer(GetPlayerCurrentContainer(playerid)))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(IsItemInWorld(itemid))
			_DisplaySafeboxDialog(playerid, itemid, true);

		else
			_DisplaySafeboxDialog(playerid, itemid, false);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/world/safebox.pwn");

	if(IsItemTypeSafebox(GetItemType(withitemid)))
		_DisplaySafeboxDialog(playerid, withitemid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_DisplaySafeboxDialog(playerid, itemid, animation)
{
	DisplayContainerInventory(playerid, GetItemArrayDataAtCell(itemid, 1));
	box_CurrentBoxItem[playerid] = itemid;

	if(animation)
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);

	else
		CancelPlayerMovement(playerid);
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeSafebox(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(box_ItemTypeBoxType[itemtype] != -1)
		return 1;

	return 0;
}

stock GetContainerSafeboxItem(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_ITEM_ID;

	return box_ContainerSafebox[containerid];
}

stock IsItemTypeExtraDataDependent(ItemType:itemtype)
{
	if(IsItemTypeBag(itemtype))
		return 1;

	if(IsItemTypeSafebox(itemtype))
		return 1;

	if(itemtype == item_Campfire)
		return 1;

	return 0;
}

stock GetSafeboxGEID(itemid)
{
	if(!IsValidItem(itemid))
		return -1;

	if(!IsItemTypeSafebox(GetItemType(itemid)))
		return -1;

	return box_GEID[itemid];
}

stock SetSafeboxGEID(itemid, geid)
{
	if(!IsValidItem(itemid))
		return 0;

	if(!IsItemTypeSafebox(GetItemType(itemid)))
		return 0;

	box_GEID[itemid] = geid;

	return 1;
}

stock GetSafeboxGEIDIndex()
{
	return box_GEID_Index;
}

stock SetSafeboxGEIDIndex(value)
{
	box_GEID_Index = value;
}

CheckForDuplicateGEID(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(!IsItemTypeSafebox(itemtype))
		return -1;

	new count;

	foreach(new i : itm_Index)
	{
		itemtype = GetItemType(i);

		if(!IsItemTypeSafebox(itemtype))
			continue;

		if(i == itemid)
			continue;

		if(box_GEID[i] == box_GEID[itemid])
		{
			box_GEID_Index++;
			box_GEID[i] = box_GEID_Index;
			printf("[WARNING] Item %d has the same GEID as item %d. Assigning new GEID: %d", itemid, i, box_GEID[i]);
			SafeboxSaveCheck(INVALID_PLAYER_ID, itemid);
			SafeboxSaveCheck(INVALID_PLAYER_ID, i);
			count++;
		}
	}

	return count;
}

ACMD:bgeid[3](playerid, params[])
{
	new
		itemid = strval(params),
		ret;

	ret = CheckForDuplicateGEID(itemid);

	if(ret == -1)
		ChatMsg(playerid, YELLOW, " >  ERROR: Specified item is not a safebox type.");

	ChatMsg(playerid, YELLOW, " >  %d safeboxe GEIDs reassigned", ret);

	return 1;
}
