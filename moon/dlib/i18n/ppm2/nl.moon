
-- Copyright (C) 2017-2020 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


-- editor stuffs

gui.ppm2.dxlevel.not_supported = 'Uw DirectX™ level is te laag. Ten minste 9.0 is vereist. Als je 8.1 voor framerate gebruikt, heb je ofwel de oudste videokaart of slechte drivers.\nOmdat framerate in gmod alleen laag kan zijn vanwege andere addons die zinloze hoge CPU belasting creëren.\nJa, dit bericht zal meerdere malen verschijnen om je te ergeren. Omdat WAT DE NEUK WAAROM ZOU JE MELDINGEN GEVEN OVER ONTBREKENDE TEXTUREN???'
gui.ppm2.dxlevel.toolow = 'DirectX™ level is te laag voor PPM/2'

gui.ppm2.editor.eyes.separate = 'Gebruik gescheiden instellingen voor de ogen'
gui.ppm2.editor.eyes.url = 'Oog URL textuur'
gui.ppm2.editor.eyes.url_desc = 'Bij gebruik van de oog-URL-structuur; De volgende opties hebben geen effect'

gui.ppm2.editor.eyes.lightwarp_desc = 'Lightwarp heeft alleen effect op EyeRefract ogen'
gui.ppm2.editor.eyes.lightwarp = "Lightwarp"
gui.ppm2.editor.eyes.desc1 = "Lightwarp textuur URL invoer\nIt moet 256x16 zijn!"
gui.ppm2.editor.eyes.desc2 = "Glanssterkte\nDeze parameters passen de sterkte van real time reflecties op het oog aan\nOm veranderingen te zien, zet ppm2_cl_reflections convar op 1\nAndere spelers zouden alleen reflecties zien met ppm2_cl_reflecties ingesteld op 1\n0 - is gematteerd; 1 - is gespiegeld"

for _, {tprefix, prefix} in ipairs {{'def', ''}, {'left', 'Left '}, {'right', 'Right '}}
	gui.ppm2.editor.eyes[tprefix].lightwarp.shader = "#{prefix}Gebruik EyeRefract shader"
	gui.ppm2.editor.eyes[tprefix].lightwarp.cornera = "#{prefix}Gebruik Eye Cornera diffuus"
	gui.ppm2.editor.eyes[tprefix].lightwarp.glossiness = "#{prefix}Glans"

	gui.ppm2.editor.eyes[tprefix].type = "#{prefix}Oogtype"
	gui.ppm2.editor.eyes[tprefix].reflection_type = "#{prefix}Type oogreflectie"
	gui.ppm2.editor.eyes[tprefix].lines = "#{prefix}Ooglijnen"
	gui.ppm2.editor.eyes[tprefix].derp = "#{prefix}Derp ogen"
	gui.ppm2.editor.eyes[tprefix].derp_strength = "#{prefix}Derp oog sterkte"
	gui.ppm2.editor.eyes[tprefix].iris_size = "#{prefix}Ooggrootte"

	gui.ppm2.editor.eyes[tprefix].points_inside = "#{prefix}Ooglijntjes binnenin"
	gui.ppm2.editor.eyes[tprefix].width = "#{prefix}Oogbreedte"
	gui.ppm2.editor.eyes[tprefix].height = "#{prefix}Ooghoogte"

	gui.ppm2.editor.eyes[tprefix].pupil.width = "#{prefix}Pupil breedte"
	gui.ppm2.editor.eyes[tprefix].pupil.height = "#{prefix}Pupil hoogte"
	gui.ppm2.editor.eyes[tprefix].pupil.size = "#{prefix}Pupil grootte"

	gui.ppm2.editor.eyes[tprefix].pupil.shift_x = "#{prefix}Pupil verschuiving X"
	gui.ppm2.editor.eyes[tprefix].pupil.shift_y = "#{prefix}Pupil verschuiving Y"
	gui.ppm2.editor.eyes[tprefix].pupil.rotation = "#{prefix}Oog rotatie"

	gui.ppm2.editor.eyes[tprefix].background = "#{prefix}Oog achtergrond"
	gui.ppm2.editor.eyes[tprefix].pupil_size = "#{prefix}Pupil"
	gui.ppm2.editor.eyes[tprefix].top_iris = "#{prefix}Bovenste oog iris"
	gui.ppm2.editor.eyes[tprefix].bottom_iris = "#{prefix}Onderste oog iris"
	gui.ppm2.editor.eyes[tprefix].line1 = "#{prefix}Oog lijn 1"
	gui.ppm2.editor.eyes[tprefix].line2 = "#{prefix}Oog lijn 2"
	gui.ppm2.editor.eyes[tprefix].reflection = "#{prefix}Oogreflectie effect"
	gui.ppm2.editor.eyes[tprefix].effect = "#{prefix}Oog effect"

gui.ppm2.editor.generic.title = 'PPM/2 Pony Editor'
gui.ppm2.editor.generic.title_file = '%q - PPM/2 Pony Editor'
gui.ppm2.editor.generic.title_file_unsaved = '%q* - PPM/2 Pony Editor (niet opgeslagen wijzigingen!)'

gui.ppm2.editor.generic.yes = 'Yas!'
gui.ppm2.editor.generic.no = 'Noh!'
gui.ppm2.editor.generic.ohno = 'Onoh!'
gui.ppm2.editor.generic.okay = 'Okai ;w;'
gui.ppm2.editor.generic.datavalue = '%s\nGegevenswaarde: %q'
gui.ppm2.editor.generic.url = '%s\n\nLink gaat naar: %s'
gui.ppm2.editor.generic.url_field = 'URL veld'
gui.ppm2.editor.generic.spoiler = 'Mysterieuze spoiler'

gui.ppm2.editor.generic.restart.needed = 'Editor moet opnieuw worden opgestart'
gui.ppm2.editor.generic.restart.text = 'U moet de editor herstarten voor het toepassen van wijzigingen.\nNu herstarten?\nNiet opgeslagen gegevens gaan verloren!'
gui.ppm2.editor.generic.fullbright = 'Vol helder'
gui.ppm2.editor.generic.wtf = 'Om de een of andere reden heeft uw speler geen NetworkedPonyData - Niets te bewerken!\nProbeer ppm2_reload in je console en probeer de editor opnieuw te openen'

gui.ppm2.editor.io.random = 'Willekeurig!'
gui.ppm2.editor.io.newfile.title = 'Nieuw Bestand'
gui.ppm2.editor.io.newfile.confirm = 'Wilt u echt een nieuw bestand aanmaken?'
gui.ppm2.editor.io.newfile.toptext = 'Reset'
gui.ppm2.editor.io.delete.confirm = 'Wilt u dat bestand echt verwijderen?\nHet zal voor altijd verdwenen zijn!\n(een lange tijd!)'
gui.ppm2.editor.io.delete.title = 'Echt verwijderen?'

gui.ppm2.editor.io.filename = 'Bestandsnaam'
gui.ppm2.editor.io.hint = 'Bestand openen door te dubbelklikken'
gui.ppm2.editor.io.reload = 'Bestandslijst opnieuw laden'
gui.ppm2.editor.io.failed = 'Heeft niet kunnen importeren.'

gui.ppm2.editor.io.warn.oldfile = '!!! Het kan wel of niet werken. U zult worden geplet.'
gui.ppm2.editor.io.warn.text = "Op dit moment heeft u uw wijzigingen niet aangegeven.\nWilt u echt een ander bestand openen?"
gui.ppm2.editor.io.warn.header = 'Niet opgeslagen wijzigingen!'
gui.ppm2.editor.io.save.button = 'Opslaan'
gui.ppm2.editor.io.save.text = 'Voer de bestandsnaam in zonder ppm2/ en .dat\nTip: om op te slaan als autoload, type "_current" (zonder citaten)'
gui.ppm2.editor.io.wear = 'Wijzigingen aanbrengen (dragen)'

gui.ppm2.editor.seq.standing = 'Staand'
gui.ppm2.editor.seq.move = 'In beweging'
gui.ppm2.editor.seq.walk = 'Wandelen'
gui.ppm2.editor.seq.sit = 'Zitten'
gui.ppm2.editor.seq.swim = 'Zwemmen'
gui.ppm2.editor.seq.run = 'Rennen'
gui.ppm2.editor.seq.duckwalk = 'Wandel als een eend'
gui.ppm2.editor.seq.duck = 'Doe als een eend'
gui.ppm2.editor.seq.jump = 'Springen'

gui.ppm2.editor.misc.race = 'Ras'
gui.ppm2.editor.misc.weight = 'Gewicht'
gui.ppm2.editor.misc.size = 'Pony grootte'
gui.ppm2.editor.misc.hide_weapons = 'Moet wapens verbergen'
gui.ppm2.editor.misc.chest = 'Mannelijke borstkas'
gui.ppm2.editor.misc.gender = 'Geslacht'
gui.ppm2.editor.misc.wings = 'Vleugels Type'
gui.ppm2.editor.misc.flexes = 'Flexibele besturing'
gui.ppm2.editor.misc.no_flexes2 = 'Geen flexibiliteit op het nieuwe model'
gui.ppm2.editor.misc.no_flexes_desc = 'U kunt elke flexstatuscontroller apart uitschakelen\nDeze buigingen kunnen dus worden aangepast met add-ons van derden (zoals PAC3)'

gui.ppm2.editor.misc.hide_pac3 = 'Entiteiten verbergen wanneer een PAC3 entiteit wordt gebruikt'
gui.ppm2.editor.misc.hide_mane = 'Mane verbergen wanneer een PAC3 entiteit wordt gebruikt'
gui.ppm2.editor.misc.hide_tail = 'Verberg de staart wanneer een PAC3 entiteit wordt gebruikt'
gui.ppm2.editor.misc.hide_socks = 'Sokken verbergen bij gebruik van een PAC3 entiteit'

gui.ppm2.editor.tabs.main = 'Algemeen'
gui.ppm2.editor.tabs.files = 'Bestanden'
gui.ppm2.editor.tabs.old_files = 'Oude Bestanden'
gui.ppm2.editor.tabs.cutiemark = 'Cutiemark'
gui.ppm2.editor.tabs.head = 'Hoofd anatomie'
gui.ppm2.editor.tabs.eyes = 'Ogen'
gui.ppm2.editor.tabs.face = 'Gezicht'
gui.ppm2.editor.tabs.mouth = 'Mond'
gui.ppm2.editor.tabs.left_eye = 'Linker oog'
gui.ppm2.editor.tabs.right_eye = 'Rechter oog'
gui.ppm2.editor.tabs.mane_horn = 'Mane en Hoorn'
gui.ppm2.editor.tabs.mane = 'Mane'
gui.ppm2.editor.tabs.details = 'Details'
gui.ppm2.editor.tabs.url_details = 'URL Details'
gui.ppm2.editor.tabs.url_separated_details = 'URL Gescheiden Details'
gui.ppm2.editor.tabs.ears = 'Oren'
gui.ppm2.editor.tabs.horn = 'Hoorn'
gui.ppm2.editor.tabs.back = 'Rug'
gui.ppm2.editor.tabs.wings = 'Vleugels'
gui.ppm2.editor.tabs.left = 'Links'
gui.ppm2.editor.tabs.right = 'Rechts'
gui.ppm2.editor.tabs.neck = 'Nek'
gui.ppm2.editor.tabs.body = 'Pony lichaam'
gui.ppm2.editor.tabs.tattoos = 'Tatoeages'
gui.ppm2.editor.tabs.tail = 'Staart'
gui.ppm2.editor.tabs.hooves = 'Hoeven anatomie'
gui.ppm2.editor.tabs.bottom_hoof = 'Onder hoef'
gui.ppm2.editor.tabs.legs = 'Benen'
gui.ppm2.editor.tabs.socks = 'Sokken'
gui.ppm2.editor.tabs.newsocks = 'Nieuwe Sokken'
gui.ppm2.editor.tabs.about = 'Over'

gui.ppm2.editor.old_tabs.mane_tail = 'Mane en staart'
gui.ppm2.editor.old_tabs.wings_and_horn_details = 'Vleugels en hoorn details'
gui.ppm2.editor.old_tabs.wings_and_horn = 'Vleugels en hoorn'
gui.ppm2.editor.old_tabs.body_details = 'Lichaam details'
gui.ppm2.editor.old_tabs.mane_tail_detals = 'Mane en staart URL details'

gui.ppm2.editor.cutiemark.display = 'Toon cutiemarkering'
gui.ppm2.editor.cutiemark.type = 'Cutiemark type'
gui.ppm2.editor.cutiemark.size = 'Cutiemark grootte'
gui.ppm2.editor.cutiemark.color = 'Cutiemark kleur'
gui.ppm2.editor.cutiemark.input = 'Cutiemark URL afbeelding invoer veld\nMoet PNG of JPEG zijn (werkt hetzelfde als\nPAC3 URL textuur)'

gui.ppm2.editor.face.eyelashes = 'Wimpers'
gui.ppm2.editor.face.eyelashes_color = 'Wimpers kleur'
gui.ppm2.editor.face.eyelashes_phong = 'Wimpers phong parameters'
gui.ppm2.editor.face.eyebrows_color = 'Wenkbrauwen kleur'
gui.ppm2.editor.face.new_muzzle = 'Gebruik nieuwe snuit voor het mannelijk model'

gui.ppm2.editor.face.nose = 'Neus kleur'
gui.ppm2.editor.face.lips = 'Lippen kleur'
gui.ppm2.editor.face.eyelashes_separate_phong = 'Afzonderlijke wimpers Phong'
gui.ppm2.editor.face.eyebrows_glow = 'Gloeiende wenkbrauwen'
gui.ppm2.editor.face.eyebrows_glow_strength = 'Wenkbrauwen gloed sterkte'
gui.ppm2.editor.face.inherit.lips = 'Neem de Lippen kleur van het lichaam'
gui.ppm2.editor.face.inherit.nose = 'Neem de neus kleur van het lichaam'

gui.ppm2.editor.mouth.fangs = 'Tanden'
gui.ppm2.editor.mouth.alt_fangs = 'Alternatieve hoektanden'
gui.ppm2.editor.mouth.claw = 'Klauwtanden'

gui.ppm2.editor.mouth.teeth = 'Tand kleur'
gui.ppm2.editor.mouth.teeth_phong = 'Tanden phong parameters'
gui.ppm2.editor.mouth.mouth = 'Mond kleur'
gui.ppm2.editor.mouth.mouth_phong = 'Mond phong parameters'
gui.ppm2.editor.mouth.tongue = 'Tong kleur'
gui.ppm2.editor.mouth.tongue_phong = 'Tong phong parameters'

gui.ppm2.editor.mane.type = 'Mane Type'
gui.ppm2.editor.mane.phong = 'Afzonderlijk mane phong instellingen van het lichaam'
gui.ppm2.editor.mane.mane_phong = 'Mane phong parameters'
gui.ppm2.editor.mane.phong_sep = 'Gescheiden bovenste en onderste mane kleuren'
gui.ppm2.editor.mane.up.phong = 'Bovenste Mane Phong instellingen'
gui.ppm2.editor.mane.down.type = 'Onderste Mane Type'
gui.ppm2.editor.mane.down.phong = 'Onderste Mane Phong instellingen'
gui.ppm2.editor.mane.newnotice = 'De volgende opties hebben alleen effect op een nieuw model'

for i = 1, 2
	gui.ppm2.editor.mane['color' .. i] = "Mane kleur #{i}"
	gui.ppm2.editor.mane.up['color' .. i] = "Bovenste mane kleur #{i}"
	gui.ppm2.editor.mane.down['color' .. i] = "Onderste mane kleur #{i}"

for i = 1, 6
	gui.ppm2.editor.mane['detail_color' .. i] = "Mane detail kleur #{i}"
	gui.ppm2.editor.mane.up['detail_color' .. i] = "Bovenste mane kleur #{i}"
	gui.ppm2.editor.mane.down['detail_color' .. i] = "Onderste mane kleur #{i}"

	gui.ppm2.editor.url_mane['desc' .. i] = "Mane URL Detail #{i} invoer veld"
	gui.ppm2.editor.url_mane['color' .. i] = "Mane URL detail kleur #{i}"

	gui.ppm2.editor.url_tail['desc' .. i] = "Staart URL Detail #{i} invoer veld"
	gui.ppm2.editor.url_tail['color' .. i] = "Staart URL detail kleur #{i}"

	gui.ppm2.editor.url_mane.sep.up['desc' .. i] = "Bovenste mane URL Detail #{i} invoer veld"
	gui.ppm2.editor.url_mane.sep.up['color' .. i] = "Bovenste Mane URL detail kleur #{i}"

	gui.ppm2.editor.url_mane.sep.down['desc' .. i] = "Onderste mane URL Detail #{i} invoer veld"
	gui.ppm2.editor.url_mane.sep.down['color' .. i] = "Onderste Mane URL detail kleur #{i}"

gui.ppm2.editor.ears.bat = 'Vleermuis pony oren'
gui.ppm2.editor.ears.size = 'Oren grootte'

gui.ppm2.editor.horn.detail_color = 'Hoorn detail kleur'
gui.ppm2.editor.horn.glowing_detail = 'Glanzende Hoorn Detail'
gui.ppm2.editor.horn.glow_strength = 'Horn gloed sterkte'
gui.ppm2.editor.horn.separate_color = 'Aparte hoornkleur van het lichaam'
gui.ppm2.editor.horn.color = 'Hoorn kleur'
gui.ppm2.editor.horn.horn_phong = 'Hoorn phong parameters'
gui.ppm2.editor.horn.magic = 'Hoorn magie kleur'
gui.ppm2.editor.horn.separate_magic_color = 'Aparte magische kleur van oogkleur'
gui.ppm2.editor.horn.separate = 'Aparte hoornkleur van het lichaam'
gui.ppm2.editor.horn.separate_phong = 'Aparte hoorn phong instellingen van het lichaam'

for i = 1, 3
	gui.ppm2.editor.horn.detail['desc' .. i] = "Hoorn URL detail #{i}"
	gui.ppm2.editor.horn.detail['color' .. i] = "URL Detail kleur #{i}"

gui.ppm2.editor.wings.separate_color = 'Aparte vleugel kleur van het lichaam'
gui.ppm2.editor.wings.color = 'Vleugel color'
gui.ppm2.editor.wings.wings_phong = 'Vleugel phong parameters'
gui.ppm2.editor.wings.separate = 'Aparte vleugel kleur van het lichaam'
gui.ppm2.editor.wings.separate_phong = 'Aparte vleugel phong instellingen van het lichaam'
gui.ppm2.editor.wings.bat_color = 'Vleermuis vleugels kleur'
gui.ppm2.editor.wings.bat_skin_color = 'Vleermuis vleugels huidskleur'
gui.ppm2.editor.wings.bat_skin_phong = 'Vleermuis vleugels huid phong parameters'

gui.ppm2.editor.wings.normal = 'Normale vleugels'
gui.ppm2.editor.wings.bat = 'Vleermuisvleugels'
gui.ppm2.editor.wings.bat_skin = 'Vleermuis vleugels huid'

gui.ppm2.editor.wings.left.size = 'Linker vleugel grootte'
gui.ppm2.editor.wings.left.fwd = 'Linker vleugel voor'
gui.ppm2.editor.wings.left.up = 'Linker vleugel boven'
gui.ppm2.editor.wings.left.inside = 'Linker vleugel binnen'

gui.ppm2.editor.wings.right.size = 'Rechter vleugel grootte'
gui.ppm2.editor.wings.right.fwd = 'Rechter vleugel voor'
gui.ppm2.editor.wings.right.up = 'Rechter vleugel boven'
gui.ppm2.editor.wings.right.inside = 'Rechter vleugel binnen'

for i = 1, 3
	gui.ppm2.editor.wings.details.def['detail' .. i] = "Vleugels URL detail #{i}"
	gui.ppm2.editor.wings.details.def['color' .. i] = "URL Detail kleur #{i}"
	gui.ppm2.editor.wings.details.bat['detail' .. i] = "Vleermuisvleugels URL detail #{i}"
	gui.ppm2.editor.wings.details.bat['color' .. i] = "Vleermuisvleugels URL Detail kleur #{i}"
	gui.ppm2.editor.wings.details.batskin['detail' .. i] = "Vleermuisvleugels huid URL detail #{i}"
	gui.ppm2.editor.wings.details.batskin['color' .. i] = "Vleermuisvleugels huid URL Detail kleur #{i}"

gui.ppm2.editor.neck.height = 'Nek hoogte'

gui.ppm2.editor.body.suit = 'Kostuum'
gui.ppm2.editor.body.color = 'Lichaams kleur'
gui.ppm2.editor.body.body_phong = 'Lichaam phong parameters'
gui.ppm2.editor.body.spine_length = 'Rug lengte'
gui.ppm2.editor.body.url_desc = 'Lichaam detail URL afbeelding invoer veld\nMoet PNG of JPEG zijn (werkt hetzelfde als \nPAC3 URL structuur)'

gui.ppm2.editor.body.disable_hoofsteps = 'Hoef stappen uitschakelen'
gui.ppm2.editor.body.disable_wander_sounds = 'Wandelgeluiden uitschakelen'
gui.ppm2.editor.body.disable_new_step_sounds = 'Aangepaste stapgeluiden uitschakelen'
gui.ppm2.editor.body.disable_jump_sound = 'Spring geluid uitschakelen'
gui.ppm2.editor.body.disable_falldown_sound = 'Neer val geluid uitschakelen'
gui.ppm2.editor.body.call_playerfootstep = 'Noem PlayerFootstep bij elk geluid'
gui.ppm2.editor.body.call_playerfootstep_desc = 'Noem PlayerFootstep haak op elk daadwerkelijk geluid dat u hoort.\nMet behulp van deze optie kunnen andere geïnstalleerde addons vertrouwen op PPM2\'s diepgang\ndie luisteren naar PlayerFootstep haak. Dit moet alleen worden uitgeschakeld wanneer u onbetrouwbare resultaten van andere addons krijgt.\nof uw FPS daalt naar lage waarden omdat een van de geïnstalleerde addons slecht gecodeerd is.'

for i = 1, PPM2.MAX_BODY_DETAILS
	gui.ppm2.editor.body.detail['desc' .. i] = "Detail #{i}"
	gui.ppm2.editor.body.detail['color' .. i] = "Detail kleur #{i}"
	gui.ppm2.editor.body.detail['glow' .. i] = "Detail #{i} gloeit"
	gui.ppm2.editor.body.detail['glow_strength' .. i] = "Detail #{i} gloeikracht"

	gui.ppm2.editor.body.detail.url['desc' .. i] = "Detail #{i}"
	gui.ppm2.editor.body.detail.url['color' .. i] = "Detail kleur #{i}"

gui.ppm2.editor.tattoo.edit_keyboard = 'Bewerken met behulp van het toetsenbord'
gui.ppm2.editor.tattoo.type = 'Type'
gui.ppm2.editor.tattoo.over = 'Tatoeage over het lichaam details'
gui.ppm2.editor.tattoo.glow = 'Tatoeage is gloeiend'
gui.ppm2.editor.tattoo.glow_strength = 'De sterkte van de tatoegering gloed'
gui.ppm2.editor.tattoo.color = 'Kleur van Tattoo'

gui.ppm2.editor.tattoo.tweak.rotate = 'Rotatie'
gui.ppm2.editor.tattoo.tweak.x = 'X Positie'
gui.ppm2.editor.tattoo.tweak.y = 'Y Positie'
gui.ppm2.editor.tattoo.tweak.width = 'Breedte Schaal'
gui.ppm2.editor.tattoo.tweak.height = 'Hoogte schaal'

for i = 1, PPM2.MAX_TATTOOS
	gui.ppm2.editor.tattoo['layer' .. i] = "Tatoegeringslaag #{i}"

gui.ppm2.editor.tail.type = 'Staart type'
gui.ppm2.editor.tail.size = 'Staart grootte'
gui.ppm2.editor.tail.tail_phong = 'Staart phong parameters'
gui.ppm2.editor.tail.separate = 'Aparte staart phong instellingen van het lichaam'

for i = 1, 2
	gui.ppm2.editor.tail['color' .. i] = 'Staart kleur ' .. i

for i = 1, 6
	gui.ppm2.editor.tail['detail' .. i] = "Staart detail kleur #{i}"
	gui.ppm2.editor.tail.url['detail' .. i] = "Staart URL detail #{i}"
	gui.ppm2.editor.tail.url['color' .. i] = "Staart URL detail #{i}"

gui.ppm2.editor.hoof.fluffers = 'Hoef Fluffers'

gui.ppm2.editor.legs.height = 'Benen hoogte'
gui.ppm2.editor.legs.socks.simple = 'Sokken (eenvoudige textuur)'
gui.ppm2.editor.legs.socks.model = 'Sokken (als model)'
gui.ppm2.editor.legs.socks.color = 'Sokken model kleur'
gui.ppm2.editor.legs.socks.socks_phong = 'Sokken phong parameters'
gui.ppm2.editor.legs.socks.texture = 'Sokken textuur'
gui.ppm2.editor.legs.socks.url_texture = 'Sokken URL textuur'

for i = 1, 6
	gui.ppm2.editor.legs.socks['color' .. i] = 'Sokken detail kleur ' .. i

gui.ppm2.editor.legs.newsocks.model = 'Sokken (als een nieuw model)'

for i = 1, 3
	gui.ppm2.editor.legs.newsocks['color' .. i] = 'Nieuwe sokken kleur ' .. i

gui.ppm2.editor.legs.newsocks.url = 'Nieuwe sokken URL textuur'

-- shared editor stuffs

gui.ppm2.editor.tattoo.help = "Om de bewerkmodus te verlaten, drukt u op Escape of klikt u ergens met de muis
Om tatto te verplaatsen, gebruikt u WASD
Om hoger/lager te schalen gebruikt u de pijlen omhoog/omlaag
Om breder/kleiner te schalen gebruik rechts/links pijlen
Om links/rechts te draaien gebruikt u Q/E"

gui.ppm2.editor.reset_value = 'Reset %s'

gui.ppm2.editor.phong.info = 'Meer info over Phong op de wiki'
gui.ppm2.editor.phong.exponent = 'Phong Exponent - hoe sterk reflecterende eigenschap\nvan een ponyhuid is\nZet bijna op nul om een robotachtige uitstraling te krijgen van uw\npony huid'
gui.ppm2.editor.phong.exponent_text = 'Phong Exponent'
gui.ppm2.editor.phong.boost.title = 'Phong Verhogen - vermenigvuldigt spiegelende kaartreflecties'
gui.ppm2.editor.phong.boost.boost = 'Phong Verhogen'
gui.ppm2.editor.phong.tint.title = 'Tint kleur - welke kleuren weerspiegelt in de kaart\nWit - Weerspiegelt alle kleuren\n(In witte kamer - witte spiegelkaart)'
gui.ppm2.editor.phong.tint.tint = 'Tint kleur'
gui.ppm2.editor.phong.frensel.front.title = 'Phong Voorkant - Fresnel 0 graden reflectie hoekvermenigvuldiger'
gui.ppm2.editor.phong.frensel.front.front = 'Phong Voorkant'
gui.ppm2.editor.phong.frensel.middle.title = 'Phong Midden - Fresnel 45 graden reflectie hoekvermenigvuldiger'
gui.ppm2.editor.phong.frensel.middle.front = 'Phong Midden'
gui.ppm2.editor.phong.frensel.sliding.title = 'Phong glijdend - Fresnel 90 graden reflectie hoekvermenigvuldiger'
gui.ppm2.editor.phong.frensel.sliding.front = 'Phong glijdend'
gui.ppm2.editor.phong.lightwarp = 'Lightwarp'
gui.ppm2.editor.phong.url_lightwarp = 'Lightwarp textuur URL invoer\nIt moet 256x16 zijn!'
gui.ppm2.editor.phong.bumpmap = 'Bumpmap URL invoer'

gui.ppm2.editor.info.discord = "Sluit je aan bij DBot's Discord!"
gui.ppm2.editor.info.ponyscape = "PPM/2 is een Ponyscape project"
gui.ppm2.editor.info.creator = "PPM/2 is gemaakt en ontwikkeld door DBot"
gui.ppm2.editor.info.newmodels = "Nieuwe modellen zijn gemaakt door Durpy"
gui.ppm2.editor.info.cppmmodels = "CPPM modellen (inclusief ponyhanden) behoren tot UnkN', 'http://steamcommunity.com/profiles/76561198084938735"
gui.ppm2.editor.info.oldmodels = "Oude modellen zijn van Scentus en anderen"
gui.ppm2.editor.info.bugs = "Heeft u een bug gevonden? Meld hier!"
gui.ppm2.editor.info.sources = "U kunt hier bronnen vinden"
gui.ppm2.editor.info.githubsources = "Of op de GitHub-mirror"
gui.ppm2.editor.info.thanks = "Met dank aan everypony die kritiek heeft geuit,\ngeholpen en getest van PPM/2!"

-- other stuff

info.ppm2.fly.pegasus = 'Je moet een Pegasus of een Alicorn zijn om te vliegen!'
info.ppm2.fly.cannot = 'Je kunt %s nu niet gebruiken.'

gui.ppm2.emotes.sad = 'Verdrietig'
gui.ppm2.emotes.wild = 'Wild'
gui.ppm2.emotes.grin = 'Grijns'
gui.ppm2.emotes.angry = 'Boos'
gui.ppm2.emotes.tongue = ':P'
gui.ppm2.emotes.angrytongue = '>:P'
gui.ppm2.emotes.pff = 'Pffff!'
gui.ppm2.emotes.kitty = ':3'
gui.ppm2.emotes.owo = 'oWo'
gui.ppm2.emotes.ugh = 'Uuugh'
gui.ppm2.emotes.lips = 'Lippen likken'
gui.ppm2.emotes.scrunch = 'Knarsen'
gui.ppm2.emotes.sorry = 'Sorry'
gui.ppm2.emotes.wink = 'Knipoogje'
gui.ppm2.emotes.right_wink = 'Rechter knipoogje'
gui.ppm2.emotes.licking = 'Likken'
gui.ppm2.emotes.suggestive_lips = 'Suggestieve lippen likken'
gui.ppm2.emotes.suggestive_no_tongue = 'Suggestieve w/o tong'
gui.ppm2.emotes.gulp = 'Slikken'
gui.ppm2.emotes.blah = 'Blah blah blah'
gui.ppm2.emotes.happi = 'Blij'
gui.ppm2.emotes.happi_grin = 'Blije grijns'
gui.ppm2.emotes.duck = 'EEND'
gui.ppm2.emotes.ducks = 'DUCK INSANITY'
gui.ppm2.emotes.quack = 'KWAK'
gui.ppm2.emotes.suggestive = 'Suggestieve w/ tong'

message.ppm2.emotes.invalid = 'Geen emotie met ID: %s'

gui.ppm2.editor.intro.text = "Welkom bij mijn nieuwe..... Robosurgeon voor pony's! Het stelt u in staat om........\n" ..
	"hmmm..... een pony te worden, en ja, dit proces is IRREVERSCHAPPELIJK! Maar u hoeft zich geen zorgen te maken,\n" ..
	"u verliest geen van uw hersencellen voor, in en na de operatie, omdat het een zeer zachte operatie uitvoert.....\n\n" ..
	"Eigenlijk heb ik geen idee, jij biologisch wezen! Zijn mechanische handen zullen je omhullen in de strakste knuffels die je ooit hebt gekregen!\n" ..
	"En, alstublieft, niet sterven in het proces, want dit zou VERVALLEN VAN UW LEVENSLANGE GARANTIE veroorzaken..... en je zult geen pony zijn!\n" ..
	"----\n\n\n" ..
	"Let op: Haal Robosurgeon niet uit elkaar. Ieders handen/handschoenen niet in bewegende delen van Robosurgeon..\n" ..
	"Schakel het apparaat niet uit terwijl het werkt.\nProbeer niet te weerstaan aan zijn acties.\n" ..
	"Wees altijd voorzichtig met Robosurgeon\n" ..
	"Sla nooit Robosurgeon op zijn interface.\n" ..
	"DBot's DLibCo neemt geen verantwoordelijkheid voor eventuele schade veroorzaakt door verkeerd gebruik van Robosurgeon.\n" ..
	"De garantie vervalt als de gebruiker sterft.\n" ..
	"Geen terugbetalingen."
gui.ppm2.editor.intro.title = 'Welkom hier, Mens!!'
gui.ppm2.editor.intro.okay = "Ok, ik zal deze licentie toch nooit lezen"

message.ppm2.debug.race_condition = 'Ontvangen NetworkedPonyData voordat de entiteit op de client werd aangemaakt! Wachten.....'

gui.ppm2.spawnmenu.newmodel = 'Spawn nieuw model'
gui.ppm2.spawnmenu.newmodelnj = 'Spawn nieuw nj model'
gui.ppm2.spawnmenu.oldmodel = 'Spawn oud model'
gui.ppm2.spawnmenu.oldmodelnj = 'Spawn oud nj model'
gui.ppm2.spawnmenu.cppmmodel = 'Spawn CPPM model'
gui.ppm2.spawnmenu.cppmmodelnj = 'Spawn CPPM nj model'
gui.ppm2.spawnmenu.cleanup = 'Opruimen ongebruikt models'
gui.ppm2.spawnmenu.reload = 'Herlaad lokale gegevens'
gui.ppm2.spawnmenu.require = 'Gegevens vereisen van de server'
gui.ppm2.spawnmenu.drawhooves = 'Laat hoeven zien als handen'
gui.ppm2.spawnmenu.nohoofsounds = 'Geen hoefgeluiden'
gui.ppm2.spawnmenu.noflexes = 'Schakel flexes uit (emotes)'
gui.ppm2.spawnmenu.advancedmode = 'Activeer de geavanceerde modus voor PPM2 editor'
gui.ppm2.spawnmenu.reflections = 'Activeer reflecties in real-time'
gui.ppm2.spawnmenu.reflections_drawdist = 'Reflecties tekenen afstand'
gui.ppm2.spawnmenu.reflections_renderdist = 'Reflecties laad afstand'
gui.ppm2.spawnmenu.doublejump = 'Dubbel springen activeert vliegen'

tip.ppm2.in_editor = 'In PPM/2 Editor'
tip.ppm2.camera = "%s's PPM/2 Camera"

message.ppm2.queue_notify = '%i texturen staan in de rij om te worden weergegeven'

gui.ppm2.editor.body.bump = 'Bumpmap sterkte'