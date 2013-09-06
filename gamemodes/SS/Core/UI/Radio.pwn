#include <YSI\y_hooks>


#define MAX_RADIO_FREQ (108.0)
#define MIN_RADIO_FREQ (87.5)


static
	rad_InventoryItem[MAX_PLAYERS],
	rad_ViewingRadio[MAX_PLAYERS],
	rad_OldMode[MAX_PLAYERS],
	PlayerText:RadioUI_Main[MAX_PLAYERS],
	PlayerText:RadioUI_Strip[MAX_PLAYERS],
	PlayerText:RadioUI_KnobL[MAX_PLAYERS],
	PlayerText:RadioUI_KnobR[MAX_PLAYERS],
	PlayerText:RadioUI_Mode[MAX_PLAYERS],
	PlayerText:RadioUI_Freq[MAX_PLAYERS],
	PlayerText:RadioUI_Power[MAX_PLAYERS],
	PlayerText:RadioUI_Back[MAX_PLAYERS];


ShowRadioUI(playerid)
{
	PlayerTextDrawShow(playerid, RadioUI_Main[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Strip[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_KnobL[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_KnobR[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Mode[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Freq[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Power[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Back[playerid]);

	SelectTextDraw(playerid, 0xFFFFFF88);
	UpdateRadioUI(playerid);

	rad_ViewingRadio[playerid] = true;
}

HideRadioUI(playerid)
{
	PlayerTextDrawHide(playerid, RadioUI_Main[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Strip[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_KnobL[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_KnobR[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Mode[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Freq[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Power[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Back[playerid]);

	if(!IsPlayerInAnyVehicle(playerid))
		DisplayPlayerInventory(playerid);

	else
		CancelSelectTextDraw(playerid);

	rad_ViewingRadio[playerid] = false;
}

UpdateRadioUI(playerid)
{
	new str[18];

	format(str, 18, "Frequency: %.2f", GetPlayerRadioFrequency(playerid));
	PlayerTextDrawSetString(playerid, RadioUI_Freq[playerid], str);

	if(GetPlayerChatMode(playerid) == CHAT_MODE_LOCAL)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Power[playerid], "off");

		if(rad_OldMode[playerid] == CHAT_MODE_GLOBAL)
			PlayerTextDrawSetString(playerid, RadioUI_Mode[playerid], "global");

		else
			PlayerTextDrawSetString(playerid, RadioUI_Mode[playerid], "freq");
	}

	if(GetPlayerChatMode(playerid) == CHAT_MODE_GLOBAL)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Mode[playerid], "global");
		PlayerTextDrawSetString(playerid, RadioUI_Power[playerid], "on");
	}

	if(GetPlayerChatMode(playerid) == CHAT_MODE_RADIO)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Mode[playerid], "freq");
		PlayerTextDrawSetString(playerid, RadioUI_Power[playerid], "on");
	}
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:clickedid)
{
	if(clickedid == RadioUI_KnobL[playerid])
	{
		SetPlayerRadioFrequency(playerid, GetPlayerRadioFrequency(playerid) - 0.5);

		if(GetPlayerRadioFrequency(playerid) > MAX_RADIO_FREQ)
			SetPlayerRadioFrequency(playerid, MIN_RADIO_FREQ);

		UpdateRadioUI(playerid);
	}
	if(clickedid == RadioUI_KnobR[playerid])
	{
		SetPlayerRadioFrequency(playerid, GetPlayerRadioFrequency(playerid) + 0.5);

		if(GetPlayerRadioFrequency(playerid) < MIN_RADIO_FREQ)
			SetPlayerRadioFrequency(playerid, MAX_RADIO_FREQ);

		UpdateRadioUI(playerid);
	}
	if(clickedid == RadioUI_Mode[playerid])
	{
		if(GetPlayerChatMode(playerid) == CHAT_MODE_GLOBAL)
			SetPlayerChatMode(playerid, CHAT_MODE_RADIO);

		else if(GetPlayerChatMode(playerid) == CHAT_MODE_RADIO)
			SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL);

		UpdateRadioUI(playerid);
	}
	if(clickedid == RadioUI_Freq[playerid])
	{
		ShowPlayerDialog(playerid, d_Radio, DIALOG_STYLE_INPUT, "Frequency", "Enter a frequency between 87.5 and 108.0", "Accept", "Cancel");
	}
	if(clickedid == RadioUI_Power[playerid])
	{
		if(GetPlayerChatMode(playerid) == CHAT_MODE_LOCAL)
		{
			if(rad_OldMode[playerid] == CHAT_MODE_GLOBAL)
				SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL);

			else
				SetPlayerChatMode(playerid, CHAT_MODE_RADIO);
		}
		else
		{
			rad_OldMode[playerid] = GetPlayerChatMode(playerid);
			SetPlayerChatMode(playerid, CHAT_MODE_LOCAL);
		}

		UpdateRadioUI(playerid);
	}
	if(clickedid == RadioUI_Back[playerid])
	{
		HideRadioUI(playerid);
	}
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Radio)
	{
		if(response)
		{
			new Float:frequency;
			if(!sscanf(inputtext, "f", frequency))
			{
				if(MIN_RADIO_FREQ < frequency < MAX_RADIO_FREQ)
				{
					SetPlayerRadioFrequency(playerid, frequency);
					UpdateRadioUI(playerid);
				}
				else
				{
					ShowPlayerDialog(playerid, d_Radio, DIALOG_STYLE_INPUT, "Frequency", "Enter a frequency between 87.5 and 108.0", "Accept", "Cancel");
				}
			}
			else
			{
				ShowPlayerDialog(playerid, d_Radio, DIALOG_STYLE_INPUT, "Frequency", "Enter a frequency between 87.5 and 108.0", "Accept", "Cancel");
			}
		}
	}

	return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(rad_ViewingRadio[playerid])
		{
			SelectTextDraw(playerid, 0xFFFFFF88);
		}
	}
}


public OnPlayerOpenInventory(playerid)
{
	rad_InventoryItem[playerid] = AddInventoryListItem(playerid, "Radio");

	return CallLocalFunction("rad_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory rad_OnPlayerOpenInventory
forward OnPlayerOpenInventory(playerid);

public OnPlayerSelectExtraItem(playerid, item)
{
	if(item == rad_InventoryItem[playerid])
	{
		ShowRadioUI(playerid);
	}

	return CallLocalFunction("rad_OnPlayerSelectExtraItem", "dd", playerid, item);
}
#if defined _ALS_OnPlayerSelectExtraItem
	#undef OnPlayerSelectExtraItem
#else
	#define _ALS_OnPlayerSelectExtraItem
#endif
#define OnPlayerSelectExtraItem rad_OnPlayerSelectExtraItem
forward OnPlayerSelectExtraItem(playerid, item);


hook OnPlayerConnect(playerid)
{
	RadioUI_Main[playerid]					= CreatePlayerTextDraw(playerid, 320.000000, 200.000000, "RADIO~n~ ~n~ ~n~ ~n~ ~n~ ");
	PlayerTextDrawAlignment			(playerid, RadioUI_Main[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Main[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Main[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Main[playerid], 0.500000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Main[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Main[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Main[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Main[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Main[playerid], 100);
	PlayerTextDrawTextSize			(playerid, RadioUI_Main[playerid], 0.000000, 200.000000);

	RadioUI_Strip[playerid]					= CreatePlayerTextDraw(playerid, 320.000000, 220.000000, "-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-");
	PlayerTextDrawAlignment			(playerid, RadioUI_Strip[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Strip[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Strip[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Strip[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_Strip[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Strip[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Strip[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Strip[playerid], 0);

	RadioUI_KnobL[playerid]					= CreatePlayerTextDraw(playerid, 220.000000, 203.000000, "LD_DRV:nawtxt");
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_KnobL[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_KnobL[playerid], 4);
	PlayerTextDrawLetterSize		(playerid, RadioUI_KnobL[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_KnobL[playerid], 0x780000FA);
	PlayerTextDrawSetOutline		(playerid, RadioUI_KnobL[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_KnobL[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_KnobL[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_KnobL[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_KnobL[playerid], 30.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_KnobL[playerid], true);

	RadioUI_KnobR[playerid]					= CreatePlayerTextDraw(playerid, 390.000000, 203.000000, "LD_DRV:nawtxt");
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_KnobR[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_KnobR[playerid], 4);
	PlayerTextDrawLetterSize		(playerid, RadioUI_KnobR[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_KnobR[playerid], 0x780000FA);
	PlayerTextDrawSetOutline		(playerid, RadioUI_KnobR[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_KnobR[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_KnobR[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_KnobR[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_KnobR[playerid], 30.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_KnobR[playerid], true);

	RadioUI_Mode[playerid]					= CreatePlayerTextDraw(playerid, 238.000000, 251.000000, "global");
	PlayerTextDrawAlignment			(playerid, RadioUI_Mode[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Mode[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Mode[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Mode[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Mode[playerid], 16777215);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Mode[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Mode[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Mode[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Mode[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Mode[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Mode[playerid], 20.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Mode[playerid], true);

	RadioUI_Freq[playerid]					= CreatePlayerTextDraw(playerid, 320.000000, 251.000000, "Frequency: 00.00");
	PlayerTextDrawAlignment			(playerid, RadioUI_Freq[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Freq[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Freq[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Freq[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Freq[playerid], 16777215);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Freq[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Freq[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Freq[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Freq[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Freq[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Freq[playerid], 20.000000, 120.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Freq[playerid], true);

	RadioUI_Power[playerid]					= CreatePlayerTextDraw(playerid, 402.000000, 251.000000, "off");
	PlayerTextDrawAlignment			(playerid, RadioUI_Power[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Power[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Power[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Power[playerid], 0.400000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Power[playerid], -16776961);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Power[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Power[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Power[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Power[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Power[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Power[playerid], 20.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Power[playerid], true);

	RadioUI_Back[playerid]					= CreatePlayerTextDraw(playerid, 320.000000, 274.000000, "Close");
	PlayerTextDrawAlignment			(playerid, RadioUI_Back[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Back[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Back[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Back[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Back[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Back[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Back[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Back[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Back[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Back[playerid], 100);
	PlayerTextDrawTextSize			(playerid, RadioUI_Back[playerid], 20.000000, 200.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Back[playerid], true);

	rad_ViewingRadio[playerid] = 0;
}
