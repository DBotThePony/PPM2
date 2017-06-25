
# PPM/2

## What is It?
PPM/2 Is a Garry's mod addon that allows you to play as customizable pony!
Addon extends the original PonyPlayerModels idea about customizable ponies for player; by full code rewrite and new models!

## The addon is part of [Ponyscape](http://steamcommunity.com/groups/Ponyscape) server project! You can connect to [Ponyscape here](steam://connect/ps.ponyscape.com)!
![Ponyscape logo](https://dbot.serealia.ca/sharex/2017/05/Ponyscape%27s%20PPMv2%20Text.png)

## The code is licensed under [Apache software foundation License 2.0](LICENSE) ([web version](https://www.apache.org/licenses/LICENSE-2.0))
## New models are licensed under [Microsoft Game Content License](http://www.xbox.com/en-us/developers/rules)

# Features
 * Fully customizable ponies! Even **more customizable than you think**! Just checkout advanced mode in editor!
 * Total code rewrite; now all functions are working on Event Oriented Programming; it means that PPM/2 can work much faster with more features included when compared to original PPM
 * New models - it allows to add huge amount of manes and tails
 * Multisupport - Don't worry! PPM/2 supports **three** various ponies models. It includes the new one; the CPPM one and the old one; no needs to remake your PACs!
 * Flexes - **YES!** your ponies now show their feelings! Sad; anger; fear and other emotes you can see on new ponies models! Also you can use them in your PACs!
 * Out-of-box support for URL textures. You can now throw away the PAC3 submaterial parts, because PPM/2 already allows you to put URL textures on pony parts!
 * Yes; you can import the old data.
 * On new models, manes and tails works as separated models; like TF2 hats.

# ConVars
## Serverside accessable cvars
```
cvar list
--------------
ppm2_bots                                : 1        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Whatever spawn bots as ponies
ppm2_debug                               : 0        : , "sv", "demo", "clientcmd_can_execute", "lua_server" : Enables debug printing. LOTS OF IT. 1 - simple messages; 2 - messages with traceback.
ppm2_disable_flexes                      : 0        : , "sv", "demo", "clientcmd_can_execute", "lua_server" : Disable pony flexes controllers. Saves some FPS.
ppm2_fly                                 : cmd      :                  : 
ppm2_no_hoofsound                        : 0        : , "sv", "rep", "demo", "clientcmd_can_execute", "lua_server" : Disable hoofstep sound play time
ppm2_sv_dmg                              : 1        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Enable hitbox damage scailing
ppm2_sv_dmg_chest                        : 1        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Damage scale when pony-player got shot in chest
ppm2_sv_dmg_head                         : 2        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Damage scale when pony-player got shot in head
ppm2_sv_dmg_lbhoof                       : 0        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Damage scale when pony-player got shot in back-forward hoof
ppm2_sv_dmg_lfhoof                       : 0        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Damage scale when pony-player got shot in left-forward hoof
ppm2_sv_dmg_rbhoof                       : 0        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Damage scale when pony-player got shot in back-forward hoof
ppm2_sv_dmg_rfhoof                       : 0        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Damage scale when pony-player got shot in right-forward hoof
ppm2_sv_dmg_stomach                      : 1        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Damage scale when pony-player got shot in stomach
ppm2_sv_edit_no_players                  : 1        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : When unrestricted edit allowed, do not allow to edit players.
ppm2_sv_edit_ragdolls_only               : 0        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : Allow to edit only ragdolls
ppm2_sv_flight                           : 1        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : Allow flight for pegasus and alicorns. It obeys PlayerNoClip hook.
ppm2_sv_flight_force                     : 0        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : Ignore PlayerNoClip hook
ppm2_sv_flightdmg                        : 1        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : Damage players in flight
ppm2_sv_new_ragdolls                     : 1        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : Enable new ragdolls
ppm2_sv_newhull                          : 1        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : Use proper collision box for ponies. Slightly affects jump mechanics. When disabled, unexpected behaviour could happen.
ppm2_sv_ragdoll_damage                   : 1        : , "sv", "nf", "demo", "clientcmd_can_execute", "lua_server" : Should death ragdoll cause damage?
ppm2_sv_ragdoll_physgun                  : 1        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : Allow physgun usage on player death ragdolls
ppm2_sv_ragdoll_toolgun                  : 1        : , "sv", "nf", "rep", "demo", "clientcmd_can_execute", "lua_server" : Allow toolgun usage on player death ragdolls
--------------
 23 convars/concommands for [ppm2_]
```

## Clientside Accessable CVars
```
cvar list
--------------
ppm2_alternative_render                  : 0        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Enable alternative render mode. This decreases FPS, enables compability with third-party BROKEN addons.
ppm2_cl_hires_body                       : 0        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Use high resoluation when rendering pony bodies. AFFECTS ONLY TEXTURE COMPILATION TIME (increases lag spike on pony data load)
ppm2_cl_hires_generic                    : 0        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Create 1024x1024 textures instead of 512x512 on texture compiling
ppm2_cl_no_hoofsound                     : 0        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Disable hoofstep sound play time
ppm2_cleanup                             : cmd      :                  : 
ppm2_debug                               : 0        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Enables debug printing. LOTS OF IT. 1 - simple messages; 2 - messages with traceback.
ppm2_disable_flexes                      : 0        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Disable pony flexes controllers. Saves some FPS.
ppm2_draw_legs                           : 1        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Draw pony legs.
ppm2_editor                              : cmd      :                  : 
ppm2_editor_advanced                     : 1        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Show all options
ppm2_editor_fullbright                   : 1        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Disable lighting in editor
ppm2_editor_model                        : 0        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : What model to use in editor. Valids are 'default', 'cppm', 'new'
ppm2_editor_reload                       : cmd      :                  : 
ppm2_editor_width                        : 384      : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Width of editor panel, in pixels
ppm2_emote                               : cmd      :                  : 
ppm2_flashlight_pass                     : 1        : , "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Enable flashlight render pass. This kills FPS.
ppm2_no_hoofsound                        : 0        : , "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Disable hoofstep sound play time
ppm2_reload                              : cmd      :                  : 
ppm2_reload_materials                    : cmd      :                  : 
ppm2_require                             : cmd      :                  : 
ppm2_sv_edit_no_players                  : 1        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : When unrestricted edit allowed, do not allow to edit players.
ppm2_sv_edit_ragdolls_only               : 0        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Allow to edit only ragdolls
ppm2_sv_flight                           : 0        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Allow flight for pegasus and alicorns. It obeys PlayerNoClip hook.
ppm2_sv_flight_force                     : 0        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Ignore PlayerNoClip hook
ppm2_sv_flightdmg                        : 1        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Damage players in flight
ppm2_sv_new_ragdolls                     : 1        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Enable new ragdolls
ppm2_sv_newhull                          : 1        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Use proper collision box for ponies. Slightly affects jump mechanics. When disabled, unexpected behaviour could happen.
ppm2_sv_ragdoll_physgun                  : 1        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Allow physgun usage on player death ragdolls
ppm2_sv_ragdoll_toolgun                  : 0        : , "nf", "rep", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Allow toolgun usage on player death ragdolls
ppm2_task_render_type                    : 1        : , "nf", "demo", "server_can_execute", "clientcmd_can_execute", "cl", "lua_client" : Task rendering type (e.g. pony ragdolls and NPCs). 1 - better render; less conflicts; more FPS. 0 - 'old-style' render; possibl
--------------
 30 convars/concommands for [ppm2]
```

# Technical
## Old Model Bones

```
0	LrigPelvis
1	LrigSpine1
2	LrigSpine2
3	LrigRibcage
4	LrigNeck1
5	LrigNeck2
6	LrigNeck3
7	LrigScull
8	Lrig_LEG_BL_Femur
9	Lrig_LEG_BL_Tibia
10	Lrig_LEG_BL_LargeCannon
11	Lrig_LEG_BL_PhalanxPrima
12	Lrig_LEG_BL_RearHoof
13	Lrig_LEG_BR_Femur
14	Lrig_LEG_BR_Tibia
15	Lrig_LEG_BR_LargeCannon
16	Lrig_LEG_BR_PhalanxPrima
17	Lrig_LEG_BR_RearHoof
18	Lrig_LEG_FL_Scapula
19	Lrig_LEG_FL_Humerus
20	Lrig_LEG_FL_Radius
21	Lrig_LEG_FL_Metacarpus
22	Lrig_LEG_FL_PhalangesManus
23	Lrig_LEG_FL_FrontHoof
24	Lrig_LEG_FR_Scapula
25	Lrig_LEG_FR_Humerus
26	Lrig_LEG_FR_Radius
27	Lrig_LEG_FR_Metacarpus
28	Lrig_LEG_FR_PhalangesManus
29	Lrig_LEG_FR_FrontHoof
30	Mane01
31	Mane02
32	Mane03
33	Mane04
34	Mane05
35	Mane06
36	Mane07
37	Mane03_tip
38	Tail01
39	Tail02
40	Tail03
```

## New model bones
```
0	LrigPelvis
1	Lrig_LEG_BL_Femur
2	Lrig_LEG_BL_Tibia
3	Lrig_LEG_BL_LargeCannon
4	Lrig_LEG_BL_PhalanxPrima
5	Lrig_LEG_BL_RearHoof
6	Lrig_LEG_BR_Femur
7	Lrig_LEG_BR_Tibia
8	Lrig_LEG_BR_LargeCannon
9	Lrig_LEG_BR_PhalanxPrima
10	Lrig_LEG_BR_RearHoof
11	LrigSpine1
12	LrigSpine2
13	LrigRibcage
14	Lrig_LEG_FL_Scapula
15	Lrig_LEG_FL_Humerus
16	Lrig_LEG_FL_Radius
17	Lrig_LEG_FL_Metacarpus
18	Lrig_LEG_FL_PhalangesManus
19	Lrig_LEG_FL_FrontHoof
20	Lrig_LEG_FR_Scapula
21	Lrig_LEG_FR_Humerus
22	Lrig_LEG_FR_Radius
23	Lrig_LEG_FR_Metacarpus
24	Lrig_LEG_FR_PhalangesManus
25	Lrig_LEG_FR_FrontHoof
26	LrigNeck1
27	LrigNeck2
28	LrigNeck3
29	LrigScull
30	Jaw
31	Ear_L
32	Ear_R
33	Mane02
34	Mane03
35	Mane03_tip
36	Mane04
37	Mane05
38	Mane06
39	Mane07
40	Mane01
41	Lrigweaponbone
42	Tail01
43	Tail02
44	Tail03
```

## Flexes
```
0	eyes_updown
1	eyes_rightleft
2	JawOpen
3	JawClose
4	Smirk
5	Frown
6	Stretch
7	Pucker
8	Grin
9	CatFace
10	Mouth_O
11	Mouth_O2
12	Mouth_Full
13	Tongue_Out
14	Tongue_Up
15	Tongue_Down
16	NoEyelashes
17	Eyes_Blink
18	Left_Blink
19	Right_Blink
20	Scrunch
21	FatButt
22	Stomach_Out
23	Stomach_In
24	Throat_Bulge
25	Male
26	Hoof_Fluffers
27	o3o
28	Ear_Fluffers
29	Fangs
30	Claw_Teeth
31	Fang_Test
32	angry_eyes
33	sad_eyes
34	Eyes_Blink_Lower
35	Male_2
36	Buff_Body
37	Manliest_Chin
38	Lowerlid_Raise
39	Happy_Eyes
40	Duck
```

# Credits
 * [Ponyscape team](http://steamcommunity.com/groups/Ponyscape) for initializing the project!
 * [Leafo](https://github.com/leafo) for his awesome [Moonscript](http://moonscript.org/)!
 * [Durpy](https://steamcommunity.com/profiles/76561198013875404) for his new pony models!

# Screenshots
## New Models
![Example](https://dbot.serealia.ca/sharex/2017/05/a977f87da5_2017-05-23_08-09-40.png)
![They finally can talk!](https://dbot.serealia.ca/sharex/2017/05/20170521090424_1.jpg)
![It hurts](https://dbot.serealia.ca/sharex/2017/05/b13d6fcbfa_2017-05-21_08-20-42.png)
![xd](https://dbot.serealia.ca/sharex/2017/05/20170520074818_1.jpg)
![SFM feel](https://dbot.serealia.ca/sharex/2017/05/20170521083924_1.jpg)
![funny](https://dbot.serealia.ca/sharex/2017/05/GeYkSCu.jpg)
![angry](https://dbot.serealia.ca/sharex/2017/05/ebd7a24102_2017-05-25_19-15-55.png)
![more angry](https://dbot.serealia.ca/sharex/2017/05/20170525191559_1.jpg)
## Editor
### Overview
![Editor](https://dbot.serealia.ca/sharex/2017/05/8691f15316_2017-05-26_20-31-56.png)
![Eyes](https://dbot.serealia.ca/sharex/2017/05/c7ab9c6eae_2017-05-26_20-32-17.png)
![Emote](https://dbot.serealia.ca/sharex/2017/05/217f6b13cc_2017-05-26_20-32-33.png)
![Customizable body details](https://dbot.serealia.ca/sharex/2017/05/64d1329e56_2017-05-26_20-32-52.png)
![Cutiemark by URL](https://dbot.serealia.ca/sharex/2017/05/0297035e88_2017-05-26_20-34-56.png)
![Import old files](https://dbot.serealia.ca/sharex/2017/05/171457f9b3_2017-05-26_20-35-18.png)
