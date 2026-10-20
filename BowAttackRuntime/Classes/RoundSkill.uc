class RoundSkill extends BowSkill;
var Skill SourceSkill;
var ClientController Driver;
var Actor RoundTarget;
var bool Active, Fired, CommandRound;
var int ActionID, Channel, Serial;
var float FirstFireAt, ClipEndAt, NextArrowAt;

// Set only by the real local animation completion callback.
var bool ClipFinished;

defaultproperties
{
}
