#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "BindHintText",
	author = "TouchMe",
	description = "Allows you to fix the hint text for a certain time",
	version = "build_0004",
	url = "https://github.com/TouchMe-Inc/csgo_bind_hint_text"
};

#define MIN_DURATION_HINT_TEXT         0.5
#define DEFAULT_DURATION_HINT_TEXT     4.0

#define HINT_TEXT_SIZE                 512


enum struct HintInfo {
	char message[HINT_TEXT_SIZE];
	float timeout;
	float locked;
}

HintInfo g_tHintMessages[MAXPLAYERS + 1];


/**
 * Called before OnPluginStart.
 *
 * @param hSelf             Handle to the plugin.
 * @param bLate             Whether or not the plugin was loaded "late" (after map load).
 * @param sError            Error message buffer in case load failed.
 * @param iErrLen           Maximum number of characters for error message buffer.
 * @return                  APLRes_Success | APLRes_SilentFailure.
 */
public APLRes AskPluginLoad2(Handle hSelf, bool bLate, char[] sError, int iErrLen)
{
	EngineVersion engine = GetEngineVersion();

	if (engine != Engine_CSGO)
	{
		strcopy(sError, iErrLen, "Plugin only supports Counter-Strike: Global Offensive.");
		return APLRes_SilentFailure;
	}

	CreateNative("BindHintText", Native_BindHintText);

	RegPluginLibrary("bind_hint_text");

	return APLRes_Success;
}

// BindHintText(float fDuration, int iClient, const char[] sFormat, any ...)
public int Native_BindHintText(Handle hPlugin, int iParams)
{
	int iClient = GetNativeCell(2);
	float fDuration = GetNativeCell(1);
	float fGameTime = GetGameTime();

	if (fDuration < MIN_DURATION_HINT_TEXT) {
		fDuration = MIN_DURATION_HINT_TEXT;
	}

	g_tHintMessages[iClient].timeout = fDuration + fGameTime;

	if (fGameTime < g_tHintMessages[iClient].locked) {
		g_tHintMessages[iClient].timeout += (g_tHintMessages[iClient].locked - fGameTime);
	}

	FormatNativeString(0, 3, 4, sizeof(g_tHintMessages[].message), _, g_tHintMessages[iClient].message);

	return 0;
}

public void OnPluginStart()
{
	HookUserMessage(GetUserMessageId("HintText"), UserMessage_HintText, .intercept = true);
}

public void OnMapStart()
{
	CreateTimer(0.1, Timer_HintTick, .flags = TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_HintTick(Handle hTimer)
{
	float fGameTime = GetGameTime();

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient) || IsFakeClient(iClient)) {
			continue;
		}

		if (g_tHintMessages[iClient].message[0] != '\0' && fGameTime > g_tHintMessages[iClient].locked) {
			PrintHintText(iClient, "@");
		}
	}

	return Plugin_Continue;
}

public Action UserMessage_HintText(UserMsg msg_id, Protobuf pb, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!playersNum) {
		return Plugin_Continue;
	}

	char sBuffer[HINT_TEXT_SIZE]; PbReadString(pb, "text", sBuffer, sizeof(sBuffer));

	if (sBuffer[0] == '\0' || sBuffer[0] == '#') {
		return Plugin_Handled;
	}

	int iClient = players[0];
	float fGameTime = GetGameTime();

	if (sBuffer[0] == '@')
	{
		if (fGameTime > g_tHintMessages[iClient].timeout) {
			g_tHintMessages[iClient].message[0] = '\0';
		}

		PbSetString(pb, "text", g_tHintMessages[iClient].message);
		return Plugin_Changed;
	}

	else {
		g_tHintMessages[iClient].locked = fGameTime + DEFAULT_DURATION_HINT_TEXT;
		g_tHintMessages[iClient].timeout += DEFAULT_DURATION_HINT_TEXT;
	}

	return Plugin_Continue;
}

public void OnClientDisconnect_Post(int iClient)
{
	g_tHintMessages[iClient].locked = 0.0;
	g_tHintMessages[iClient].timeout = 0.0;
	g_tHintMessages[iClient].message[0] = '\0';
}
