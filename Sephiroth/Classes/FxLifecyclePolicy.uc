// 统一提供角色生命周期状态判断，不持有角色或装备缓存。
class FxLifecyclePolicy extends Object;

// Keep effect eligibility separate from equipment and model reads.
// 先核对角色、控制器和 PSI 归属，再判断变身；返回 Ready、WaitingData、Unavailable 或 Transformed。
static function name GetHeroState(Hero H)
{
    local ClientController CC;

    if (H == None || H.bDeleteMe)
        return 'Unavailable';

    CC = ClientController(H.Controller);
    if (CC == None || CC.bDeleteMe || CC.Pawn != H || CC.PSI == None || CC.PSI.bDeleteMe)
        return 'WaitingData';

    if (CC.PSI.bTransformed || CC.PSI.TransToMonsterName != "")
        return 'Transformed';

    return 'Ready';
}
