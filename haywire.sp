/**
 * This is an optional part of the srcds-haywire suite
 *
 * @author Mihai Ene
 */
#include <sourcemod>

#define MAX_STEAMID_LENGTH 32
#define MAX_IP_LENGTH 64
#define MAX_MESSAGE_LENGTH 192

public Plugin:myinfo = {
    name = "Haywire",
    author = "Mihai Ene",
    description = "Enhances server logs",
    version = "0.1.0",
    url = "https://github.com/randunel/sourcemod-haywire"
};

public OnPluginStart() {
    HookEvents();
}

/**
 * Event hooks
 */
HookEvents() {
    HookGeneric();
    decl String:folder[64];
    GetGameFolderName(folder, sizeof(folder));
    if(strcmp(folder, "csgo") == 0) {
        HookCSGO();
    }
}

HookGeneric() {
    // This section is from https://wiki.alliedmods.net/Generic_Source_Server_Events
    HookEvent("server_cvar", Handle_server_cvar); // ok
    HookEvent("player_connect", Handle_player_connect); // ok
    HookEvent("player_info", Handle_player_info); // TEST
    HookEvent("player_disconnect", Handle_player_disconnect); // ok
    HookEvent("player_activate", Handle_player_activate); // ok
    HookEvent("player_say", Handle_player_say); // TEST
    // This section is from https://wiki.alliedmods.net/Generic_Source_Events
    HookEvent("player_team", Handle_player_team); // ok
    HookEvent("player_class", Handle_player_class); // not working
    HookEvent("player_death", Handle_player_death); // ok
    HookEvent("player_hurt", Handle_player_hurt); // ok
    HookEvent("player_score", Handle_player_score); // not working
    HookEvent("player_spawn", Handle_player_spawn); // not working
    HookEvent("player_shoot", Handle_player_shoot); // not working
    HookEvent("player_use", Handle_player_use); // TEST
    HookEvent("player_changename", Handle_player_changename); // TEST
    HookEvent("game_newmap", Handle_game_newmap); // TEST
    HookEvent("game_start", Handle_game_start); // ok - start of warmup, start of firstround
    HookEvent("game_end", Handle_game_end); // TEST
    HookEvent("round_start", Handle_round_start); // not working
    HookEvent("round_end", Handle_round_end); // ok when bomb explodes
    HookEvent("break_breakable", Handle_break_breakable); // TEST
    HookEvent("break_prop", Handle_break_prop); // TEST
}

HookCSGO() {
    LogToGame("Should hook CSGO events");
}

/**
 * Event handlers
 */

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

public Action:Handle_player_class(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:class[MAX_NAME_LENGTH];
    GetEventString(event, "class", class, sizeof(class));
    LogToGame("HW->player_class->[%d],[%s]",
        GetEventInt(event, "userid"),
        class
    );
    return Plugin_Handled;
}

public Action:Handle_player_death(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_death->[%d],[%d]",
        GetEventInt(event, "userid"),
        GetEventInt(event, "attacker")
    );
    return Plugin_Handled;
}

public Action:Handle_player_hurt(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_hurt->[%d],[%d],[%d]",
        GetEventInt(event, "userid"),
        GetEventInt(event, "attacker"),
        GetEventInt(event, "health")
    );
    return Plugin_Handled;
}

public Action:Handle_player_score(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_score->[%d],[%d],[%d],[%d]",
        GetEventInt(event, "userid"),
        GetEventInt(event, "kills"),
        GetEventInt(event, "deaths"),
        GetEventInt(event, "score")
    );
    return Plugin_Handled;
}

public Action:Handle_player_spawn(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_chat->[%d]",
        GetEventInt(event, "userid")
    );
    return Plugin_Handled;
}

public Action:Handle_player_shoot(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_shoot->[%d],[%d],[%d]",
        GetEventInt(event, "userid"),
        GetEventInt(event, "weapon"),
        GetEventInt(event, "mode")
    );
    return Plugin_Handled;
}

public Action:Handle_player_use(Handle:event, const String:eventName[], bool:dontBroadcast) {
    LogToGame("HW->player_use->[%d],[%d]",
        GetEventInt(event, "userid"),
        GetEventInt(event, "entity")
    );
    return Plugin_Handled;
}

public Action:Handle_player_changename(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:oldName[MAX_NAME_LENGTH];
    GetEventString(event, "oldname", oldName, sizeof(oldName));
    new String:newName[MAX_NAME_LENGTH];
    GetEventString(event, "newname", newName, sizeof(newName));
    LogToGame("HW->player_changename->[%d],[%s],[%s]",
        GetEventInt(event, "userid"),
        oldName,
        newName
    );
    return Plugin_Handled;
}

public Action:Handle_game_newmap(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:map[MAX_MESSAGE_LENGTH];
    GetEventString(event, "mapname", map, sizeof(map));
    LogToGame("HW->game_newmap->[%s]",
        map
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

public Action:Handle_round_start(Handle:event, const String:eventName[], bool:dontBroadcast) {
    new String:objective[MAX_NAME_LENGTH];
    GetEventString(event, "objective", objective, sizeof(objective));
    LogToGame("HW->game_start->[%d],[%d],[%s]",
        GetEventInt(event, "timelimit"),
        GetEventInt(event, "fraglimit"),
        objective
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

