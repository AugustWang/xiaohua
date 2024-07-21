// -> client to server
// <- server to client
// <-> client & server
//struct UsedSkill ->
//{
//	int 	skillId; 
//	int 	desId;	
//	int     x;
//	int     y;
//};
//
//struct ObjResult
//{
//	int id;
//	int hp;
//	int damagehp;
//};
//
//struct SkillResult <-
//{
//	int		usedId;
//	int 	skillId; 
//	vector <ObjResult> result;	
//};

struct Skillcooldown<-
{
	int skillID;
	int time;
};

//struct Buff
//{
//	int userID;
//	int targateID;
//
//	int skillID;
//	int time;
//
//	int hel_damageHP;
//	int hpper;
//};
//
//struct MISS<-
//{
//	int usedId;
//	int targateID;
//};