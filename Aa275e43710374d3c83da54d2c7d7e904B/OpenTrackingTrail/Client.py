# -*- coding: utf-8 -*-
from QuModLibs.Client import *
from Modules.TrackingTrail.Client import BaseKnifeLightEffectRenderer
lambda: "By 棱花 && KID团队 请在遵循协议的前提下使用"
lambda: "OpenTrackingTrail Client"
# 2025/02/08

# 顺带给生物也绑定一份
@BaseKnifeLightEffectRenderer.regEntity("minecraft:husk")
class TestKLRenderer(BaseKnifeLightEffectRenderer):
    """ 测试刀光渲染器 """
    def onGameTick(self):
        BaseKnifeLightEffectRenderer.onGameTick(self)
        if True:    #  在此处编写你的渲染条件 为了测试 这里始终开启
            # ["rightarm", "rightitem"] 为绑定的骨骼/定位器名字 可根据实际需求在模型上调整
            # createBinder需要一个唯一key名 确保tick下重复调用不会重复创建 实现实时更新渲染开关
            self.createBinder("default", ["rightarm", "rightitem"], {"startColor": (1, 1, 1, 1), "endColor": (1, 1, 1, 0), "length": 5, "width": 3, "offset": 0, "texture": "open_knife_light", "bloom": False})
        else:
            self.removeAllBinder()

@Listen("AddPlayerCreatedClientEvent")
def AddPlayerCreatedClientEvent(args={}):
    # 截至当前版本QuModLibs暂未提供组件快捷玩家注册装饰器 需自行监听
    TestKLRenderer().bind(args["playerId"])

# PS: 为避免多MOD冲突问题 若需大量魔改 请重新命名模型/材质/着色器相关名称 避免ODR问题