//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function()
{
	var mapinfo = Game.GetMapInfo()
	var rootNode = $("#GameInfoPanel" );
	if (mapinfo['map_name'] == "maps/duel.vpk") 
	{
		var showInfoPanel = true;
	}
	else
	{
		var showInfoPanel = false;
	}

	if (showInfoPanel)
	{
		var teamNode = $.CreatePanel( "Panel", rootNode, "" );
		teamNode.AddClass( "duel_info" );
		teamNode.BLoadLayout( "file://{resources}/layout/custom_game/game_info_duel.xml", false, false );
	}
})();