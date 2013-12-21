#include <sourcemod>

#define PLUGIN_NAME "Haywire"
#define PLUGIN_AUTHOR "Mihai Ene"
#define PLUGIN_DESCRIPTION "Haywire stats CS:GO plugin"
#define PLUGIN_VERSION "0.1.0"
#define PLUGIN_URL "https://github.com/randunel/sourcemod-haywire"

#define MAX_STEAMID_LENGTH 32
#define MAX_IP_LENGTH 64
#define MAX_MESSAGE_LENGTH 192

public Plugin:myinfo = {
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version = PLUGIN_VERSION,
    url = PLUGIN_URL
};

public OnPluginStart() {
    HookEvents();
}

HookEvents() {
    // This section is from https://wiki.alliedmods.net/Generic_Source_Server_Events
    HookEvent("server_cvar", Handle_server_cvar); // ok
    HookEvent("player_connect", Handle_player_connect); // ok
    HookEvent("player_info", Handle_player_info); // TEST
    HookEvent("player_disconnect", Handle_player_disconnect); // ok
    HookEvent("player_activate", Handle_player_activate); // ok
    HookEvent("player_say", Handle_player_say); // ok
    // This section is from https://wiki.alliedmods.net/Generic_Source_Events
    HookEvent("player_team", Handle_player_team); // ok
    HookEvent("game_start", Handle_game_start); // ok - start of warmup, start of firstround
    HookEvent("game_end", Handle_game_end); // TEST
    //HookEvent("round_start", Handle_round_start); // not working
    HookEvent("break_breakable", Handle_break_breakable); // TEST
    HookEvent("break_prop", Handle_break_prop); // TEST
    // This section is from https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events
    HookEvent("player_death", Handle_player_death);
    HookEvent("player_hurt", Handle_player_hurt);
    HookEvent("item_purchase", Handle_item_purchase);
    HookEvent("bomb_beginplant", Handle_bomb_beginplant);
    HookEvent("bomb_abortplant", Handle_bomb_abortplant);
    HookEvent("bomb_planted", Handle_bomb_planted);
    HookEvent("bomb_defused", Handle_bomb_defused);
    HookEvent("bomb_exploded", Handle_bomb_exploded);
    HookEvent("bomb_dropped", Handle_bomb_dropped);
    HookEvent("bomb_pickup", HandleSimpleUserid);
    HookEvent("defuser_dropped", Handle_defuser_dropped);
    HookEvent("defuser_pickup", Handle_defuser_pickup);
    HookEvent("announce_phase_end", HandleSimpleEvent);
    HookEvent("cs_intermission", HandleSimpleEvent);
    HookEvent("bomb_begindefuse", Handle_bomb_begindefuse);
    HookEvent("bomb_abortdefuse", HandleSimpleUserid);
    HookEvent("player_radio", Handle_player_radio);
    HookEvent("bomb_beep", Handle_bomb_beep);
    HookEvent("weapon_fire", Handle_weapon_fire);
    HookEvent("weapon_fire_on_empty", Handle_weapon_fire_on_empty);
    HookEvent("weapon_outofammo", HandleSimpleUserid);
    HookEvent("weapon_reload", HandleSimpleUserid);
    HookEvent("weapon_zoom", HandleSimpleUserid);
    HookEvent("silencer_detach", HandleSimpleUserid);
    HookEvent("player_spawned", HandleSimpleUserid);
    HookEvent("item_pickup", Handle_item_pickup);
    HookEvent("ammo_pickup", Handle_ammo_pickup);
    HookEvent("item_equip", Handle_item_equip);
    HookEvent("enter_buyzone", Handle_enter_buyzone);
    HookEvent("exit_buyzone", Handle_exit_buyzone);
    HookEvent("buytime_ended", HandleSimpleEvent);
    HookEvent("enter_bombzone", Handle_enter_bombzone);
    HookEvent("exit_bombzone", Handle_exit_bombzone);
    HookEvent("silencer_off", HandleSimpleUserid);
    HookEvent("silencer_on", HandleSimpleUserid);
    /*HookEvent("round_prestart", Handle_round_prestart);
    HookEvent("round_poststart", Handle_round_poststart);
    HookEvent("round_start", Handle_round_start);
    HookEvent("round_end", Handle_round_end); // ok when bomb explodes
    HookEvent("grenade_bounce", Handle_grenade_bounce);
    HookEvent("hegrenade_detonate", Handle_hegrenade_detonate);
    HookEvent("flashbang_detonate", Handle_flashbang_detonate);
    HookEvent("smokegrenade_detonate", Handle_smokegrenade_detonate);
    HookEvent("smokegrenade_expired", Handle_smokegrenade_expired);
    HookEvent("molotov_detonate", Handle_molotov_detonate);
    HookEvent("decoy_detonate", Handle_decoy_detonate);
    HookEvent("decoy_started", Handle_decoy_started);
    HookEvent("inferno_startburn", Handle_inferno_startburn);
    HookEvent("inferno_expire", Handle_inferno_expire);
    HookEvent("inferno_extinguish", Handle_inferno_extinguish);
    HookEvent("decoy_firing", Handle_decoy_firing);
    HookEvent("bullet_impact", Handle_bullet_impact);
    HookEvent("player_footstep", Handle_player_footstep);
    HookEvent("player_blind", Handle_player_blind);
    HookEvent("player_falldamage", Handle_player_falldamage);
    HookEvent("door_moving", Handle_door_moving);
    HookEvent("round_freeze_end", Handle_round_freeze_end);
    HookEvent("mb_input_lock_success", Handle_mb_input_lock_success);
    HookEvent("mb_input_lock_cancel", Handle_mb_input_lock_cancel);
    HookEvent("round_mvp", Handle_round_mvp);
    HookEvent("switch_team", Handle_switch_team);
    HookEvent("player_given_c4", Handle_player_given_c4);
    HookEvent("bot_takeover", Handle_bot_takeover);
*/
}

/**
 * Event handlers
 */

public Action:HandleSimpleEvent(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->%s->", eventName);
    return Plugin_Handled;
}

public Action:HandleSimpleUserid(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");
    if(!IsClientInGame(player)) {
        return Plugin_Handled;
    }

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    LogToGame("HW->%s->[%d],[%f],[%f],[%f]", eventName, player, playerCoords[0], playerCoords[1], playerCoords[2]);
    return Plugin_Handled;
}

// This section is from https://wiki.alliedmods.net/Generic_Source_Server_Events

public Action:Handle_server_cvar(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:cvar[MAX_MESSAGE_LENGTH];
    GetEventString(event, "cvarname", cvar, sizeof(cvar));
    new String:value[MAX_MESSAGE_LENGTH];
    GetEventString(event, "cvarvalue", value, sizeof(value));
    LogToGame("HW->server_cvar->[%s],[%s]",
        cvar,
        value
    );
    return Plugin_Handled;
}

public Action:Handle_player_connect(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:pName[MAX_NAME_LENGTH];
    GetEventString(event, "name", pName, sizeof(pName));
    new String:sId[MAX_STEAMID_LENGTH];
    GetEventString(event, "networkid", sId, sizeof(sId));
    new String:address[MAX_IP_LENGTH];
    GetEventString(event, "address", address, sizeof(address));
    LogToGame("HW->player_connect->[%s],[%d],[%d],[%s],[%s],[%b]",
        pName,
        GetEventInt(event, "index"),
        GetEventInt(event, "userid"),
        sId, // BOT for bots
        address, // [none] for bots
        GetEventBool(event, "bot") // 1 / 0
    );
    return Plugin_Handled;
}

public Action:Handle_player_info(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:pName[MAX_NAME_LENGTH];
    GetEventString(event, "name", pName, sizeof(pName));
    new String:sId[MAX_STEAMID_LENGTH];
    GetEventString(event, "networkid", sId, sizeof(sId));
    LogToGame("HW->player_info->[%s],[%d],[%d],[%s],[%b]",
        pName,
        GetEventInt(event, "index"),
        GetEventInt(event, "userid"),
        sId,
        GetEventBool(event, "bot")
    );
    return Plugin_Handled;
}

public Action:Handle_player_disconnect(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:reason[MAX_MESSAGE_LENGTH];
    GetEventString(event, "reason", reason, sizeof(reason));
    new String:name[MAX_NAME_LENGTH];
    GetEventString(event, "name", name, sizeof(name));
    new String:sId[MAX_STEAMID_LENGTH];
    GetEventString(event, "networkid", sId, sizeof(sId));
    LogToGame("HW->player_disconnect->[%d],[%s],[%s],[%s],[%d]",
        GetEventInt(event, "userid"),
        reason,
        name,
        sId,
        GetEventInt(event, "bot")
    );
    return Plugin_Handled;
}

public Action:Handle_player_activate(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_activate->[%d]",
        GetEventInt(event, "userid")
    );
    return Plugin_Handled;
}

public Action:Handle_player_say(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:message[MAX_MESSAGE_LENGTH];
    GetEventString(event, "text", message, sizeof(message));
    LogToGame("HW->player_say->[%d],[%s]",
        GetEventInt(event, "userid"),
        message
    );
    return Plugin_Handled;
}

public Action:Handle_player_team(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_team->[%d],[%d],[%d],[%d]",
        GetEventInt(event, "userid"),
        GetEventInt(event, "team"),
        GetEventInt(event, "oldteam"),
        GetEventBool(event, "disconnect")
    );
    return Plugin_Handled;
}

public Action:Handle_game_start(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:objective[MAX_NAME_LENGTH];
    GetEventString(event, "objective", objective, sizeof(objective));
    LogToGame("HW->game_start->[%d],[%d],[%s]",
        GetEventInt(event, "timelimit"),
        GetEventInt(event, "fraglimit"),
        objective
    );
    return Plugin_Handled;
}

public Action:Handle_game_end(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->game_end->[%d]",
        GetEventInt(event, "winner")
    );
    return Plugin_Handled;
}

public Action:Handle_round_end(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:message[MAX_MESSAGE_LENGTH];
    GetEventString(event, "message", message, sizeof(message));
    LogToGame("HW->round_end->[%d],[%d],[%s]",
        GetEventInt(event, "winner"),
        GetEventInt(event, "reason"),
        message
    );
    return Plugin_Handled;
}

public Action:Handle_break_breakable(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->break_breakable->[%d],[%d],[%d]",
        GetEventInt(event, "entindex"),
        GetEventInt(event, "userid"),
        GetEventInt(event, "material")
    );
    return Plugin_Handled;
}

public Action:Handle_break_prop(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->break_prop->[%d],[%d]",
        GetEventInt(event, "entindex"),
        GetEventInt(event, "userid")
    );
    return Plugin_Handled;
}

// CSGO specific

public Action:Handle_player_death(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new victim = GetEventInt(event, "userid");
    new killer = GetEventInt(event, "attacker");

    new Float:victimCoords[3];
    GetClientAbsOrigin(victim, Float:victimCoords);
    new Float:killerCoords[3];
    GetClientAbsOrigin(killer, Float:killerCoords);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->player_death->[%d],[%f],[%f],[%f],[%d],[%f],[%f],[%f],[%d],[%s],[%d],[%d],[%d],[%d]",
        victim,
        victimCoords[0],
        victimCoords[1],
        victimCoords[2],
        killer,
        killerCoords[0],
        killerCoords[1],
        killerCoords[2],
        GetEventInt(event, "assister"),
        weapon,
        GetEventBool(event, "headshot"),
        GetEventInt(event, "dominated"),
        GetEventInt(event, "revenge"),
        GetEventInt(event, "penetrated")
    );
    return Plugin_Handled;
}

public Action:Handle_player_hurt(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new victim = GetEventInt(event, "userid");
    new attacker = GetEventInt(event, "attacker");

    new Float:victimCoords[3];
    GetClientAbsOrigin(victim, Float:victimCoords);
    new Float:attackerCoords[3];
    GetClientAbsOrigin(attacker, Float:attackerCoords);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->player_hurt->[%d],[%f],[%f],[%f],[%d],[%f],[%f],[%f],[%d],[%d],[%s],[%d],[%d],[%d]",
        victim,
        victimCoords[0],
        victimCoords[1],
        victimCoords[2],
        attacker,
        attackerCoords[0],
        attackerCoords[1],
        attackerCoords[2],
        GetEventInt(event, "health"),
        GetEventInt(event, "armor"),
        weapon,
        GetEventInt(event, "dmg_health"),
        GetEventInt(event, "dmg_armod"),
        GetEventInt(event, "hitgroup")
    );
    return Plugin_Handled;
}

public Action:Handle_item_purchase(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");
    if(!IsClientInGame(player)) {
        return Plugin_Handled;
    }

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->item_purchase->[%d],[%f],[%f],[%f],[%d],[%s]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventInt(event, "team"),
        weapon
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_beginplant(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->bomb_beginplant->[%d],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_abortplant(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->bomb_abortplant->[%d],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_planted(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->bomb_planted->[%d],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_defused(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->bomb_defused->[%d],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_exploded(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->bomb_exploded->[%d],[%d]",
        GetEventInt(event, "userid"),
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_dropped(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    new entity = GetEventInt(event, "entindex");

    new Float:entityCoords[3];
    GetEntPropVector(entity, /*Prop_Send*/ Prop_Data, "m_vecOrigin", Float:entityCoords);

    LogToGame("HW->bomb_dropped->[%d],[%f],[%f],[%f],[%d],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        entity,
        entityCoords[0],
        entityCoords[1],
        entityCoords[2]
    );
    return Plugin_Handled;
}

public Action:Handle_defuser_dropped(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new entity = GetEventInt(event, "entityid");

    new Float:entityCoords[3];
    GetEntPropVector(entity, Prop_Data, "m_vecOrigin", Float:entityCoords);

    LogToGame("HW->defuser_dropped->[%d],[%f],[%f],[%f]",
        entity,
        entityCoords[0],
        entityCoords[1],
        entityCoords[2]
    );
    return Plugin_Handled;
}

public Action:Handle_defuser_pickup(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->defuser_pickup->[%d],[%f],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventFloat(event, "entityid")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_begindefuse(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Fload:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->bomb_begindefuse->[%d],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventBool(event, "haskit")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_abortdefuse(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->bomb_abortdefuse->[%d],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2]
    );
    return Plugin_Handled;
}

public Action:Handle_player_radio(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->player_radio->[%d],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventBool(event, "slot")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_beep(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new entity = GetEventInt(event, "entindex");

    new Float:entityCoords[3];
    GetEntPropVector(entity, Prop_Data, "m_vecOrigin", Float:entityCoords);

    LogToGame("HW->bomb_beep->[%d],[%f],[%f],[%f]",
        entity,
        entityCoords[0],
        entityCoords[1],
        entityCoords[2]
    );
    return Plugin_Handled;
}

public Action:Handle_weapon_fire(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->weapon_fire->[%d],[%f],[%f],[%f],[%s],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        weapon,
        GetEventBool(event, "silenced")
    );
    return Plugin_Handled;
}

public Action:Handle_weapon_fire_on_empty(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->weapon_fire_on_empty->[%d],[%f],[%f],[%f],[%s]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        weapon
    );
    return Plugin_Handled;
}

public Action:Handle_item_pickup(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");
    if(!IsClientInGame(player)) {
        return Plugin_Handled;
    }

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    new String:item[MAX_NAME_LENGTH];
    GetEventString(event, "item", item, sizeof(item));

    LogToGame("HW->item_pickup->[%d],[%f],[%f],[%f],[%s]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        item
    );
    return Plugin_Handled;
}

public Action:Handle_ammo_pickup(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    new String:item[MAX_NAME_LENGTH];
    GetEventString(event, "item", item, sizeof(item));

    LogToGame("HW->ammo_pickup->[%d],[%f],[%f],[%f],[%s],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        item,
        GetEventFloat(event, "index")
    );
    return Plugin_Handled;
}

public Action:Handle_item_equip(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");
    if(!IsClientInGame(player)) {
        return Plugin_Handled;
    }

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    new String:item[MAX_NAME_LENGTH];
    GetEventString(event, "item", item, sizeof(item));

    LogToGame("HW->item_equip->[%d],[%f],[%f],[%f],[%s],[%d],[%d],[%d],[%d],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        item,
        GetEventBool(event, "canzoom"),
        GetEventBool(event, "hassilencer"),
        GetEventBool(event, "issilenced"),
        GetEventBool(event, "hastracers"),
        GetEventInt(event, "weptype")
    );
    return Plugin_Handled;
}

public Action:Handle_enter_buyzone(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");
    if(!IsClientInGame(player)) {
        return Plugin_Handled;
    }

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->enter_buyzone->[%d],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventBool(event, "canbuy")
    );
    return Plugin_Handled;
}

public Action:Handle_exit_buyzone(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");
    if(!IsClientInGame(player)) {
        return Plugin_Handled;
    }

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->exit_buyzone->[%d],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventBool(event, "canbuy")
    );
    return Plugin_Handled;
}

public Action:Handle_enter_bombzone(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->enter_bombzone->[%d],[%f],[%f],[%f],[%d],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventBool(event, "hasbomb"),
        GetEventBool(event, "isplanted")
    );
    return Plugin_Handled;
}

public Action:Handle_exit_bombzone(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetEventInt(event, "userid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);

    LogToGame("HW->exit_bombzone->[%d],[%f],[%f],[%f],[%d],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        GetEventBool(event, "hasbomb"),
        GetEventBool(event, "isplanted")
    );
    return Plugin_Handled;
}


/*
    HookEvent("silencer_off", Handle_silencer_off);
    HookEvent("silencer_on", Handle_silencer_on);
    HookEvent("round_prestart", Handle_round_prestart);
    HookEvent("round_poststart", Handle_round_poststart);
    HookEvent("round_start", Handle_round_start);
    HookEvent("round_end", Handle_round_end); // ok when bomb explodes
    HookEvent("grenade_bounce", Handle_grenade_bounce);
    HookEvent("hegrenade_detonate", Handle_hegrenade_detonate);
    HookEvent("flashbang_detonate", Handle_flashbang_detonate);
    HookEvent("smokegrenade_detonate", Handle_smokegrenade_detonate);
    HookEvent("smokegrenade_expired", Handle_smokegrenade_expired);
    HookEvent("molotov_detonate", Handle_molotov_detonate);
    HookEvent("decoy_detonate", Handle_decoy_detonate);
    HookEvent("decoy_started", Handle_decoy_started);
    HookEvent("inferno_startburn", Handle_inferno_startburn);
    HookEvent("inferno_expire", Handle_inferno_expire);
    HookEvent("inferno_extinguish", Handle_inferno_extinguish);
    HookEvent("decoy_firing", Handle_decoy_firing);
    HookEvent("bullet_impact", Handle_bullet_impact);
    HookEvent("player_footstep", Handle_player_footstep);
    HookEvent("player_blind", Handle_player_blind);
    HookEvent("player_falldamage", Handle_player_falldamage);
    HookEvent("door_moving", Handle_door_moving);
    HookEvent("round_freeze_end", Handle_round_freeze_end);
    HookEvent("mb_input_lock_success", Handle_mb_input_lock_success);
    HookEvent("mb_input_lock_cancel", Handle_mb_input_lock_cancel);
    HookEvent("round_mvp", Handle_round_mvp);
    HookEvent("switch_team", Handle_switch_team);
    HookEvent("player_given_c4", Handle_player_given_c4);
    HookEvent("bot_takeover", Handle_bot_takeover);
*/
