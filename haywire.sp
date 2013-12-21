/**
 * This is an optional part of the srcds-haywire suite
 *
 * @author Mihai Ene
 */
#include <sourcemod>

#define MAX_STEAMID_LENGTH 32
#define MAX_IP_LENGTH 64


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
    //HookEvent("server_addban", Handle_server_addban);
    HookEvent("player_connect", Handle_player_connect);
}

HookCSGO() {
    LogAction(-1, -1, "Should hook CSGO events");
}

/**
 * Event handlers
 */
/*public Action:Handle_server_addban(Handle:event, const String:name[], bool:dontBroadcast) {
    new tLId = GetEventInt(event, "userid");
    new String:tId[MAX_NAME_LENGTH];
    tId = GetEventString(event, "networkid");
    new tIp = GetEventString(event, "ip");
    new duration = GetEventString(event, "duration");
    new by = GetEventString(event, "by");
    LogAction(0, tLId, "HW->server_addban->[%L],[%L],[%L],[%L],[%L]", tLid, tId, tIp, duration, by);
    return Plugin_Handled;
}*/

public Action:Handle_player_connect(Handle:event, const String:name[], bool: dontBroadcast) {
    new String:pName[MAX_NAME_LENGTH];
    GetEventString(event, "name", pName, sizeof(pName));
    new index = GetEventInt(event, "index");
    new uId = GetEventInt(event, "userid");
    new String:nId[MAX_STEAMID_LENGTH];
    GetEventString(event, "networkid", nId, sizeof(nId));
    new String:address[MAX_IP_LENGTH];
    GetEventString(event, "address", address, sizeof(address));
    new bot = GetEventBool(event, "bot");
    LogAction(uId, -1, "HW->player_connect->[%L],[%L],[%L],[%L],[%L],[%L]", pName, index, uId, nId, address, bot);
    return Plugin_Handled;
}

