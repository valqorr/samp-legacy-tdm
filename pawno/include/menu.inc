/*
            » Release : valqorr's Menu Text
			» Credits: -
			
			» Functions :
			
			» ShowPlayerMenu(playerid, menuid, iarray[][]);
			» HidePlayerMenu(playerid);
			
			» Callbacks :
			
			» OnMenuItem(playerid, menuid, itemid)
																			  */
															

//==================================[MACRO]=====================================

#define MAX_VAL_MENU (100)

#define this<%0>%1.func \
	%0(%1); public %0(%1)
	
//================================[VARIABLE]====================================

enum e_MENUTEXT {
	Text: e_BACKGROUND,
	Text: e_List[4],
	Text: e_Item[4],
	e_tdID
};

enum e_PLAYER {
	e_NULL,
	e_STATU
};

static
	e_PLAYER: g_iPlayer[MAX_PLAYERS char],
	g_iText[MAX_PLAYERS][e_MENUTEXT];
	
forward OnMenuItem(playerid, menuid, key);
//================================[CALLBACK]====================================

this<OnConnect>playerid.func {
	g_iPlayer{playerid} = e_NULL;
	return 1;
}

this<OnText>playerid,text[].func {
	if((g_iPlayer{playerid} == e_STATU)) {
		PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);
		CallLocalFunction("OnMenuItem", "udd", playerid, g_iText[playerid][e_tdID], strval(text));
		return 0;
	}
	return 1;
}

this<OnKey>playerid,key.func {
	if(key == KEY_FIRE) {
		if((g_iPlayer{playerid} == e_STATU)) {
			HidePlayerMenu(playerid);
		}
	}
	return 1;
}

//===================================[F/S]======================================

ShowPlayerMenu(playerid, menuid, iarray[][]) {
	if((g_iPlayer{playerid} == e_STATU)) {
		HidePlayerMenu(playerid);
	}	
	TextDrawSetString(g_iText[playerid][e_List][0], iarray[0]);
	TextDrawSetString(g_iText[playerid][e_Item][0], iarray[1]);
	
	TextDrawSetString(g_iText[playerid][e_List][1], iarray[2]);
	TextDrawSetString(g_iText[playerid][e_Item][1], iarray[3]);
	
	TextDrawSetString(g_iText[playerid][e_List][2], iarray[4]);
	TextDrawSetString(g_iText[playerid][e_Item][2], iarray[5]);
	
	TextDrawSetString(g_iText[playerid][e_List][3], iarray[6]);
	TextDrawSetString(g_iText[playerid][e_Item][3], iarray[7]);
	
	TextDrawShowForPlayer(playerid, g_iText[playerid][e_BACKGROUND]);
	for(new i, j = 4; i != j; ++i) {
		TextDrawShowForPlayer(playerid, g_iText[playerid][e_List][i]);
		TextDrawShowForPlayer(playerid, g_iText[playerid][e_Item][i]);
	}
	g_iText[playerid][e_tdID] = menuid;
	g_iPlayer{playerid} = e_STATU;
}

HidePlayerMenu(playerid) { 
	g_iPlayer{playerid} = e_NULL;
	TextDrawHideForPlayer(playerid, g_iText[playerid][e_BACKGROUND]);
	for(new i, j = 4; i != j; ++i) {
		TextDrawHideForPlayer(playerid, g_iText[playerid][e_List][i]);
		TextDrawHideForPlayer(playerid, g_iText[playerid][e_Item][i]);
	}
}

LoadTextDraws2(playerid) {
	g_iText[playerid][e_BACKGROUND] = TextDrawCreate(160.000000, 140.000000, "~n~ ~n~ ~n~ ~n~ ~n~");
	TextDrawBackgroundColor(g_iText[playerid][e_BACKGROUND], 255);
	TextDrawFont(g_iText[playerid][e_BACKGROUND], 1);
	TextDrawLetterSize(g_iText[playerid][e_BACKGROUND], 0.500000, 4.000000);
	TextDrawColor(g_iText[playerid][e_BACKGROUND], -1);
	TextDrawSetOutline(g_iText[playerid][e_BACKGROUND], 0);
	TextDrawSetProportional(g_iText[playerid][e_BACKGROUND], 1);
	TextDrawSetShadow(g_iText[playerid][e_BACKGROUND], 1);
	TextDrawUseBox(g_iText[playerid][e_BACKGROUND], 1);
	TextDrawBoxColor(g_iText[playerid][e_BACKGROUND], 150);
	TextDrawTextSize(g_iText[playerid][e_BACKGROUND], 463.000000, 0.000000);
	
	g_iText[playerid][e_List][0] = TextDrawCreate(166.000000, 152.000000, "~r~<!> ~w~Saglik");
	TextDrawBackgroundColor(g_iText[playerid][e_List][0], 255);
	TextDrawFont(g_iText[playerid][e_List][0], 1);
	TextDrawLetterSize(g_iText[playerid][e_List][0], 0.289999, 1.000000);
	TextDrawColor(g_iText[playerid][e_List][0], -1);
	TextDrawSetOutline(g_iText[playerid][e_List][0], 0);
	TextDrawSetProportional(g_iText[playerid][e_List][0], 1);
	TextDrawSetShadow(g_iText[playerid][e_List][0], 1);

	g_iText[playerid][e_List][1] = TextDrawCreate(346.000000, 152.000000, "~r~<!> ~w~Araclar");
	TextDrawBackgroundColor(g_iText[playerid][e_List][1], 255);
	TextDrawFont(g_iText[playerid][e_List][1], 1);
	TextDrawLetterSize(g_iText[playerid][e_List][1], 0.289999, 1.000000);
	TextDrawColor(g_iText[playerid][e_List][1], -1);
	TextDrawSetOutline(g_iText[playerid][e_List][1], 0);
	TextDrawSetProportional(g_iText[playerid][e_List][1], 1);
	TextDrawSetShadow(g_iText[playerid][e_List][1], 1);

	g_iText[playerid][e_List][2] = TextDrawCreate(166.000000, 224.000000, "~r~<!> ~w~Silahlar");
	TextDrawBackgroundColor(g_iText[playerid][e_List][2], 255);
	TextDrawFont(g_iText[playerid][e_List][2], 1);
	TextDrawLetterSize(g_iText[playerid][e_List][2], 0.289999, 1.000000);
	TextDrawColor(g_iText[playerid][e_List][2], -1);
	TextDrawSetOutline(g_iText[playerid][e_List][2], 0);
	TextDrawSetProportional(g_iText[playerid][e_List][2], 1);
	TextDrawSetShadow(g_iText[playerid][e_List][2], 1);

	g_iText[playerid][e_List][3] = TextDrawCreate(346.000000, 224.000000, "~r~<!> ~w~Teleports");
	TextDrawBackgroundColor(g_iText[playerid][e_List][3], 255);
	TextDrawFont(g_iText[playerid][e_List][3], 1);
	TextDrawLetterSize(g_iText[playerid][e_List][3], 0.289999, 1.000000);
	TextDrawColor(g_iText[playerid][e_List][3], -1);
	TextDrawSetOutline(g_iText[playerid][e_List][3], 0);
	TextDrawSetProportional(g_iText[playerid][e_List][3], 1);
	TextDrawSetShadow(g_iText[playerid][e_List][3], 1);
	
	g_iText[playerid][e_Item][0] = TextDrawCreate(188.000000, 164.000000, "~y~-> ~w~Health(~r~$3000~w~)");
	TextDrawBackgroundColor(g_iText[playerid][e_Item][0], 255);
	TextDrawFont(g_iText[playerid][e_Item][0], 1);
	TextDrawLetterSize(g_iText[playerid][e_Item][0], 0.219999, 0.699998);
	TextDrawColor(g_iText[playerid][e_Item][0], -1);
	TextDrawSetOutline(g_iText[playerid][e_Item][0], 0);
	TextDrawSetProportional(g_iText[playerid][e_Item][0], 1);
	TextDrawSetShadow(g_iText[playerid][e_Item][0], 1);

	g_iText[playerid][e_Item][1] = TextDrawCreate(367.000000, 164.000000, "~y~-> ~w~Health(~r~$3000~w~)");
	TextDrawBackgroundColor(g_iText[playerid][e_Item][1], 255);
	TextDrawFont(g_iText[playerid][e_Item][1], 1);
	TextDrawLetterSize(g_iText[playerid][e_Item][1], 0.219999, 0.699998);
	TextDrawColor(g_iText[playerid][e_Item][1], -1);
	TextDrawSetOutline(g_iText[playerid][e_Item][1], 0);
	TextDrawSetProportional(g_iText[playerid][e_Item][1], 1);
	TextDrawSetShadow(g_iText[playerid][e_Item][1], 1);

	g_iText[playerid][e_Item][2] = TextDrawCreate(188.000000, 237.000000, "~y~-> ~w~Health(~r~$3000~w~)");
	TextDrawBackgroundColor(g_iText[playerid][e_Item][2], 255);
	TextDrawFont(g_iText[playerid][e_Item][2], 1);
	TextDrawLetterSize(g_iText[playerid][e_Item][2], 0.219999, 0.699998);
	TextDrawColor(g_iText[playerid][e_Item][2], -1);
	TextDrawSetOutline(g_iText[playerid][e_Item][2], 0);
	TextDrawSetProportional(g_iText[playerid][e_Item][2], 1);
	TextDrawSetShadow(g_iText[playerid][e_Item][2], 1);

	g_iText[playerid][e_Item][3] = TextDrawCreate(367.000000, 237.000000, "~y~-> ~w~Health(~r~$3000~w~)");
	TextDrawBackgroundColor(g_iText[playerid][e_Item][3], 255);
	TextDrawFont(g_iText[playerid][e_Item][3], 1);
	TextDrawLetterSize(g_iText[playerid][e_Item][3], 0.219999, 0.699998);
	TextDrawColor(g_iText[playerid][e_Item][3], -1);
	TextDrawSetOutline(g_iText[playerid][e_Item][3], 0);
	TextDrawSetProportional(g_iText[playerid][e_Item][3], 1);
	TextDrawSetShadow(g_iText[playerid][e_Item][3], 1);
}