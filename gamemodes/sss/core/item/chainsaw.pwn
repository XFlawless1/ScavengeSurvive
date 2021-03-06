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


#define INVALID_TREE_INDEX      (-1)

new
	tr_LastTreeIndex[MAX_PLAYERS] = {INVALID_TREE_INDEX, ...};


public OnPlayerEnterTreeArea(playerid, treeid)
{
	if(!IsValidTree(treeid))
		return 0;

	tr_LastTreeIndex[playerid] = treeid;
	return 1;
}
public OnPlayerLeaveTreeArea(playerid, treeid)
{
	if(!IsValidTree(treeid))
		return 0;
		
	tr_LastTreeIndex[playerid] = INVALID_TREE_INDEX;
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	tr_LastTreeIndex[playerid] = INVALID_TREE_INDEX;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/chainsaw.pwn");

	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(tr_LastTreeIndex[playerid] == INVALID_TREE_INDEX)
		return 0;

	new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

	if(itemtype != GetTreeSpeciesHarvestItem(GetTreeSpecies(tr_LastTreeIndex[playerid])))
		return 0;

	if(itemtype == item_Chainsaw && GetItemWeaponItemMagAmmo(GetPlayerItem(playerid)) <= 0)
	{
		ShowActionText(playerid, ls(playerid, "CHAINSAFUEL"), 5000);
		return 0;
	}

	if(newkeys == 16)
	{
		_StartWoodCutting(playerid, tr_LastTreeIndex[playerid]);
	}
	if(oldkeys == 16)
	{
		_StopWoodCutting(playerid);
	}

	return 1;
}

hook OnHoldActionUpdate(playerid, progress)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionUpdate] in /gamemodes/sss/core/item/chainsaw.pwn");

	if(tr_LastTreeIndex[playerid] != INVALID_TREE_INDEX)
	{
		new
			t_Index = tr_LastTreeIndex[playerid];
			
		if(!IsValidTree(t_Index))
		{
			_StopWoodCutting(playerid);
			tr_LastTreeIndex[playerid] = INVALID_TREE_INDEX;
			return 1;
		}

		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype != GetTreeSpeciesHarvestItem(GetTreeSpecies(t_Index)))
		{
			_StopWoodCutting(playerid);
			return 1;
		}

		if(itemtype == item_Chainsaw)
		{
			new ammo = GetItemWeaponItemMagAmmo(itemid);

			if(ammo <= 0)
			{
				_StopWoodCutting(playerid);
				return 1;
			}

			if(floatround(GetPlayerProgressBarValue(playerid, ActionBar) * 10) % 60 == 0)
				_FireWeapon(playerid, WEAPON_CHAINSAW);
		}

		SetTreeHealth(t_Index, GetTreeHealth(t_Index) - (GetTreeSpeciesChopDamage(GetTreeSpecies(t_Index)) / 10) ); // divide it by 10, because it gets called every 100 mseconds not 1000

		if(GetTreeHealth(t_Index) <= 0.0)
		{
			LeanTree(t_Index);
			_StopWoodCutting(playerid);
			tr_LastTreeIndex[playerid] = INVALID_TREE_INDEX;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_StartWoodCutting(playerid, treeid)
{
	new
		start 	= (1000 * floatround(GetTreeSpeciesMaxHealth(GetTreeSpecies(treeid))) ) 	/  floatround(GetTreeSpeciesChopDamage(GetTreeSpecies(treeid))),
		end 	= (1000 * floatround(GetTreeHealth(treeid))) 								/  floatround(GetTreeSpeciesChopDamage(GetTreeSpecies(treeid)));
	
	StartHoldAction(playerid, start, start - end);
	
	SetPlayerToFaceTree(playerid, treeid);
	ApplyAnimation(playerid, "CHAINSAW", "CSAW_G", 4.0, 1, 0, 0, 0, 0, 1);
	
}

_StopWoodCutting(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);
}
