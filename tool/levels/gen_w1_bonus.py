# tool/levels/gen_w1_bonus.py — source layout for assets/levels/w1_bonus.txt (Ember Hollow).
# Run from the repo root: python3 tool/levels/gen_w1_bonus.py  (then flutter test).
# Kept so the level can be edited by coordinates instead of by hand in a 124-col grid.
W,H=124,20
g=[['.']*W for _ in range(H)]
def put(r,c,s):
    for i,ch in enumerate(s):
        g[r][c+i]=ch
# ground rows 16-19 solid
for r in range(16,20): put(r,0,'#'*W)
# --- 0-17 start runway
put(15,4,'P'); put(15,8,'s'); put(15,11,'b'); put(15,14,'m'); put(15,17,'t')
# coin arc
put(12,11,'cc'); put(13,10,'c'); put(13,13,'c')
# --- 20-29 spike bed with platform over it
put(16,22,'^^^^')                       # 1-deep spike pit (ground row 17 under)
put(13,19,'=========')                 # bridge cols 19-27
put(11,21,'c.c.c')                     # coins above bridge
# --- 30-44: totem pillar + thornling, campfire
put(15,29,'K')                          # campfire before the totem: a death here costs a section, not the level
put(14,36,'###'); put(15,36,'###'); put(13,37,'O')   # totem on a 2-high pillar (cols 36-38)
put(15,40,'a'); put(15,42,'T'); put(15,52,'K'); put(15,46,'s')
# --- 47-66: rising stair of thin platforms, ashbat, enemies below
put(13,49,'=====');  put(12,51,'c')
put(11,55,'=====');  put(10,57,'c'); put(10,56,'V')
put(9,61,'=====');   put(8,63,'f'); put(8,61,'c')
put(15,55,'R'); put(15,61,'N'); put(15,63,'b')
# --- 66-72: ground vault 1 (w1_l4 pattern) with cracked walls
put(14,66,'B...B'); put(15,66,'B.X.B')
# high chest reward for the stair: platform + chest
put(7,66,'=====');  put(6,68,'C')
# --- 73-92: fire pit, bridge, second totem, chest, campfire
put(15,75,'K'); put(15,77,'s')
put(16,80,'~~~')                       # fire pit cols 80-82
put(13,78,'=======')                   # bridge cols 78-84
put(11,80,'c.c')
put(14,87,'###'); put(15,87,'###'); put(13,88,'O')
put(15,92,'C'); put(15,94,'h')
# --- 95-108: gauntlet
put(15,97,'T'); put(12,99,'V'); put(15,100,'R'); put(15,107,'N'); put(15,104,'r')
put(12,96,'c.c.c.c')
put(13,100,'=====')                    # hop platform over the gauntlet
put(15,108,'a')
# --- 100-104 elevated vault 2 (on its own pillar over the gauntlet? no: put it up top)
put(10,104,'#####'); put(8,104,'B...B'); put(9,104,'B.X.B')  # vault floor row 10, walls rows 8-9
put(7,104,'#####')                     # roof
put(6,105,'c.c')                       # coins on the roof (double-jump from the approach)
put(10,99,'=====')                     # approach platform flush with the vault floor (cols 99-103)
put(11,93,'=====')                     # lower approach platform (cols 93-97)
# --- 109-123: finish
put(15,112,'C'); put(15,115,'f'); put(15,118,'t'); put(15,120,'E')
put(15,113,'K')
meta="""meta: name=Ember Hollow
meta: lore=The grove keeps a purse of its own. It does not hand it over.
meta: world=1
meta: music=combat
meta: par_s=170
meta: sign1=A bonus grove. Nothing here is required - everything here pays.
meta: sign2=The high road pays in coin. The low road pays in bruises.
meta: sign3=Fire below, coin above. Pick your footing before you pick your pocket.
"""
open('assets/levels/w1_bonus.txt','w').write(meta+'\n'.join(''.join(r) for r in g)+'\n')
print('\n'.join(''.join(r) for r in g))
