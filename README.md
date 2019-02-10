
# PPM/2

## What is It?
PPM/2 Is a Garry's mod addon that allows you to play as customizable pony!
Addon extends the original PonyPlayerModels idea about customizable ponies for player; by full code rewrite and new models!

## The addon is part of [Ponyscape](http://steamcommunity.com/groups/Ponyscape) server project! You can connect to [Ponyscape here](steam://connect/ps.ponyscape.com)!
![Ponyscape logo](https://i.dbotthepony.ru/2017/05/Ponyscape%27s%20PPMv2%20Text.png)

The code is licensed under MIT License

New models are licensed under [Microsoft Game Content License](http://www.xbox.com/en-us/developers/rules)

This project use assets from [Dynamic Surroundings](https://github.com/OreCruncher/DynamicSurroundings), especially it's [sounds](https://github.com/OreCruncher/DynamicSurroundings/blob/master/CREDITS.md#sounds)

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
ppm2_bots                                : 1        : , "sv", "nf", "demo", "lua_server" : Whatever spawn bots as ponies
ppm2_debug                               : 0        : , "sv", "demo", "lua_server" : Enables debug printing. LOTS OF IT. 1 - simple messages; 2 - messages with traceback.
ppm2_disable_flexes                      : 0        : , "sv", "demo", "lua_server" : Disable pony flexes controllers. Saves some FPS.
ppm2_fly                                 : cmd      :                  :
ppm2_no_hoofsound                        : 0        : , "sv", "rep", "demo", "lua_server" : Disable hoofstep sound play time
ppm2_sv_allow_resize                     : 1        : , "sv", "nf", "rep", "demo", "lua_server" : Allow to resize ponies. Disables resizing completely (visual; mechanical)
ppm2_sv_dmg                              : 1        : , "sv", "nf", "demo", "lua_server" : Enable hitbox damage scailing
ppm2_sv_dmg_chest                        : 1        : , "sv", "nf", "demo", "lua_server" : Damage scale when pony-player got shot in chest
ppm2_sv_dmg_head                         : 2        : , "sv", "nf", "demo", "lua_server" : Damage scale when pony-player got shot in head
ppm2_sv_dmg_lbhoof                       : 0        : , "sv", "nf", "demo", "lua_server" : Damage scale when pony-player got shot in back-forward hoof
ppm2_sv_dmg_lfhoof                       : 0        : , "sv", "nf", "demo", "lua_server" : Damage scale when pony-player got shot in left-forward hoof
ppm2_sv_dmg_rbhoof                       : 0        : , "sv", "nf", "demo", "lua_server" : Damage scale when pony-player got shot in back-forward hoof
ppm2_sv_dmg_rfhoof                       : 0        : , "sv", "nf", "demo", "lua_server" : Damage scale when pony-player got shot in right-forward hoof
ppm2_sv_dmg_stomach                      : 1        : , "sv", "nf", "demo", "lua_server" : Damage scale when pony-player got shot in stomach
ppm2_sv_draw_hands                       : 1        : , "sv", "nf", "rep", "demo", "lua_server" : Should draw hooves as viewmodel
ppm2_sv_edit_no_players                  : 1        : , "sv", "nf", "rep", "demo", "lua_server" : When unrestricted edit allowed, do not allow to edit players.
ppm2_sv_edit_ragdolls_only               : 0        : , "sv", "nf", "rep", "demo", "lua_server" : Allow to edit only ragdolls
ppm2_sv_editor_dist                      : 0        : , "sv", "nf", "rep", "demo", "lua_server" : Distance limit in PPM/2 Editor/2
ppm2_sv_flight                           : 1        : , "sv", "nf", "rep", "demo", "lua_server" : Allow flight for pegasus and alicorns. It obeys PlayerNoClip hook.
ppm2_sv_flight_force                     : 0        : , "sv", "nf", "rep", "demo", "lua_server" : Ignore PlayerNoClip hook
ppm2_sv_flight_nocheck                   : 0        : , "sv", "nf", "rep", "demo", "lua_server" : Suppress PlayerNoClip clientside check (useful with bad coded addons. known are - ULX, Cinema, FAdmin)
ppm2_sv_flightdmg                        : 1        : , "sv", "nf", "rep", "demo", "lua_server" : Damage players in flight
ppm2_sv_new_ragdolls                     : 1        : , "sv", "nf", "rep", "demo", "lua_server" : Enable new ragdolls
ppm2_sv_newhull                          : 1        : , "sv", "nf", "rep", "demo", "lua_server" : Use proper collision box for ponies. Slightly affects jump mechanics. When disabled, unexpected behaviour could happen.
ppm2_sv_ragdoll_damage                   : 1        : , "sv", "nf", "demo", "lua_server" : Should death ragdoll cause damage?
ppm2_sv_ragdoll_physgun                  : 1        : , "sv", "nf", "rep", "demo", "lua_server" : Allow physgun usage on player death ragdolls
ppm2_sv_ragdoll_toolgun                  : 0        : , "sv", "nf", "rep", "demo", "lua_server" : Allow toolgun usage on player death ragdolls
ppm2_sv_ragdolls_collisions              : 1        : , "sv", "nf", "rep", "demo", "lua_server" : Enable ragdolls collisions
--------------
 28 convars/concommands for [ppm2]
```

## Clientside Accessable CVars
```
cvar list
--------------
ppm2_cl_draw_hands                       : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Should draw hooves as viewmodel
ppm2_cl_emotes_chat                      : 1        : , "demo", "server_can_execute", "cl", "lua_client" : Show emotes list while chatbox is open
ppm2_cl_emotes_context                   : 1        : , "demo", "server_can_execute", "cl", "lua_client" : Show emotes list while context menu is open
ppm2_cl_hires_body                       : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Use high resoluation when rendering pony bodies. AFFECTS ONLY TEXTURE COMPILATION TIME (increases lag spike on pony data load)
ppm2_cl_hires_generic                    : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Create 1024x1024 textures instead of 512x512 on texture compiling
ppm2_cl_no_hoofsound                     : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Disable hoofstep sound play time
ppm2_cl_reflections                      : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Calculate eye reflections in real time. Needs beefy computer.
ppm2_cl_reflections_drawdist             : 192      : , "demo", "server_can_execute", "cl", "lua_client" : Reflections maximal draw distance
ppm2_cl_reflections_renderdist           : 1000     : , "demo", "server_can_execute", "cl", "lua_client" : Reflection scene draw distance (ZFar)
ppm2_cl_reflections_size                 : 512      : , "demo", "server_can_execute", "cl", "lua_client" : Reflections size. Must be multiple to 2! (16, 32, 64, 128, 256)
ppm2_cleanup                             : cmd      :                  :
ppm2_debug                               : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Enables debug printing. LOTS OF IT. 1 - simple messages; 2 - messages with traceback.
ppm2_disable_flexes                      : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Disable pony flexes controllers. Saves some FPS.
ppm2_draw_legs                           : 1        : , "demo", "server_can_execute", "cl", "lua_client" : Draw pony legs.
ppm2_editor                              : cmd      :                  :
ppm2_editor3                             : cmd      :                  :
ppm2_editor_advanced                     : 1        : , "demo", "server_can_execute", "cl", "lua_client" : Show all options. Keep in mind Editor3 acts different with this option.
ppm2_editor_fullbright                   : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Disable lighting in editor
ppm2_editor_model                        : 0        : , "demo", "server_can_execute", "cl", "lua_client" : What model to use in editor. Valids are 'default', 'cppm', 'new'
ppm2_editor_reload                       : cmd      :                  :
ppm2_editor_width                        : 384      : , "demo", "server_can_execute", "cl", "lua_client" : Width of editor panel, in pixels
ppm2_emote                               : cmd      :                  :
ppm2_flashlight_pass                     : 0        : , "demo", "server_can_execute", "cl", "lua_client" : Enable flashlight render pass. This kills FPS.
ppm2_flight_djump                        : 1        : , "demo", "server_can_execute", "cl", "lua_client" : Double press of Jump activates flight
ppm2_horn_firstperson                    : 1        : , "nf", "demo", "server_can_execute", "cl", "lua_client" : Visual horn effetcs in first person
ppm2_horn_glow                           : 1        : , "nf", "demo", "server_can_execute", "cl", "lua_client" : Visual horn glow when player uses physgun
ppm2_horn_nobeam                         : 1        : , "nf", "demo", "server_can_execute", "cl", "lua_client" : Hide physgun beam
ppm2_horn_particles                      : 1        : , "nf", "demo", "server_can_execute", "cl", "lua_client" : Visual horn particles when player uses physgun
ppm2_legs_new                            : 1        : , "demo", "server_can_execute", "cl", "lua_client" : Use RenderOverride function for legs drawing
ppm2_new_editor                          : cmd      :                  :
ppm2_new_editor_reload                   : cmd      :                  :
ppm2_no_hoofsound                        : 0        : , "rep", "demo", "server_can_execute", "cl", "lua_client" : Disable hoofstep sound play time
ppm2_old_editor                          : cmd      :                  :
ppm2_old_editor_reload                   : cmd      :                  :
ppm2_reload                              : cmd      :                  :
ppm2_reload_materials                    : cmd      :                  :
ppm2_render_legsdepth                    : 1        : , "nf", "demo", "server_can_execute", "cl", "lua_client" : Render legs in depth pass. Useful with Boken DoF enabled
ppm2_render_legstype                     : 0        : , "demo", "server_can_execute", "cl", "lua_client" : When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables
ppm2_render_stare                        : 1        : , "demo", "server_can_execute", "cl", "lua_client" : Make eyes follow players and move when idling
ppm2_require                             : cmd      :                  :
ppm2_sv_allow_resize                     : 1        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Allow to resize ponies. Disables resizing completely (visual; mechanical)
ppm2_sv_draw_hands                       : 1        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Should draw hooves as viewmodel
ppm2_sv_edit_no_players                  : 1        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : When unrestricted edit allowed, do not allow to edit players.
ppm2_sv_edit_ragdolls_only               : 0        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Allow to edit only ragdolls
ppm2_sv_editor_dist                      : 0        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Distance limit in PPM/2 Editor/2. 0 - means default (400)
ppm2_sv_flight                           : 1        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Allow flight for pegasus and alicorns. It obeys PlayerNoClip hook.
ppm2_sv_flight_force                     : 0        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Ignore PlayerNoClip hook
ppm2_sv_flight_nocheck                   : 0        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Suppress PlayerNoClip clientside check (useful with bad coded addons. known are - ULX, Cinema, FAdmin)
ppm2_sv_flightdmg                        : 1        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Damage players in flight
ppm2_sv_new_ragdolls                     : 1        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Enable new ragdolls
ppm2_sv_newhull                          : 1        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Use proper collision box for ponies. Slightly affects jump mechanics. When disabled, unexpected behaviour could happen.
ppm2_sv_ragdoll_physgun                  : 1        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Allow physgun usage on player death ragdolls
ppm2_sv_ragdoll_toolgun                  : 0        : , "nf", "rep", "demo", "server_can_execute", "cl", "lua_client" : Allow toolgun usage on player death ragdolls
--------------
 53 convars/concommands for [ppm2]
```

# Technical
## Old Model Bones

```lua
-- 0   LrigPelvis
-- 1   LrigSpine1
-- 2   LrigSpine2
-- 3   LrigRibcage
-- 4   LrigNeck1
-- 5   LrigNeck2
-- 6   LrigNeck3
-- 7   LrigScull
-- 8   Lrig_LEG_BL_Femur
-- 9   Lrig_LEG_BL_Tibia
-- 10  Lrig_LEG_BL_LargeCannon
-- 11  Lrig_LEG_BL_PhalanxPrima
-- 12  Lrig_LEG_BL_RearHoof
-- 13  Lrig_LEG_BR_Femur
-- 14  Lrig_LEG_BR_Tibia
-- 15  Lrig_LEG_BR_LargeCannon
-- 16  Lrig_LEG_BR_PhalanxPrima
-- 17  Lrig_LEG_BR_RearHoof
-- 18  Lrig_LEG_FL_Scapula
-- 19  Lrig_LEG_FL_Humerus
-- 20  Lrig_LEG_FL_Radius
-- 21  Lrig_LEG_FL_Metacarpus
-- 22  Lrig_LEG_FL_PhalangesManus
-- 23  Lrig_LEG_FL_FrontHoof
-- 24  Lrig_LEG_FR_Scapula
-- 25  Lrig_LEG_FR_Humerus
-- 26  Lrig_LEG_FR_Radius
-- 27  Lrig_LEG_FR_Metacarpus
-- 28  Lrig_LEG_FR_PhalangesManus
-- 29  Lrig_LEG_FR_FrontHoof
-- 30  Mane01
-- 31  Mane02
-- 32  Mane03
-- 33  Mane04
-- 34  Mane05
-- 35  Mane06
-- 36  Mane07
-- 37  Mane03_tip
-- 38  Tail01
-- 39  Tail02
-- 40  Tail03
```

## New model bones
```lua
-- 0    LrigPelvis
-- 1    Lrig_LEG_BL_Femur
-- 2    Lrig_LEG_BL_Tibia
-- 3    Lrig_LEG_BL_LargeCannon
-- 4    Lrig_LEG_BL_PhalanxPrima
-- 5    Lrig_LEG_BL_RearHoof
-- 6    Lrig_LEG_BR_Femur
-- 7    Lrig_LEG_BR_Tibia
-- 8    Lrig_LEG_BR_LargeCannon
-- 9    Lrig_LEG_BR_PhalanxPrima
-- 10   Lrig_LEG_BR_RearHoof
-- 11   LrigSpine1
-- 12   LrigSpine2
-- 13   LrigRibcage
-- 14   Lrig_LEG_FL_Scapula
-- 15   Lrig_LEG_FL_Humerus
-- 16   Lrig_LEG_FL_Radius
-- 17   Lrig_LEG_FL_Metacarpus
-- 18   Lrig_LEG_FL_PhalangesManus
-- 19   Lrig_LEG_FL_FrontHoof
-- 20   Lrig_LEG_FR_Scapula
-- 21   Lrig_LEG_FR_Humerus
-- 22   Lrig_LEG_FR_Radius
-- 23   Lrig_LEG_FR_Metacarpus
-- 24   Lrig_LEG_FR_PhalangesManus
-- 25   Lrig_LEG_FR_FrontHoof
-- 26   LrigNeck1
-- 27   LrigNeck2
-- 28   LrigNeck3
-- 29   LrigScull
-- 30   Jaw
-- 31   Ear_L
-- 32   Ear_R
-- 33   Mane02
-- 34   Mane03
-- 35   Mane03_tip
-- 36   Mane04
-- 37   Mane05
-- 38   Mane06
-- 39   Mane07
-- 40   Mane01
-- 41   Lrigweaponbone
-- 42   right_hand
-- 43   wing_l
-- 44   wing_r
-- 45   Tail01
-- 46   Tail02
-- 47   Tail03
-- 48   wing_l_bat
-- 49   wing_r_bat
-- 50   wing_open_l
-- 51   wing_open_r
```

## Flexes
```
0   eyes_updown
1   eyes_rightleft
2   JawOpen
3   JawClose
4   Smirk
5   Frown
6   Stretch
7   Pucker
8   Grin
9   CatFace
10  Mouth_O
11  Mouth_O2
12  Mouth_Full
13  Tongue_Out
14  Tongue_Up
15  Tongue_Down
16  NoEyelashes
17  Eyes_Blink
18  Left_Blink
19  Right_Blink
20  Scrunch
21  FatButt
22  Stomach_Out
23  Stomach_In
24  Throat_Bulge
25  Male
26  Hoof_Fluffers
27  o3o
28  Ear_Fluffers
29  Fangs
30  Claw_Teeth
31  Fang_Test
32  angry_eyes
33  sad_eyes
34  Eyes_Blink_Lower
35  Male_2
36  Buff_Body
37  Manliest_Chin
38  Lowerlid_Raise
39  Happy_Eyes
40  Duck
41  Fatbutt2
```
