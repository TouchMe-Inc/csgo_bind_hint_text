#if defined  _bind_hint_text_included_
 #endinput
#endif
#define _bind_hint_text_included_

native void BindHintText(float fDuration, int iClient, const char[] sFormat, any ...);

public SharedPlugin __pl_bind_hint_text =
{
	name = "bind_hint_text",
	file = "bind_hint_text.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_bind_hint_text_SetNTVOptional()
{
	MarkNativeAsOptional("BindHintText");
}
#endif
