
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- editor stuffs

gui.ppm2.editor.eyes.separate = 'Getrennte Einstellungen für Augen verwenden'
gui.ppm2.editor.eyes.url = 'Augen URL Textur'
gui.ppm2.editor.eyes.url_desc = 'Bei Verwendung der Augen URL Textur; Die folgenden Optionen haben keine Auswirkung'

gui.ppm2.editor.eyes.lightwarp_desc = 'Lightwarp wirkt nur auf EyeRefract Augen'
gui.ppm2.editor.eyes.lightwarp = "Lightwarp"
gui.ppm2.editor.eyes.desc1 = "Lightwarp textur URL eingabe\nEs muss 256x16 sein!"
gui.ppm2.editor.eyes.desc2 = "Glanzstärke\nDieser Parameter erhöht die Stärke der Echtzeitreflexionen auf das Auge\nUm Änderungen zu sehen, setze ppm2_cl_reflections convar auf 1\nAndere Spieler würden Reflexionen nur sehen, wenn ppm2_cl_reflections auf 1 gesetzt ist\n0 - ist matt; 1 - ist spiegelnd"

for {tprefix, prefix} in *{{'def', ''}, {'left', 'Links '}, {'right', 'Rechts '}}
	gui.ppm2.editor.eyes[tprefix].lightwarp.shader = "#{prefix}EyeRefract Shader verwenden"
	gui.ppm2.editor.eyes[tprefix].lightwarp.cornera = "#{prefix}Eye Cornea diffus verwenden"
	gui.ppm2.editor.eyes[tprefix].lightwarp.glossiness = "#{prefix}Glanz"

	gui.ppm2.editor.eyes[tprefix].type = "#{prefix}Augentyp"
	gui.ppm2.editor.eyes[tprefix].reflection_type = "#{prefix}Augenreflexion typ"
	gui.ppm2.editor.eyes[tprefix].lines = "#{prefix}Augenlinien"
	gui.ppm2.editor.eyes[tprefix].derp = "#{prefix}Derp Augen"
	gui.ppm2.editor.eyes[tprefix].derp_strength = "#{prefix}Derp Augen Stärke"
	gui.ppm2.editor.eyes[tprefix].iris_size = "#{prefix}Augengröße"

	gui.ppm2.editor.eyes[tprefix].points_inside = "#{prefix}Augenlinien innen"
	gui.ppm2.editor.eyes[tprefix].width = "#{prefix}Augenbreite"
	gui.ppm2.editor.eyes[tprefix].height = "#{prefix}Augenhöhe"

	gui.ppm2.editor.eyes[tprefix].pupil.width = "#{prefix}Pupillenbreite"
	gui.ppm2.editor.eyes[tprefix].pupil.height = "#{prefix}Pupillenhöhe"
	gui.ppm2.editor.eyes[tprefix].pupil.size = "#{prefix}Pupillengröße"

	gui.ppm2.editor.eyes[tprefix].pupil.shift_x = "#{prefix}Pupillen Verschiebung X"
	gui.ppm2.editor.eyes[tprefix].pupil.shift_y = "#{prefix}Pupillen Verschiebung Y"
	gui.ppm2.editor.eyes[tprefix].pupil.rotation = "#{prefix}Augenrotation"

	gui.ppm2.editor.eyes[tprefix].background = "#{prefix}Augenhintergrund"
	gui.ppm2.editor.eyes[tprefix].pupil_size = "#{prefix}Pupille"
	gui.ppm2.editor.eyes[tprefix].top_iris = "#{prefix}Obere Augeniris"
	gui.ppm2.editor.eyes[tprefix].bottom_iris = "#{prefix}Untere Augeniris"
	gui.ppm2.editor.eyes[tprefix].line1 = "#{prefix}Augenlinie 1"
	gui.ppm2.editor.eyes[tprefix].line2 = "#{prefix}Augenlinie 2"
	gui.ppm2.editor.eyes[tprefix].reflection = "#{prefix}Augenreflexionseffekt"
	gui.ppm2.editor.eyes[tprefix].effect = "#{prefix}Augeneffekt"

gui.ppm2.editor.generic.title = 'PPM/2 Pony Editor'
gui.ppm2.editor.generic.title_file = '%q - PPM/2 Pony Editor'
gui.ppm2.editor.generic.title_file_unsaved = '%q* - PPM/2 Pony Editor (ungespeicherte Änderungen!)'

gui.ppm2.editor.generic.yes = 'Yas!'
gui.ppm2.editor.generic.no = 'Noh!'
gui.ppm2.editor.generic.ohno = 'Onoh!'
gui.ppm2.editor.generic.okay = 'Okai ;w;'
gui.ppm2.editor.generic.datavalue = '%s\nDatenwert: %q'
gui.ppm2.editor.generic.url = '%s\n\nLink geht zu: %s'
gui.ppm2.editor.generic.url_field = 'URL Feld'
gui.ppm2.editor.generic.spoiler = 'Geheimnisvoller Spoiler'

gui.ppm2.editor.generic.restart.needed = 'Neustart des Editors erforderlich'
gui.ppm2.editor.generic.restart.text = 'Du solltest den Editor neu starten, um die Änderung zu übernehmen.\nJetzt neu starten?\nNicht gespeicherte Daten gehen verloren!'
gui.ppm2.editor.generic.fullbright = 'Volle Helligkeit'
gui.ppm2.editor.generic.wtf = 'Aus irgendeinem Grund hat Dein Player kein NetworkedPonyData. - Nichts zu bearbeiten!\nVersuche ppm2_reload in Deine Konsole einzugeben und versuche es erneut, den Editor zu öffnen.'

gui.ppm2.editor.io.random = 'Randomisieren!'
gui.ppm2.editor.io.newfile.title = 'Neue Datei'
gui.ppm2.editor.io.newfile.confirm = 'Willst Du wirklich eine neue Datei erstellen?'
gui.ppm2.editor.io.newfile.toptext = 'Zurücksetzen'
gui.ppm2.editor.io.delete.confirm = 'Willst Du diese Datei wirklich löschen?\nEs wird für immer weg sein!\n(eine lange Zeit!)'
gui.ppm2.editor.io.delete.title = 'Wirklich löschen?'

gui.ppm2.editor.io.filename = 'Dateiname'
gui.ppm2.editor.io.hint = 'Datei per Doppelklick öffnen'
gui.ppm2.editor.io.reload = 'Dateiliste neu laden'
gui.ppm2.editor.io.failed = 'Import fehlgeschlagen.'

gui.ppm2.editor.io.warn.oldfile = '!!! Es kann funktionieren oder auch nicht. Du wirst zerquetscht werden.'
gui.ppm2.editor.io.warn.text = "Derzeit hast du deine Änderungen nicht angegeben.\nWillst Du wirklich eine andere Datei öffnen?"
gui.ppm2.editor.io.warn.header = 'Nicht gespeicherte Änderungen!'
gui.ppm2.editor.io.save.button = 'Speichern'
gui.ppm2.editor.io.save.text = 'Dateiname ohne ppm2/ und .dat eingeben\nTipp: Um als Autoload zu speichern, schreibe "_current" (ohne ") ein.'
gui.ppm2.editor.io.wear = 'übernehmen (Anziehen)'

gui.ppm2.editor.seq.standing = 'Stehen'
gui.ppm2.editor.seq.move = 'Bewegen'
gui.ppm2.editor.seq.walk = 'Gehen'
gui.ppm2.editor.seq.sit = 'Sitzen'
gui.ppm2.editor.seq.swim = 'Schwimmen'
gui.ppm2.editor.seq.run = 'Laufen'
gui.ppm2.editor.seq.duckwalk = 'Ducken gehen'
gui.ppm2.editor.seq.duck = 'Ducken'
gui.ppm2.editor.seq.jump = 'Springen'

gui.ppm2.editor.misc.race = 'Rasse'
gui.ppm2.editor.misc.weight = 'Gewicht'
gui.ppm2.editor.misc.size = 'Pony Größe'
gui.ppm2.editor.misc.hide_weapons = 'Waffen verstecken'
gui.ppm2.editor.misc.chest = 'Männliche Brust'
gui.ppm2.editor.misc.gender = 'Geschlecht'
gui.ppm2.editor.misc.wings = 'Flügel Typ'
gui.ppm2.editor.misc.flexes = 'Flex steuerung'
gui.ppm2.editor.misc.no_flexes2 = 'Kein Flex beim neuen Modell'
gui.ppm2.editor.misc.no_flexes_desc = 'Du kannst jeden Flex Zustandsregler separat deaktivieren.\nSo können diese Flexe mit Addons von Drittanbietern (wie PAC3) modifiziert werden.'

gui.ppm2.editor.misc.hide_pac3 = 'Entitys ausblenden wenn PAC3 Entity verwendet wird'
gui.ppm2.editor.misc.hide_mane = 'Mähne ausblenden wenn PAC3 Entity verwendet wird'
gui.ppm2.editor.misc.hide_tail = 'Schweif ausblenden wenn PAC3 Entity verwendet wird'
gui.ppm2.editor.misc.hide_socks = 'Socken ausblenden wenn PAC3 Entity verwendet wird'

gui.ppm2.editor.tabs.main = 'Allgemeines'
gui.ppm2.editor.tabs.files = 'Dateien'
gui.ppm2.editor.tabs.old_files = 'Alte Dateien'
gui.ppm2.editor.tabs.cutiemark = 'Schönheitsfleck'
gui.ppm2.editor.tabs.head = 'Kopfanatomie'
gui.ppm2.editor.tabs.eyes = 'Augen'
gui.ppm2.editor.tabs.face = 'Gesicht'
gui.ppm2.editor.tabs.mouth = 'Mund'
gui.ppm2.editor.tabs.left_eye = 'Linkes Auge'
gui.ppm2.editor.tabs.right_eye = 'Rechtes Auge'
gui.ppm2.editor.tabs.mane_horn = 'Mähne und Horn'
gui.ppm2.editor.tabs.mane = 'Mähne'
gui.ppm2.editor.tabs.details = 'Details'
gui.ppm2.editor.tabs.url_details = 'URL Details'
gui.ppm2.editor.tabs.url_separated_details = 'URL Getrennte Details'
gui.ppm2.editor.tabs.ears = 'Ohren'
gui.ppm2.editor.tabs.horn = 'Horn'
gui.ppm2.editor.tabs.back = 'Rücken'
gui.ppm2.editor.tabs.wings = 'Flügel'
gui.ppm2.editor.tabs.left = 'Links'
gui.ppm2.editor.tabs.right = 'Rechts'
gui.ppm2.editor.tabs.neck = 'Hals'
gui.ppm2.editor.tabs.body = 'Pony Körper'
gui.ppm2.editor.tabs.tattoos = 'Tätowierungen'
gui.ppm2.editor.tabs.tail = 'Schweif'
gui.ppm2.editor.tabs.hooves = 'Huf Anatomie'
gui.ppm2.editor.tabs.bottom_hoof = 'Huf unten'
gui.ppm2.editor.tabs.legs = 'Beine'
gui.ppm2.editor.tabs.socks = 'Socken'
gui.ppm2.editor.tabs.newsocks = 'Neue Socken'
gui.ppm2.editor.tabs.about = 'Über'

gui.ppm2.editor.old_tabs.mane_tail = 'Mähne und Schweif'
gui.ppm2.editor.old_tabs.wings_and_horn_details = 'Flügel und Horn Details'
gui.ppm2.editor.old_tabs.wings_and_horn = 'Flügel und Horn'
gui.ppm2.editor.old_tabs.body_details = 'Körper Details'
gui.ppm2.editor.old_tabs.mane_tail_detals = 'Mähne und Schweif URL Details'

gui.ppm2.editor.cutiemark.display = 'Schönheitsfleck anzeigen'
gui.ppm2.editor.cutiemark.type = 'Schönheitsfleck typ'
gui.ppm2.editor.cutiemark.size = 'Schönheitsfleck größe'
gui.ppm2.editor.cutiemark.color = 'Schönheitsfleck Farbe'
gui.ppm2.editor.cutiemark.input = 'Schönheitsfleck URL bild Eingabefeld\nSollte PNG oder JPEG sein (funktioniert wie bei\nPAC3 URL texture)'

gui.ppm2.editor.face.eyelashes = 'Wimpern'
gui.ppm2.editor.face.eyelashes_color = 'Wimpern Farbe'
gui.ppm2.editor.face.eyelashes_phong = 'Wimpern Phong Parameter'
gui.ppm2.editor.face.eyebrows_color = 'Augenbrauen Farbe'
gui.ppm2.editor.face.new_muzzle = 'Neue Schnauze für das männliche Modell nutzen'

gui.ppm2.editor.face.nose = 'Nasenfarbe'
gui.ppm2.editor.face.lips = 'Lippenfarbe'
gui.ppm2.editor.face.eyelashes_separate_phong = 'Separate Wimpern Phong'
gui.ppm2.editor.face.eyebrows_glow = 'leuchtende Augenbrauen'
gui.ppm2.editor.face.eyebrows_glow_strength = 'Augenbrauen Leuchtstärke'
gui.ppm2.editor.face.inherit.lips = 'Erbe Lippen Farbe vom Körper'
gui.ppm2.editor.face.inherit.nose = 'Erbe Nasen Farbe vom Körper'

gui.ppm2.editor.mouth.fangs = 'Fangzähne'
gui.ppm2.editor.mouth.alt_fangs = 'Alternative Fangzähne'
gui.ppm2.editor.mouth.claw = 'Klauenzähne'

gui.ppm2.editor.mouth.teeth = 'Zahnfarbe'
gui.ppm2.editor.mouth.teeth_phong = 'Zahn Phong Parameter'
gui.ppm2.editor.mouth.mouth = 'Mundfarbe'
gui.ppm2.editor.mouth.mouth_phong = 'Mund Phong Parameter'
gui.ppm2.editor.mouth.tongue = 'Zungenfarbe'
gui.ppm2.editor.mouth.tongue_phong = 'Zunge Phong Parameter'

gui.ppm2.editor.mane.type = 'Mähne Typ'
gui.ppm2.editor.mane.phong = 'Trenne Mähne phong Einstellungen vom Körper'
gui.ppm2.editor.mane.mane_phong = 'Mähne Phong Parameter'
gui.ppm2.editor.mane.phong_sep = 'Trenne obere und untere Mähnenfarbe'
gui.ppm2.editor.mane.up.phong = 'Obere Mähne Phong Einstellungen'
gui.ppm2.editor.mane.down.type = 'Untere Mähne Typ'
gui.ppm2.editor.mane.down.phong = 'Untere Mähne Phong Einstellungen'
gui.ppm2.editor.mane.newnotice = 'Die nächsten Optionen wirken sich nur auf das neue Modell aus'

for i = 1, 2
	gui.ppm2.editor.mane['color' .. i] = "Mähnefarbe #{i}"
	gui.ppm2.editor.mane.up['color' .. i] = "Obere Mähnefarbe #{i}"
	gui.ppm2.editor.mane.down['color' .. i] = "Untere Mähnefarbe #{i}"

for i = 1, 6
	gui.ppm2.editor.mane['detail_color' .. i] = "Mähne Detail Farbe #{i}"
	gui.ppm2.editor.mane.up['detail_color' .. i] = "Obere Mähnefarbe #{i}"
	gui.ppm2.editor.mane.down['detail_color' .. i] = "Untere Mähnefarbe #{i}"

	gui.ppm2.editor.url_mane['desc' .. i] = "Mähne URL Detail #{i} Eingabefeld"
	gui.ppm2.editor.url_mane['color' .. i] = "Mähne URL Detail Farbe #{i}"

	gui.ppm2.editor.url_mane.sep.up['desc' .. i] = "Obere Mähne URL Detail #{i} Eingabefeld"
	gui.ppm2.editor.url_mane.sep.up['color' .. i] = "Obere Mähne URL Detail Farbe #{i}"

	gui.ppm2.editor.url_mane.sep.down['desc' .. i] = "Untere Mähne URL Detail #{i} Eingabefeld"
	gui.ppm2.editor.url_mane.sep.down['color' .. i] = "Untere Mähne URL Detail Farbe #{i}"

gui.ppm2.editor.ears.bat = 'Bat pony Ohren'
gui.ppm2.editor.ears.size = 'Ohrengröße'

gui.ppm2.editor.horn.detail_color = 'Horn Detailfarbe'
gui.ppm2.editor.horn.glowing_detail = 'Horn leuchten Detail'
gui.ppm2.editor.horn.glow_strength = 'Horn leuchten Stärke'
gui.ppm2.editor.horn.separate_color = 'Trenne Horn Farbe vom Körper'
gui.ppm2.editor.horn.color = 'Horn Farbe'
gui.ppm2.editor.horn.horn_phong = 'Horn Phong Parameter'
gui.ppm2.editor.horn.magic = 'Horn magie Farbe'
gui.ppm2.editor.horn.separate_magic_color = 'Trenne magie Farbe vom Augen Farbe'
gui.ppm2.editor.horn.separate = 'Trenne Horn Farbe vom Körper'
gui.ppm2.editor.horn.separate_phong = 'Trenne Horn phong Einstellungen vom Körper'

for i = 1, 3
	gui.ppm2.editor.horn.detail['desc' .. i] = "Horn URL Detail #{i}"
	gui.ppm2.editor.horn.detail['color' .. i] = "URL Detail Farbe #{i}"

gui.ppm2.editor.wings.separate_color = 'Trenne Flügel Farbe vom Körper'
gui.ppm2.editor.wings.color = 'Flügelfarbe'
gui.ppm2.editor.wings.wings_phong = 'Flügel Phong Parameter'
gui.ppm2.editor.wings.separate = 'Trenne Flügelfarbe vom Körper'
gui.ppm2.editor.wings.separate_phong = 'Trenne Flügel phong Einstellungen vom Körper'
gui.ppm2.editor.wings.bat_color = 'Bat Flügelfarbe'
gui.ppm2.editor.wings.bat_skin_color = 'Bat Flügel Hautfarbe'
gui.ppm2.editor.wings.bat_skin_phong = 'Bat Flügel Haut Phong Parameter'

gui.ppm2.editor.wings.normal = 'Normale Flügel'
gui.ppm2.editor.wings.bat = 'Bat Flügel'
gui.ppm2.editor.wings.bat_skin = 'Bat Flügel Haut'

gui.ppm2.editor.wings.left.size = 'Linker Flügel Größe'
gui.ppm2.editor.wings.left.fwd = 'Linker Flügel Vorwärts'
gui.ppm2.editor.wings.left.up = 'Linker Flügel Hoch'
gui.ppm2.editor.wings.left.inside = 'Linker Flügel Innen'

gui.ppm2.editor.wings.right.size = 'Rechter Flügel Größe'
gui.ppm2.editor.wings.right.fwd = 'Rechter Flügel Vorwärts'
gui.ppm2.editor.wings.right.up = 'Rechter Flügel Hoch'
gui.ppm2.editor.wings.right.inside = 'Rechter Flügel Innen'

for i = 1, 3
	gui.ppm2.editor.wings.details.def['detail' .. i] = "Flügel URL Detail #{i}"
	gui.ppm2.editor.wings.details.def['color' .. i] = "URL Detail Farbe #{i}"
	gui.ppm2.editor.wings.details.bat['detail' .. i] = "Bat Flügel URL Detail #{i}"
	gui.ppm2.editor.wings.details.bat['color' .. i] = "Bat Flügel URL Detail Farbe #{i}"
	gui.ppm2.editor.wings.details.batskin['detail' .. i] = "Bat Flügel Haut URL Detail #{i}"
	gui.ppm2.editor.wings.details.batskin['color' .. i] = "Bat Flügel Haut URL Detail Farbe #{i}"

gui.ppm2.editor.neck.height = 'Halshöhe'

gui.ppm2.editor.body.suit = 'Körperanzug'
gui.ppm2.editor.body.color = 'Körperfarbe'
gui.ppm2.editor.body.body_phong = 'Körper Phong Parameter'
gui.ppm2.editor.body.spine_length = 'Rückenlänge'
gui.ppm2.editor.body.url_desc = 'Körper Detail URL Bild Eingabefeld\nSollte PNG oder JPEG sein (funktioniert wie bei\nPAC3 URL textur)'

for i = 1, PPM2.MAX_BODY_DETAILS
	gui.ppm2.editor.body.detail['desc' .. i] = "Detail #{i}"
	gui.ppm2.editor.body.detail['color' .. i] = "Detail Farbe #{i}"
	gui.ppm2.editor.body.detail['glow' .. i] = "Detail #{i} leuchtet"
	gui.ppm2.editor.body.detail['glow_strength' .. i] = "Detail #{i} leuchtkraft"

	gui.ppm2.editor.body.detail.url['desc' .. i] = "Detail #{i}"
	gui.ppm2.editor.body.detail.url['color' .. i] = "Detail Farbe #{i}"

gui.ppm2.editor.tattoo.edit_keyboard = 'Bearbeiten mit der Tastatur'
gui.ppm2.editor.tattoo.type = 'Typ'
gui.ppm2.editor.tattoo.over = 'Tattoo über Körperdetails'
gui.ppm2.editor.tattoo.glow = 'Tattoo leuchtet'
gui.ppm2.editor.tattoo.glow_strength = 'Tattoo leuchtkraft'
gui.ppm2.editor.tattoo.color = 'Farbe der Tätowierung'

gui.ppm2.editor.tattoo.tweak.rotate = 'Rotation'
gui.ppm2.editor.tattoo.tweak.x = 'X Position'
gui.ppm2.editor.tattoo.tweak.y = 'Y Position'
gui.ppm2.editor.tattoo.tweak.width = 'Breite Skalierung'
gui.ppm2.editor.tattoo.tweak.height = 'Länge Skalierung'

for i = 1, PPM2.MAX_TATTOOS
	gui.ppm2.editor.tattoo['layer' .. i] = "Tattooschicht #{i}"

gui.ppm2.editor.tail.type = 'Schweif typ'
gui.ppm2.editor.tail.size = 'Schweif größe'
gui.ppm2.editor.tail.tail_phong = 'Schweif Phong Parameter'
gui.ppm2.editor.tail.separate = 'Trenne Schweif phong Einstellungen vom Körper'

for i = 1, 2
	gui.ppm2.editor.tail['color' .. i] = 'Schweiffarbe ' .. i

for i = 1, 6
	gui.ppm2.editor.tail['detail' .. i] = "Schweif Detail Farbe #{i}"
	gui.ppm2.editor.tail.url['detail' .. i] = "Schweif URL Detail #{i}"
	gui.ppm2.editor.tail.url['color' .. i] = "Schweif URL Detail #{i}"

gui.ppm2.editor.hoof.fluffers = 'Huf flausch'

gui.ppm2.editor.legs.height = 'Bein höhe'
gui.ppm2.editor.legs.socks.simple = 'Socken (einfache Textur)'
gui.ppm2.editor.legs.socks.model = 'Socken (als Modell)'
gui.ppm2.editor.legs.socks.color = 'Socken Modell Farbe'
gui.ppm2.editor.legs.socks.socks_phong = 'Socken Phong Parameter'
gui.ppm2.editor.legs.socks.texture = 'Socken Textur'
gui.ppm2.editor.legs.socks.url_texture = 'Socken URL textur'

for i = 1, 6
	gui.ppm2.editor.legs.socks['color' .. i] = 'Socken Detail Farbe ' .. i

gui.ppm2.editor.legs.newsocks.model = 'Socken (als neues Modell)'

for i = 1, 3
	gui.ppm2.editor.legs.newsocks['color' .. i] = 'Neue Sockenfarbe ' .. i

gui.ppm2.editor.legs.newsocks.url = 'Neue Socken URL textur'

-- shared editor stuffs

gui.ppm2.editor.tattoo.help = "Um den Bearbeitungsmodus zu verlassen, drücke Escape oder klicke irgendwo mit der Maus
Um das Tattoo zu bewegen, verwende WASD
Um höher/niedriger zu skalieren, verwende die Hoch/Runter Pfeiltasten
Um breiter/kleiner zu skalieren, verwende die Rechts/Links Pfeiltasten
Um links/rechts zu Drehen, verwende die Q/E Tasten"

for name, data in pairs PPM2.PonyDataRegistry
	gui.ppm2.editor.reset[data.getFunc\lower()] = 'Zurücksetzen ' .. data.getFunc

gui.ppm2.editor.phong.info = 'Mehr Infos über Phong im Wiki'
gui.ppm2.editor.phong.exponent = 'Phong Exponent - wie stark die reflektierende Eigenschaft\nvon der Ponyhaut ist\nSetze den Wert nahe Null, um dem Roboterlook zu bekommen\nPonyhaut'
gui.ppm2.editor.phong.exponent_text = 'Phong Exponent'
gui.ppm2.editor.phong.boost.title = 'Phong Verstärkung - multipliziert spiegelnde Kartenreflexionen'
gui.ppm2.editor.phong.boost.boost = 'Phong Verstärkung'
gui.ppm2.editor.phong.tint.title = 'Tönung Farbe - welche Farben reflektieren Spiegelkarte\nWeiß - Reflektiert alle Farben\n(Im weißen Raum - weiße Spiegelkarte)'
gui.ppm2.editor.phong.tint.tint = 'Tönung Farbe - welche Farben reflektieren Spiegelkarte\nWeiß - Reflektiert alle Farben\n(Im weißen Raum - weiße Spiegelkarte)'
gui.ppm2.editor.phong.frensel.front.title = 'Phong Front - Fresnel 0 Grad Reflexionswinkel Multiplikator'
gui.ppm2.editor.phong.frensel.front.front = 'Phong Front'
gui.ppm2.editor.phong.frensel.middle.title = 'Phong Mitte - Fresnel 45 Grad Reflexionswinkel Multiplikator'
gui.ppm2.editor.phong.frensel.middle.front = 'Phong Mitte'
gui.ppm2.editor.phong.frensel.sliding.title = 'Phong Gleitend - Fresnel 45 Grad Reflexionswinkel Multiplikator'
gui.ppm2.editor.phong.frensel.sliding.front = 'Phong Gleitend'
gui.ppm2.editor.phong.lightwarp = 'Lightwarp'
gui.ppm2.editor.phong.url_lightwarp = 'Lightwarp textur URL eingabe\nEs muss 256x16 sein!'
gui.ppm2.editor.phong.bumpmap = 'Bumpmap URL eingabe'

gui.ppm2.editor.info.discord = "Trete DBot's Discord bei!"
gui.ppm2.editor.info.ponyscape = "PPM/2 ist ein Ponyscape projekt"
gui.ppm2.editor.info.creator = "PPM/2 wurde von DBot erstellt und entwickelt"
gui.ppm2.editor.info.newmodels = "Neue Modelle wurden von Durpy erstellt"
gui.ppm2.editor.info.cppmmodels = "CPPM Modelle (einschließlich Ponyhände) gehören zu UnkN', 'http://steamcommunity.com/profiles/76561198084938735"
gui.ppm2.editor.info.oldmodels = "Alte Modelle gehören zu Scentus und den anderen."
gui.ppm2.editor.info.bugs = "Einen Fehler gefunden? Melde es hier!"
gui.ppm2.editor.info.sources = "Quellen findest du hier"
gui.ppm2.editor.info.githubsources = "Oder im GitHub mirror"
gui.ppm2.editor.info.thanks = "Besonderer Dank geht an alle, die kritisiert,\ngeholfen und PPM/2 getestet haben!"

-- other stuff

info.ppm2.fly.pegasus = 'Du musst eine Pegasus oder ein Alicorn sein, um zu fliegen!'
info.ppm2.fly.cannot = 'Du kannst nicht %s im Augenblick.'

gui.ppm2.emotes.sad = 'Traurig'
gui.ppm2.emotes.wild = 'Wild'
gui.ppm2.emotes.grin = 'Grinsen'
gui.ppm2.emotes.angry = 'Wütend'
gui.ppm2.emotes.tongue = ':P'
gui.ppm2.emotes.angrytongue = '>:P'
gui.ppm2.emotes.pff = 'Pffff!'
gui.ppm2.emotes.kitty = ':3'
gui.ppm2.emotes.owo = 'oWo'
gui.ppm2.emotes.ugh = 'Uuugh'
gui.ppm2.emotes.lips = 'Lippen lecken'
gui.ppm2.emotes.scrunch = 'Scrunch'
gui.ppm2.emotes.sorry = 'Entschuldigend'
gui.ppm2.emotes.wink = 'Zwinkern'
gui.ppm2.emotes.right_wink = 'Rechts Zwinkern'
gui.ppm2.emotes.licking = 'Lecken'
gui.ppm2.emotes.suggestive_lips = 'Anzüglich Lippen Lecken'
gui.ppm2.emotes.suggestive_no_tongue = 'Anzüglich ohne Zunge'
gui.ppm2.emotes.gulp = 'Schlucken'
gui.ppm2.emotes.blah = 'Blah blah blah'
gui.ppm2.emotes.happi = 'Glücklich'
gui.ppm2.emotes.happi_grin = 'Glückliches Grinsen'
gui.ppm2.emotes.duck = 'ENTE'
gui.ppm2.emotes.ducks = 'ENTEN WAHNSINN'
gui.ppm2.emotes.quack = 'QUACK'
gui.ppm2.emotes.suggestive = 'Anzüglich mit Zunge'

message.ppm2.emotes.invalid = 'Keine Emotion mit ID: %s'

gui.ppm2.editor.intro.text = "Grüße meinen neuen.... Robochirurgen für Ponys! Es erlaubt Dir....\n" ..
	"hmmm... ein Pony zu werden, und ja, dieser Prozess ist UNUMKEHRBAR! Aber mach dir keine Sorgen,\n" ..
	"Du verlierst keine deiner Gehirnzellen, in und nach der Operation, weil wir die Operation sehr schonend durchführen...\n\n" ..
	"Eigentlich habe ich keine Ahnung, du biologisches Wesen! Seine mechanischen Hände werden dich in die engsten Umarmungen hüllen, die du je bekommen hast!\n" ..
	"Und, bitte, sterbe nicht in diesen Prozess, denn dies würde dazu führen DAS ERLÖSCHEN DEINER LEBENSLANGEN GARANTIE... und Du wirst kein Pony sein!\n" ..
	"----\n\n\n" ..
	"Vorsicht: Nehme den Robochirurgen nicht auseinander.\nLege deine Hände/Hufe nicht in bewegliche Teile des Robochirurgen.\n" ..
	"Schalte es während des Betriebs nicht aus..\nVersuche nicht sich seinen Taten zu widersetzen.\n" ..
	"Sei immer sanft mit den Robochirurgen.\n" ..
	"Schlage den Robochirurgen nie auf sein Interface.\n" ..
	"DBot's DLibCo übernimmt keine Verantwortung für Schäden, die durch falsche Verwendung von Robochirurgen entstehen.\n" ..
	"Die Garantie erlischt, wenn der Benutzer stirbt.\n" ..
	"Keine Rückerstattung."
gui.ppm2.editor.intro.title = 'Willkommen hier, Mensch!'
gui.ppm2.editor.intro.okay = "Ok, ich werde diese Lizenz sowieso nie lesen."
