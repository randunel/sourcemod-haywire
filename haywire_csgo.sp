#include <sourcemod>
#include <sdktools>

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
    HookEvent("round_start", Handle_round_start);
    HookEvent("round_end", Handle_round_end); // ok when bomb explodes
    HookEvent("grenade_bounce", HandleSimpleUserid);
    HookEvent("hegrenade_detonate", HandleUserEntity);
    HookEvent("flashbang_detonate", HandleUserEntity);
    HookEvent("smokegrenade_detonate", HandleUserEntity);
    HookEvent("smokegrenade_expired", HandleUserEntity);
    HookEvent("molotov_detonate", HandleUserEntity); // TEST, it may need custom handler
    HookEvent("decoy_detonate", HandleUserEntity);
    HookEvent("decoy_started", HandleUserEntity);
    HookEvent("inferno_startburn", HandleSimpleEntity);
    HookEvent("inferno_expire", HandleSimpleEntity);
    HookEvent("inferno_extinguish", HandleSimpleEntity);
    HookEvent("decoy_firing", HandleUserEntity);
    HookEvent("bullet_impact", Handle_bullet_impact);
    HookEvent("player_footstep", HandleSimpleUserid);
    HookEvent("player_jump", HandleSimpleUserid);
    HookEvent("player_blind", HandleSimpleUserid);
    HookEvent("player_falldamage", Handle_player_falldamage);
    HookEvent("door_moving", Handle_door_moving);
    HookEvent("round_freeze_end", HandleSimpleEvent);
    HookEvent("mb_input_lock_success", HandleSimpleEvent);
    HookEvent("mb_input_lock_cancel", HandleSimpleEvent);
    HookEvent("cs_win_panel_round", Handle_cs_win_panel_round);
    HookEvent("cs_win_panel_match", Handle_cs_win_panel_match);
    HookEvent("cs_match_end_restart", HandleSimpleEvent);
    HookEvent("cs_pre_restart", HandleSimpleEvent);
    HookEvent("match_end_conditions", Handle_match_end_conditions);
    HookEvent("round_mvp", Handle_round_mvp);
    HookEvent("switch_team", Handle_switch_team);
    HookEvent("player_given_c4", HandleSimpleUserid);
    HookEvent("bot_takeover", Handle_bot_takeover);
}

/**
 * Event handlers
 */

public Action:HandleSimpleEvent(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->%s->", eventName);
    return Plugin_Handled;
}

public Action:HandleSimpleUserid(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);
    LogToGame("HW->%s->[%d],[%f],[%f],[%f],[%f],[%f],[%f]",
        eventName,
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2]
    );
    return Plugin_Handled;
}

public Action:HandleSimpleEntity(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->%s->[%d],[%f],[%f],[%f]",
        GetEventInt(event, "entityid"),
        GetEventFloat(event, "x"),
        GetEventFloat(event, "y"),
        GetEventFloat(event, "z")
    );
    return Plugin_Handled
}

public Action:HandleUserEntity(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));
    new entity = GetEventInt(event, "entityid");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->%s->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%f],[%f],[%f]",
        eventName,
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        entity,
        GetEventFloat(event, "x"),
        GetEventFloat(event, "y"),
        GetEventFloat(event, "z")
    );
    return Plugin_Handled
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
    LogToGame("HW->player_connect->[%d],[%d],[%s],[%s],[%b],[%s",
        GetEventInt(event, "index"),
        GetClientOfUserId(GetEventInt(event, "userid")),
        sId, // BOT for bots
        address, // [none] for bots
        GetEventBool(event, "bot"), // 1 / 0
        pName
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
        GetClientOfUserId(GetEventInt(event, "userid")),
        sId,
        GetEventBool(event, "bot")
    );
    return Plugin_Handled;
}

public Action:Handle_player_disconnect(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:reason[MAX_MESSAGE_LENGTH];
    GetEventString(event, "reason", reason, sizeof(reason));
    new String:sId[MAX_STEAMID_LENGTH];
    GetEventString(event, "networkid", sId, sizeof(sId));
    LogToGame("HW->player_disconnect->[%d],[%s],[%s],[%d]",
        GetClientOfUserId(GetEventInt(event, "userid")),
        reason,
        sId,
        GetEventInt(event, "bot")
    );
    return Plugin_Handled;
}

public Action:Handle_player_activate(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_activate->[%d]",
        GetClientOfUserId(GetEventInt(event, "userid"))
    );
    return Plugin_Handled;
}

public Action:Handle_player_say(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:message[MAX_MESSAGE_LENGTH];
    GetEventString(event, "text", message, sizeof(message));
    LogToGame("HW->player_say->[%d],[%s]",
        GetClientOfUserId(GetEventInt(event, "userid")),
        message
    );
    return Plugin_Handled;
}

public Action:Handle_player_team(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_team->[%d],[%d],[%d],[%d]",
        GetClientOfUserId(GetEventInt(event, "userid")),
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

public Action:Handle_break_breakable(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->break_breakable->[%d],[%d],[%d]",
        GetEventInt(event, "entindex"),
        GetClientOfUserId(GetEventInt(event, "userid")),
        GetEventInt(event, "material")
    );
    return Plugin_Handled;
}

public Action:Handle_break_prop(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->break_prop->[%d],[%d]",
        GetEventInt(event, "entindex"),
        GetClientOfUserId(GetEventInt(event, "userid"))
    );
    return Plugin_Handled;
}

// CSGO specific

public Action:Handle_player_death(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new killer = GetClientOfUserId(GetEventInt(event, "attacker"));

    new Float:victimCoords[3];
    GetClientAbsOrigin(victim, Float:victimCoords);
    new Float:victimAngles[3];
    GetClientEyeAngles(victim, Float:victimAngles);

    new Float:killerCoords[3];
    GetClientAbsOrigin(killer, Float:killerCoords);
    new Float:killerAngles[3];
    GetClientEyeAngles(killer, Float:killerAngles);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->player_death->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%s],[%d],[%d],[%d],[%d]",
        victim,
        victimCoords[0],
        victimCoords[1],
        victimCoords[2],
        victimAngles[0],
        victimAngles[1],
        victimAngles[2],
        killer,
        killerCoords[0],
        killerCoords[1],
        killerCoords[2],
        killerAngles[0],
        killerAngles[1],
        killerAngles[2],
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
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    if(attacker == 0) {
        return Plugin_Handled;
    }

    new Float:victimCoords[3];
    GetClientAbsOrigin(victim, Float:victimCoords);
    new Float:victimAngles[3];
    GetClientEyeAngles(victim, Float:victimAngles);

    new Float:attackerCoords[3];
    GetClientAbsOrigin(attacker, Float:attackerCoords);
    new Float:attackerAngles[3];
    GetClientEyeAngles(attacker, Float:attackerAngles);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->player_hurt->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%d],[%s],[%d],[%d],[%d]",
        victim,
        victimCoords[0],
        victimCoords[1],
        victimCoords[2],
        victimAngles[0],
        victimAngles[1],
        victimAngles[2],
        attacker,
        attackerCoords[0],
        attackerCoords[1],
        attackerCoords[2],
        attackerAngles[0],
        attackerAngles[1],
        attackerAngles[2],
        GetEventInt(event, "health"),
        GetEventInt(event, "armor"),
        weapon,
        GetEventInt(event, "dmg_health"),
        GetEventInt(event, "dmg_armor"),
        GetEventInt(event, "hitgroup")
    );
    return Plugin_Handled;
}

public Action:Handle_item_purchase(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->item_purchase->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%s]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventInt(event, "team"),
        weapon
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_beginplant(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->bomb_beginplant->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_abortplant(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->bomb_abortplant->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_planted(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->bomb_planted->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_defused(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->bomb_defused->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_exploded(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->bomb_exploded->[%d],[%d]",
        GetClientOfUserId(GetEventInt(event, "userid")),
        GetEventInt(event, "site")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_dropped(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    new entity = GetEventInt(event, "entindex");

    new Float:entityCoords[3];
    GetEntPropVector(entity, /*Prop_Send*/ Prop_Data, "m_vecOrigin", Float:entityCoords);

    LogToGame("HW->bomb_dropped->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
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
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->defuser_pickup->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventFloat(event, "entityid")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_begindefuse(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->bomb_begindefuse->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventBool(event, "haskit")
    );
    return Plugin_Handled;
}

public Action:Handle_bomb_abortdefuse(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->bomb_abortdefuse->[%d],[%f],[%f],[%f],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2]
    );
    return Plugin_Handled;
}

public Action:Handle_player_radio(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->player_radio->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventInt(event, "slot")
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
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->weapon_fire->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%s],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        weapon,
        GetEventBool(event, "silenced")
    );
    return Plugin_Handled;
}

public Action:Handle_weapon_fire_on_empty(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    new String:weapon[MAX_NAME_LENGTH];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

    LogToGame("HW->weapon_fire_on_empty->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%s]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        weapon
    );
    return Plugin_Handled;
}

public Action:Handle_item_pickup(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    new String:item[MAX_NAME_LENGTH];
    GetEventString(event, "item", item, sizeof(item));

    LogToGame("HW->item_pickup->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%s]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        item
    );
    return Plugin_Handled;
}

public Action:Handle_ammo_pickup(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    new String:item[MAX_NAME_LENGTH];
    GetEventString(event, "item", item, sizeof(item));

    LogToGame("HW->ammo_pickup->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%s],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        item,
        GetEventFloat(event, "index")
    );
    return Plugin_Handled;
}

public Action:Handle_item_equip(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    new String:item[MAX_NAME_LENGTH];
    GetEventString(event, "item", item, sizeof(item));

    LogToGame("HW->item_equip->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%s],[%d],[%d],[%d],[%d],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
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
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->enter_buyzone->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventBool(event, "canbuy")
    );
    return Plugin_Handled;
}

public Action:Handle_exit_buyzone(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->exit_buyzone->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventBool(event, "canbuy")
    );
    return Plugin_Handled;
}

public Action:Handle_enter_bombzone(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->enter_bombzone->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventBool(event, "hasbomb"),
        GetEventBool(event, "isplanted")
    );
    return Plugin_Handled;
}

public Action:Handle_exit_bombzone(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->exit_bombzone->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%d]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventBool(event, "hasbomb"),
        GetEventBool(event, "isplanted")
    );
    return Plugin_Handled;
}

public Action:Handle_round_start(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:objective[MAX_NAME_LENGTH];
    GetEventString(event, "objective", objective, sizeof(objective));

    LogToGame("HW->round_start->[%f],[%f],[%s]",
        GetEventFloat(event, "timelimit"),
        GetEventFloat(event, "fraglimit"),
        objective
    );
    return Plugin_Handled;
}

public Action:Handle_round_end(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:message[MAX_MESSAGE_LENGTH];
    GetEventString(event, "message", message, sizeof(message));

    LogToGame("HW->round_end->[%f],[%f],[%s]",
        GetEventFloat(event, "winner"),
        GetEventFloat(event, "reason"),
        message
    );
    return Plugin_Handled;
}

public Action:Handle_bullet_impact(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->bullet_impact->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventFloat(event, "x"),
        GetEventFloat(event, "y"),
        GetEventFloat(event, "z")
    );
    return Plugin_Handled;
}

public Action:Handle_player_falldamage(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);

    LogToGame("HW->player_falldamage->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        GetEventFloat(event, "damage")
    );
    return Plugin_Handled;
}

public Action:Handle_door_moving(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));
    new entity = GetEventInt(event, "entindex");

    new Float:playerCoords[3];
    GetClientAbsOrigin(player, Float:playerCoords);
    new Float:playerAngles[3];
    GetClientEyeAngles(player, Float:playerAngles);
    new Float:entityCoords[3];
    GetEntPropVector(entity, Prop_Data, "m_vecOrigin", Float:entityCoords);

    LogToGame("HW->door_moving->[%d],[%f],[%f],[%f],[%f],[%f],[%f],[%d],[%f],[%f],[%f]",
        player,
        playerCoords[0],
        playerCoords[1],
        playerCoords[2],
        playerAngles[0],
        playerAngles[1],
        playerAngles[2],
        entity,
        entityCoords[0],
        entityCoords[1],
        entityCoords[2]
    );
    return Plugin_Handled;
}

public Action:Handle_cs_win_panel_round(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:token[MAX_MESSAGE_LENGTH];
    GetEventString(event, "token", token, sizeof(token));
    LogToGame("HW->cs_win_panel_round->[%d],[%d],[%d],[%d],[%s],[%d],[%f],[%f],[%f]",
        GetEventBool(event, "show_timer_defend"),
        GetEventBool(event, "show_timer_attack"),
        GetEventInt(event, "timer_time"),
        GetEventInt(event, "final_event"),
        token,
        GetEventInt(event, "funfact_player"),
        GetEventFloat(event, "funfact_data1"),
        GetEventFloat(event, "funfact_data2"),
        GetEventFloat(event, "funfact_data3")
    );
    return Plugin_Handled;
}

public Action:Handle_cs_win_panel_match(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->cs_win_panel_match->[%d],[%d],[%f],[%f],[%d],[%d],[%f],[%f]",
        GetEventInt(event, "t_score"),
        GetEventInt(event, "ct_score"),
        GetEventFloat(event, "t_kd"),
        GetEventFloat(event, "ct_kd"),
        GetEventInt(event, "t_objectives_done"),
        GetEventInt(event, "ct_objectives_done"),
        GetEventFloat(event, "t_money_earned"),
        GetEventFloat(event, "ct_money_earned")
    );
    return Plugin_Handled;
}

public Action:Handle_match_end_conditions(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->match_end_conditions->[%f],[%f],[%f],[%f]",
        GetEventFloat(event, "frags"),
        GetEventFloat(event, "max_rounds"),
        GetEventFloat(event, "win_rounds"),
        GetEventFloat(event, "time")
    );
    return Plugin_Handled;
}

public Action:Handle_round_mvp(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->round_mvp->[%d],[%d]",
        GetClientOfUserId(GetEventInt(event, "userid")),
        GetEventInt(event, "reason")
    );
    return Plugin_Handled;
}

public Action:Handle_switch_team(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->switch_team->[%d],[%d],[%d],[%d],[%d]",
        GetEventInt(event, "numPlayers"),
        GetEventInt(event, "numSpectators"),
        GetEventInt(event, "avg_rank"),
        GetEventInt(event, "numTSlotsFree"),
        GetEventInt(event, "numCTSlotsFree")
    );
    return Plugin_Handled;
}

public Action:Handle_bot_takeover(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->bot_takeover->[%d],[%d],[%d]",
        GetClientOfUserId(GetEventInt(event, "userid")),
        GetEventInt(event, "botid"),
        GetEventInt(event, "index")
    );
    return Plugin_Handled;
}

