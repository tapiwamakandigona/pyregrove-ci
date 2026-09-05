# tool/levels/gen_w2_bonus.py — source layout for assets/levels/w2_bonus.txt (Slag Cellar).
# Run from the repo root: python3 tool/levels/gen_w2_bonus.py  (then flutter test).
W,H=130,20
g=[['.']*W for _ in range(H)]
def put(r,c,s):
    for i,ch in enumerate(s):
        g[r][c+i]=ch
put(0,0,'#'*W)                                  # cave ceiling
for c in (14,40,66,92,118):                     # stalactite columns
    put(1,c,'#'); put(2,c,'#')
for c in (40,92): put(3,c,'#')
for r in range(16,20): put(r,0,'#'*W)           # ground
# --- 0-18 start
put(15,4,'P'); put(15,8,'s'); put(15,11,'r'); put(15,14,'m')
put(12,10,'cc'); put(13,9,'c'); put(13,12,'c')
# --- 19-34 fire trench with two bridges, a wisp guarding coins
put(16,22,'~~~~~')                               # fire cols 22-26 (hazard pits <= 5 wide: ejection-arc rule)
put(13,20,'=====')                                # bridge A cols 20-24
put(11,25,'=====')                                # bridge B cols 25-29 (higher)
put(9,26,'c.c.c'); put(8,28,'W')                 # coins over bridge B, wisp above them
put(15,31,'K'); put(15,33,'s'); put(15,35,'S')            # creeper waits past the campfire
# --- 35-58 soot creeper ledge run + diver room
put(14,36,'#####'); put(15,36,'#####')            # step block cols 36-40 (2 high)
put(13,38,'S')                                     # creeper walks off the step
put(11,43,'====='); put(9,49,'=====')              # rising platforms
put(7,44,'D'); put(4,52,'D')                       # divers hover above the platforms (clear of standing height)
put(8,49,'c'); put(8,52,'c'); put(12,44,'c')
put(15,46,'S'); put(15,52,'a')
put(6,55,'=====')                                  # top shelf
put(5,57,'f')                                      # feather on the top shelf
# --- 59-72 ground vault 1 + hound corridor
put(14,60,'B...B'); put(15,60,'B.X.B')
put(15,66,'H')                                     # slag hound waits where the vault jump lands
put(13,70,'###'); put(14,70,'###'); put(15,70,'###')   # 3-high wall: double-jump it with the hound on your heels
put(15,74,'r')
put(12,64,'c.c.c')
# --- 73-90 pit + totem pillar + chest, campfire
put(15,75,'K'); put(15,77,'s')
put(16,80,'^^^^')                                  # spike bed cols 80-83
put(13,78,'=======')                               # bridge cols 78-84
put(11,80,'c.c'); put(9,81,'D')                   # diver watches the spike bridge
put(14,87,'###'); put(15,87,'###'); put(13,88,'O') # totem pillar cols 87-89
put(15,92,'C'); put(15,94,'h')
# --- 95-112 second hound + rotshield gauntlet under an elevated vault
put(15,97,'H'); put(15,103,'R'); put(15,108,'S'); put(15,105,'r')
put(12,96,'c.c.c.c'); put(11,101,'W')             # wisp hunts over the gauntlet
put(13,100,'=====')
put(10,104,'#####'); put(8,104,'B...B'); put(9,104,'B.X.B')   # vault 2: floor row 10, walls 8-9
put(7,104,'#####'); put(6,105,'c.c')                          # roof + roof coins
put(10,99,'====='); put(11,93,'=====')                        # approach platforms
put(9,112,'W')                                                # wisp lurking right of the vault
# --- 113-129 finish
put(14,110,'###'); put(15,110,'###')              # 2-high step out of the gauntlet
put(12,114,'c.c'); put(15,116,'C'); put(15,118,'K'); put(15,121,'f'); put(15,124,'m'); put(15,126,'E')
meta="""meta: name=Slag Cellar
meta: lore=Below the kiln, the works kept what the fire did not want.
meta: world=2
meta: env=cave
meta: music=cave_combat
meta: par_s=180
meta: sign1=A bonus cellar. Nothing here is required - everything here pays.
meta: sign2=Divers watch the shelves. Cross under one at a time, then swing up.
meta: sign3=Hounds run flat ground. When one crouches, be somewhere else.
"""
open('assets/levels/w2_bonus.txt','w').write(meta+'\n'.join(''.join(r) for r in g)+'\n')
print('\n'.join(''.join(r) for r in g))
