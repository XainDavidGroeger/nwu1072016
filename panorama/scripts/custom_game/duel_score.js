(function () {
  GameEvents.Subscribe( "update_duel_score", UpdateScore );
})();

function UpdateScore( msg ) {
  var playeronescore = $("#ScoreOneLine");
  var playertwoscore = $("#ScoreTwoLine");
  $.Msg(msg.continue);
  if (msg.continue == 1)
  {
  	$.Msg("update");
  	var playeronescoreMessage = $("#ScoreOneId");
  	playeronescoreMessage.text = "Main Score: " + msg.scoreOne + " - " + msg.scoreTwo;
  	var playertwoscoreMessage = $("#ScoreTwoId");
  	playertwoscoreMessage.text = "CS Score: " + msg.csOne + " - " + msg.csTwo;
  }else {
  	$.Msg("new");
  	notification = $.CreatePanel('Label', playeronescore, 'ScoreOneId');
  	notification.html = true;
  	notification.text = "Main Score: 0 - 0";
  	notification.hittest = false;
  	notification.AddClass('TitleText');

  	notification = $.CreatePanel('Label', playertwoscore, 'ScoreTwoId');
  	notification.html = true;
  	notification.text = "CS Score: 0 - 0";
  	notification.hittest = false;
  	notification.AddClass('TitleText');
  }
}