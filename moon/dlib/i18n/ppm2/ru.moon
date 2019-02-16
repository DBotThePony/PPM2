
-- Copyright (C) 2017-2019 DBot

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

gui.ppm2.dxlevel.not_supported = 'Выставленный уровень DirectX™ слишком низок для работы PPM/2. Необходимый минимум - 9.0.\nДолжно быть, вы используете DirectX™ ниже 9.0 по причине видеокарты 2004 года или плохих драйверов.\nНо если вы используете DirectX™ ниже 9.0 ради FPS - то это тупо ещё большая нагрузка на видеокарту, так как\nв gmod FPS зависит прямо от нагрузки ЦП другими аддонами от Васи228, которые, кстати, с этим очень хорошо справляются.'
gui.ppm2.dxlevel.toolow = 'Уровень технологии DirectX™ слишком низок для работы PPM/2'

gui.ppm2.editor.eyes.separate = 'Использовать разные настройки для глаз'
gui.ppm2.editor.eyes.url = 'URL текстура глаза'
gui.ppm2.editor.eyes.url_desc = 'Когда используется URL текстура; настройки снизу не имеют силы'

gui.ppm2.editor.eyes.lightwarp_desc = 'Lightwarp имеет эффект только на EyeRefract глазаз'
gui.ppm2.editor.eyes.lightwarp = "Lightwarp"
gui.ppm2.editor.eyes.desc1 = "Lightwarp URL текстура\nОБЯЗАНА БЫТЬ 256x16!"
gui.ppm2.editor.eyes.desc2 = "Сила 'Зеркалья' у глаз\nЭтот параметр влияет на отражения в режиме Отражений в реальном времени\nЗа это отвечает переменная клиента ppm2_cl_reflections\nОстальные игроки увидят отражения только с ppm2_cl_reflections 1\n0 - матовая поверхность; 1 - зеркальная"

for _, {tprefix, prefix} in ipairs {{'def', ''}, {'left', 'Left '}, {'right', 'Right '}}
	gui.ppm2.editor.eyes[tprefix].lightwarp.shader = "#{prefix}Использовать шейдер EyeRefract"
	gui.ppm2.editor.eyes[tprefix].lightwarp.cornera = "#{prefix}Испольщовать Cornera диффуз текстуру"
	gui.ppm2.editor.eyes[tprefix].lightwarp.glossiness = "#{prefix}Стеклянность (?)"

	gui.ppm2.editor.eyes[tprefix].type = "#{prefix}Тип глаза"
	gui.ppm2.editor.eyes[tprefix].reflection_type = "#{prefix}Тип отражений глаза"
	gui.ppm2.editor.eyes[tprefix].lines = "#{prefix}Линии радужной оболочки"
	gui.ppm2.editor.eyes[tprefix].derp = "#{prefix}Derp глаз"
	gui.ppm2.editor.eyes[tprefix].derp_strength = "#{prefix}Сила Derp глаза"
	gui.ppm2.editor.eyes[tprefix].iris_size = "#{prefix}Размер глаза"

	gui.ppm2.editor.eyes[tprefix].points_inside = "#{prefix}Линии радужной оболочки смотрят внутрь"
	gui.ppm2.editor.eyes[tprefix].width = "#{prefix}Ширина глаза"
	gui.ppm2.editor.eyes[tprefix].height = "#{prefix}Высота глаза"

	gui.ppm2.editor.eyes[tprefix].pupil.width = "#{prefix}Ширина зрачка"
	gui.ppm2.editor.eyes[tprefix].pupil.height = "#{prefix}Высота зрачка"
	gui.ppm2.editor.eyes[tprefix].pupil.size = "#{prefix}Размер зрачка"

	gui.ppm2.editor.eyes[tprefix].pupil.shift_x = "#{prefix}Сдвиг зрачка по X"
	gui.ppm2.editor.eyes[tprefix].pupil.shift_y = "#{prefix}Сдвиг зрачка по Y"
	gui.ppm2.editor.eyes[tprefix].pupil.rotation = "#{prefix}Поворот глаза"

	gui.ppm2.editor.eyes[tprefix].background = "#{prefix}Фон глаза"
	gui.ppm2.editor.eyes[tprefix].pupil_size = "#{prefix}Зрачок"
	gui.ppm2.editor.eyes[tprefix].top_iris = "#{prefix}Верхняя радужная оболочка"
	gui.ppm2.editor.eyes[tprefix].bottom_iris = "#{prefix}Нижняя радужная оболочка"
	gui.ppm2.editor.eyes[tprefix].line1 = "#{prefix}Радужная линия 1"
	gui.ppm2.editor.eyes[tprefix].line2 = "#{prefix}Радужная линия 2"
	gui.ppm2.editor.eyes[tprefix].reflection = "#{prefix}Эффект отражения"
	gui.ppm2.editor.eyes[tprefix].effect = "#{prefix}Эффект мультяшного глаза"

gui.ppm2.editor.generic.title = 'PPM/2 Пони редактор'
gui.ppm2.editor.generic.title_file = '%q - PPM/2 Пони редактор'
gui.ppm2.editor.generic.title_file_unsaved = '%q* - PPM/2 Пони редактор (несохраненные изменения!)'

gui.ppm2.editor.generic.yes = 'Даа!'
gui.ppm2.editor.generic.no = 'Ниань!'
gui.ppm2.editor.generic.ohno = 'Ойнет!'
gui.ppm2.editor.generic.okay = 'Окай ;w;'
gui.ppm2.editor.generic.datavalue = '%s\nID в коде: %q'
gui.ppm2.editor.generic.url = '%s\n\nСсылка ведёт на: %s'
gui.ppm2.editor.generic.url_field = 'URL поле'
gui.ppm2.editor.generic.spoiler = 'Таинственный спойлер'

gui.ppm2.editor.generic.restart.needed = 'Необходим перезапуск редактора'
gui.ppm2.editor.generic.restart.text = 'Вы должны перезапустить редактор для изменений.\nПерезапустить сейчас?\nНесохраненные изменения будут утрачены!'
gui.ppm2.editor.generic.fullbright = 'Без затенения'
gui.ppm2.editor.generic.wtf = 'Волею хаоса у вас отсутствует NetworkedPonyData который необходимо изменять.\nПопробуйте выполнить ppm2_reload в консоли и открыть редактор снова.'

gui.ppm2.editor.io.random = 'Рандомизировать!'
gui.ppm2.editor.io.newfile.title = 'Новый файл'
gui.ppm2.editor.io.newfile.confirm = 'Вы действительно хотите создать новый файл?'
gui.ppm2.editor.io.newfile.toptext = 'Сбросить'
gui.ppm2.editor.io.delete.confirm = 'Вы действительно хотите удалить данный файл?\nОн пропадет навсегда!\n(очень долгое время!)'
gui.ppm2.editor.io.delete.title = 'Действительно удалить?'

gui.ppm2.editor.io.filename = 'Имя файла'
gui.ppm2.editor.io.hint = 'Можно открыть двойным нажатием'
gui.ppm2.editor.io.reload = 'Перезагрузить список файлов'
gui.ppm2.editor.io.failed = 'Ошибка импорта.'

gui.ppm2.editor.io.warn.oldfile = '!!! Это может или сработать или нет. Вы будете аннигилированы.'
gui.ppm2.editor.io.warn.text = "В данный момент вы не сохранили свои изменения.\nВы действительно хотите открыть другой файл?"
gui.ppm2.editor.io.warn.header = 'Несохраненные изменения!'
gui.ppm2.editor.io.save.button = 'Сохранить'
gui.ppm2.editor.io.save.text = 'Введите имя файла без ppm2/ и .dat\nПодсказка: что бы сохранить файл как авто-загружаемый, введите "_current" (без кавычек)'
gui.ppm2.editor.io.wear = 'Применить изменения'

gui.ppm2.editor.seq.standing = 'Стоит'
gui.ppm2.editor.seq.move = 'Двигается'
gui.ppm2.editor.seq.walk = 'Беспечно идет'
gui.ppm2.editor.seq.sit = 'Сидит'
gui.ppm2.editor.seq.swim = 'Плавает'
gui.ppm2.editor.seq.run = 'Бежит'
gui.ppm2.editor.seq.duckwalk = 'Идет вприсядку'
gui.ppm2.editor.seq.duck = 'Присел'
gui.ppm2.editor.seq.jump = 'Прыжок'

gui.ppm2.editor.misc.race = 'Раса'
gui.ppm2.editor.misc.weight = 'Вес'
gui.ppm2.editor.misc.size = 'Размер пони'
gui.ppm2.editor.misc.hide_weapons = 'Скрывать ли оружия'
gui.ppm2.editor.misc.chest = 'Бафф груди'
gui.ppm2.editor.misc.gender = 'Пол'
gui.ppm2.editor.misc.wings = 'Тип крыльев'
gui.ppm2.editor.misc.flexes = 'Управление flexами'
gui.ppm2.editor.misc.no_flexes2 = 'Отключить flex на новых моделях'
gui.ppm2.editor.misc.no_flexes_desc = 'Вы можете отдельно отключить любой flex\nПоэтому они могут быть изменены третьим кодом (таким как PAC3)'

gui.ppm2.editor.misc.hide_pac3 = 'Скрывать ентити когда используется PAC3 entity'
gui.ppm2.editor.misc.hide_mane = 'Скрывать гриву когда используется PAC3 entity'
gui.ppm2.editor.misc.hide_tail = 'Скрывать хвост когда используется PAC3 entity'
gui.ppm2.editor.misc.hide_socks = 'Скрывать носки когда используется PAC3 entity'

gui.ppm2.editor.tabs.main = 'Общее'
gui.ppm2.editor.tabs.files = 'Файлы'
gui.ppm2.editor.tabs.old_files = 'Старые файлы'
gui.ppm2.editor.tabs.cutiemark = 'Кьютимарка'
gui.ppm2.editor.tabs.head = 'Анатомия головы'
gui.ppm2.editor.tabs.eyes = 'Глаза'
gui.ppm2.editor.tabs.face = 'Лицо'
gui.ppm2.editor.tabs.mouth = 'Рот'
gui.ppm2.editor.tabs.left_eye = 'Левый глаз'
gui.ppm2.editor.tabs.right_eye = 'Правый глаз'
gui.ppm2.editor.tabs.mane_horn = 'Грива и рог'
gui.ppm2.editor.tabs.mane = 'Грива'
gui.ppm2.editor.tabs.details = 'Детали'
gui.ppm2.editor.tabs.url_details = 'URL Детали'
gui.ppm2.editor.tabs.url_separated_details = 'Отдельные URL Детали'
gui.ppm2.editor.tabs.ears = 'Уши'
gui.ppm2.editor.tabs.horn = 'Рог'
gui.ppm2.editor.tabs.back = 'Спина'
gui.ppm2.editor.tabs.wings = 'Крылья'
gui.ppm2.editor.tabs.left = 'Правое'
gui.ppm2.editor.tabs.right = 'Левое'
gui.ppm2.editor.tabs.neck = 'Шея'
gui.ppm2.editor.tabs.body = 'Тело пони'
gui.ppm2.editor.tabs.tattoos = 'Тату'
gui.ppm2.editor.tabs.tail = 'Хвост'
gui.ppm2.editor.tabs.hooves = 'Анатомия копыт'
gui.ppm2.editor.tabs.bottom_hoof = 'Нижняя часть'
gui.ppm2.editor.tabs.legs = 'Ноги'
gui.ppm2.editor.tabs.socks = 'Носки'
gui.ppm2.editor.tabs.newsocks = 'Новые носки'
gui.ppm2.editor.tabs.about = 'О PPM/2'

gui.ppm2.editor.old_tabs.mane_tail = 'Грива и хвост'
gui.ppm2.editor.old_tabs.wings_and_horn_details = 'Детали крыльев и рога'
gui.ppm2.editor.old_tabs.wings_and_horn = 'Крылья и рог'
gui.ppm2.editor.old_tabs.body_details = 'Детали тела'
gui.ppm2.editor.old_tabs.mane_tail_detals = 'URL детали хвоста и гривы'

gui.ppm2.editor.cutiemark.display = 'Отображать кьютимарку'
gui.ppm2.editor.cutiemark.type = 'Тип кьютимарки'
gui.ppm2.editor.cutiemark.size = 'Размер кьютимарки'
gui.ppm2.editor.cutiemark.color = 'Цвет кьютимарки'
gui.ppm2.editor.cutiemark.input = 'URL кьютимарка\nДолжна быть в формате PNG или JPEG (СЖИМАЕШЬ, НЕБОСЬ?) (работает так же\nкак PAC3 URL текстура)'

gui.ppm2.editor.face.eyelashes = 'Ресницы'
gui.ppm2.editor.face.eyelashes_color = 'Цвет ресниц'
gui.ppm2.editor.face.eyelashes_phong = 'Фонг параметры ресниц'
gui.ppm2.editor.face.eyebrows_color = 'Цвет бровей'
gui.ppm2.editor.face.new_muzzle = 'Использовать новую мордочку'

gui.ppm2.editor.face.nose = 'Цвет ноздрей'
gui.ppm2.editor.face.lips = 'Цвет губ'
gui.ppm2.editor.face.eyelashes_separate_phong = 'Отделить фонг настройки ресниц от тела'
gui.ppm2.editor.face.eyebrows_glow = 'Светящиеся ресницы'
gui.ppm2.editor.face.eyebrows_glow_strength = 'Сила свечения'
gui.ppm2.editor.face.inherit.lips = 'Наследовать цвет губ от тела'
gui.ppm2.editor.face.inherit.nose = 'Наследовать цвет ноздрей от тела'

gui.ppm2.editor.mouth.fangs = 'Клыки'
gui.ppm2.editor.mouth.alt_fangs = 'Альтернативные клыки'
gui.ppm2.editor.mouth.claw = 'Акульи зубы'

gui.ppm2.editor.mouth.teeth = 'Цвет зубов'
gui.ppm2.editor.mouth.teeth_phong = 'Фонг параметры зубов'
gui.ppm2.editor.mouth.mouth = 'Цвет полости рта'
gui.ppm2.editor.mouth.mouth_phong = 'Фонг параметры рта'
gui.ppm2.editor.mouth.tongue = 'Цвет языка'
gui.ppm2.editor.mouth.tongue_phong = 'Фонг параметры языка'

gui.ppm2.editor.mane.type = 'Тип гривы'
gui.ppm2.editor.mane.phong = 'Отделить фонг настройки гривы от тела'
gui.ppm2.editor.mane.mane_phong = 'Фонг параметры гривы'
gui.ppm2.editor.mane.phong_sep = 'Отделить нижний и верхний цвета гривы'
gui.ppm2.editor.mane.up.phong = 'Фонг настройки верхней гривы'
gui.ppm2.editor.mane.down.type = 'Lower Mane Type'
gui.ppm2.editor.mane.down.phong = 'Фонг настройки нижней гривы'
gui.ppm2.editor.mane.newnotice = 'Следующие опции имеют эффект только на новой модели'

for i = 1, 2
	gui.ppm2.editor.mane['color' .. i] = "Цвет гривы #{i}"
	gui.ppm2.editor.mane.up['color' .. i] = "Цвет верхней гривы #{i}"
	gui.ppm2.editor.mane.down['color' .. i] = "Цвет нижней гривы #{i}"

for i = 1, 6
	gui.ppm2.editor.mane['detail_color' .. i] = "Деталь гривы #{i}"
	gui.ppm2.editor.mane.up['detail_color' .. i] = "Деталь верхней гривы #{i}"
	gui.ppm2.editor.mane.down['detail_color' .. i] = "Деталь нижней гривы #{i}"

	gui.ppm2.editor.url_mane['desc' .. i] = "URL деталь гривы #{i}"
	gui.ppm2.editor.url_mane['color' .. i] = "Цвет URL детали #{i}"

	gui.ppm2.editor.url_mane.sep.up['desc' .. i] = "URL деталь верхней гривы #{i}"
	gui.ppm2.editor.url_mane.sep.up['color' .. i] = "Цвет URL детали верхней гривы #{i}"

	gui.ppm2.editor.url_mane.sep.down['desc' .. i] = "URL деталь нижней гривы #{i}"
	gui.ppm2.editor.url_mane.sep.down['color' .. i] = "Цвет URL детали нижней гривы #{i}"

gui.ppm2.editor.ears.bat = 'Уши бэт-пони'
gui.ppm2.editor.ears.size = 'Размер ушей'

gui.ppm2.editor.horn.detail_color = 'Цвет детали рога'
gui.ppm2.editor.horn.glowing_detail = 'Светящаяся деталь рога'
gui.ppm2.editor.horn.glow_strength = 'Сила свечения'
gui.ppm2.editor.horn.separate_color = 'Отделить цвет рога от тела'
gui.ppm2.editor.horn.color = 'Цвет рога'
gui.ppm2.editor.horn.horn_phong = 'Фонг параметры рога'
gui.ppm2.editor.horn.magic = 'Цвет магии рога'
gui.ppm2.editor.horn.separate_magic_color = 'Отделить цвет магии от цвета глаз'
gui.ppm2.editor.horn.separate = 'Отделить цвет рога от тела'
gui.ppm2.editor.horn.separate_phong = 'Отделить настройки фонга рога от тела'

for i = 1, 3
	gui.ppm2.editor.horn.detail['desc' .. i] = "URL деталь рога #{i}"
	gui.ppm2.editor.horn.detail['color' .. i] = "Цвет URL детали рога #{i}"

gui.ppm2.editor.wings.separate_color = 'Отделить цвет крыльев от тела'
gui.ppm2.editor.wings.color = 'Цвет крыльев'
gui.ppm2.editor.wings.wings_phong = 'Фонг параметры крыльев'
gui.ppm2.editor.wings.separate = 'Отделить цвет крыльев от тела'
gui.ppm2.editor.wings.separate_phong = 'Отделить настройки фонга крыльев от тела'
gui.ppm2.editor.wings.bat_color = 'Цвет крыльев летучей мыши'
gui.ppm2.editor.wings.bat_skin_color = 'Цвет кожи крыльев летучей мыши'
gui.ppm2.editor.wings.bat_skin_phong = 'Фонг параметры кожи бет крыльев'

gui.ppm2.editor.wings.normal = 'Обычные крылья'
gui.ppm2.editor.wings.bat = 'Крылья летучей мыши'
gui.ppm2.editor.wings.bat_skin = 'Кожа крыльев летучей мыши'

gui.ppm2.editor.wings.left.size = 'Размер левого крыла'
gui.ppm2.editor.wings.left.fwd = 'X левого крыла'
gui.ppm2.editor.wings.left.up = 'Z левого крыла'
gui.ppm2.editor.wings.left.inside = 'Y левого крыла'

gui.ppm2.editor.wings.right.size = 'Размер правого крыла'
gui.ppm2.editor.wings.right.fwd = 'X правого крыла'
gui.ppm2.editor.wings.right.up = 'Z правого крыла'
gui.ppm2.editor.wings.right.inside = 'Y правого крыла'

for i = 1, 3
	gui.ppm2.editor.wings.details.def['detail' .. i] = "URL деталь крыльев #{i}"
	gui.ppm2.editor.wings.details.def['color' .. i] = "Цвет URL детали крыльев #{i}"
	gui.ppm2.editor.wings.details.bat['detail' .. i] = "URL деталь бэт-крыльев #{i}"
	gui.ppm2.editor.wings.details.bat['color' .. i] = "Цвет URL детали крыльев #{i}"
	gui.ppm2.editor.wings.details.batskin['detail' .. i] = "Bat wing деталь кожи бэт-крыльев #{i}"
	gui.ppm2.editor.wings.details.batskin['color' .. i] = "Цвет URL детали кожи бэт-крыльев #{i}"

gui.ppm2.editor.neck.height = 'Neck height'

gui.ppm2.editor.body.suit = 'Костюм'
gui.ppm2.editor.body.color = 'Цвет тела'
gui.ppm2.editor.body.body_phong = 'Фонг параметрый тела'
gui.ppm2.editor.body.spine_length = 'Длинна спины'
gui.ppm2.editor.body.url_desc = 'URL детали тела\nДолжны быть в формате PNG или JPEG (работает так же\nкак и PAC3 URL текстуры)'

for i = 1, PPM2.MAX_BODY_DETAILS
	gui.ppm2.editor.body.detail['desc' .. i] = "Деталь #{i}"
	gui.ppm2.editor.body.detail['color' .. i] = "Цвет детали #{i}"
	gui.ppm2.editor.body.detail['glow' .. i] = "Деталь #{i} светится"
	gui.ppm2.editor.body.detail['glow_strength' .. i] = "Сила свечения #{i} детали"

	gui.ppm2.editor.body.detail.url['desc' .. i] = "Деталь #{i}"
	gui.ppm2.editor.body.detail.url['color' .. i] = "Цвет детали #{i}"

gui.ppm2.editor.tattoo.edit_keyboard = 'Редактировать используя клавиатуру'
gui.ppm2.editor.tattoo.type = 'Тип'
gui.ppm2.editor.tattoo.over = 'Тату поверх деталей тела'
gui.ppm2.editor.tattoo.glow = 'Тату светится'
gui.ppm2.editor.tattoo.glow_strength = 'Сила свечения тату'
gui.ppm2.editor.tattoo.color = 'Цвет тату'

gui.ppm2.editor.tattoo.tweak.rotate = 'Поворот'
gui.ppm2.editor.tattoo.tweak.x = 'X позиция'
gui.ppm2.editor.tattoo.tweak.y = 'Y позиция'
gui.ppm2.editor.tattoo.tweak.width = 'Ширина'
gui.ppm2.editor.tattoo.tweak.height = 'Высота'

for i = 1, PPM2.MAX_TATTOOS
	gui.ppm2.editor.tattoo['layer' .. i] = "Тату уровень #{i}"

gui.ppm2.editor.tail.type = 'Тип хвоста'
gui.ppm2.editor.tail.size = 'Размер хвоста'
gui.ppm2.editor.tail.tail_phong = 'Фонг параметры хвоста'
gui.ppm2.editor.tail.separate = 'Отделить настройки фонга хвоста от тела'

for i = 1, 2
	gui.ppm2.editor.tail['color' .. i] = 'Цвет хвоста ' .. i

for i = 1, 6
	gui.ppm2.editor.tail['detail' .. i] = "Цвет детали хвоста #{i}"
	gui.ppm2.editor.tail.url['detail' .. i] = "URL деталь хвоста #{i}"
	gui.ppm2.editor.tail.url['color' .. i] = "Цвет URL детали хвоста #{i}"

gui.ppm2.editor.hoof.fluffers = 'Мех у копыт'

gui.ppm2.editor.legs.height = 'Высота ног'
gui.ppm2.editor.legs.socks.simple = 'Носочки (простая текстура)'
gui.ppm2.editor.legs.socks.model = 'Носочки (моделью)'
gui.ppm2.editor.legs.socks.color = 'Цвет носок'
gui.ppm2.editor.legs.socks.socks_phong = 'Фонг параметры носок'
gui.ppm2.editor.legs.socks.texture = 'Текстура носок'
gui.ppm2.editor.legs.socks.url_texture = 'URL текстура носок'

for i = 1, 6
	gui.ppm2.editor.legs.socks['color' .. i] = 'Цвет детали носок ' .. i

gui.ppm2.editor.legs.newsocks.model = 'Носочки (как новая модель)'

for i = 1, 3
	gui.ppm2.editor.legs.newsocks['color' .. i] = 'Цвет новых носков ' .. i

gui.ppm2.editor.legs.newsocks.url = 'URL текстура новых носков'

-- shared editor stuffs

gui.ppm2.editor.tattoo.help = "Что бы выйти из режима редактирования, нажмите ESC
Или нажмите где угодно мышью. Двигать на WASD
Верхняя и нижняя стрелки отвечают за размер по вертикали
Правая и левая стрелки отвечают за размер по горизонтали
Q/E отвечают за поворот"

gui.ppm2.editor.reset_value = 'Сбросить %s'

gui.ppm2.editor.phong.info = 'Больше информации про Фонг на вики'
gui.ppm2.editor.phong.exponent = 'Фонговая экспонента - насолько сильна отражающая способность\nЗначение около нуля делает почти зеркальную\nповерхность кожи (робот глянцевой краской)'
gui.ppm2.editor.phong.exponent_text = 'Фонговая экспонента'
gui.ppm2.editor.phong.boost.title = 'Фонговое усиление - контролирует усиление отражений'
gui.ppm2.editor.phong.boost.boost = 'Фонговое усиление'
gui.ppm2.editor.phong.tint.title = 'Tint цвет - цвет отражений фонга'
gui.ppm2.editor.phong.tint.tint = 'Tint цвет'
gui.ppm2.editor.phong.frensel.front.title = 'Фонг впрямь - Множитель отражения при угле Френселя 0'
gui.ppm2.editor.phong.frensel.front.front = 'Фонг впрямь'
gui.ppm2.editor.phong.frensel.middle.title = 'Фонг в угол - Множитель отражения при угле Френселя 45'
gui.ppm2.editor.phong.frensel.middle.front = 'Фонг в угол'
gui.ppm2.editor.phong.frensel.sliding.title = 'Фонг вскользь - Множитель отражения при угле Френселя 90'
gui.ppm2.editor.phong.frensel.sliding.front = 'Фонг вскользь'
gui.ppm2.editor.phong.lightwarp = 'Lightwarp'
gui.ppm2.editor.phong.url_lightwarp = 'Lightwarp URL текстура\nОБЯЗАНА БЫТЬ 256x16!'
gui.ppm2.editor.phong.bumpmap = 'URL текстура'

gui.ppm2.editor.info.discord = "Присоединяйтесь к Дискорд серверу DBotThePony!"
gui.ppm2.editor.info.ponyscape = "PPM/2 это проект Ponyscape"
gui.ppm2.editor.info.creator = "PPM/2 был создан и поддерживается DBotThePony"
gui.ppm2.editor.info.newmodels = "Новые модели были созданы Durpy"
gui.ppm2.editor.info.cppmmodels = "CPPM модели (включая руки) принадлежат UnkN"
gui.ppm2.editor.info.oldmodels = "Старые модели принадлежат Scentus и Остальным"
gui.ppm2.editor.info.bugs = "Нашли баг? Репорт!"
gui.ppm2.editor.info.sources = "Вы можете найти исходники аддона тут"
gui.ppm2.editor.info.githubsources = "Или на GitHub зеркале"
gui.ppm2.editor.info.thanks = "Спасибочки всем участвующим при разработке,\nсо своей критикой к PPM/2!"

-- other stuff

info.ppm2.fly.pegasus = 'Вы должны быть пегасом или аликорном что бы летать!'
info.ppm2.fly.cannot = 'Вы сейчас не можете %s.'

gui.ppm2.emotes.sad = 'Грустный'
gui.ppm2.emotes.wild = 'Дикий'
gui.ppm2.emotes.grin = 'Оскал'
gui.ppm2.emotes.angry = 'Злой'
gui.ppm2.emotes.tongue = ':P'
gui.ppm2.emotes.angrytongue = '>:P'
gui.ppm2.emotes.pff = 'пфффф!'
gui.ppm2.emotes.kitty = ':3'
gui.ppm2.emotes.owo = 'oWo'
gui.ppm2.emotes.ugh = 'эмммм'
gui.ppm2.emotes.lips = 'Губолиз'
gui.ppm2.emotes.scrunch = 'Сморщенный'
gui.ppm2.emotes.sorry = 'Ой'
gui.ppm2.emotes.wink = 'Подмигивание'
gui.ppm2.emotes.right_wink = 'Правое Подмигивание'
gui.ppm2.emotes.licking = 'Лижет'
gui.ppm2.emotes.suggestive_lips = 'Оч. губолиз'
gui.ppm2.emotes.suggestive_no_tongue = 'Оч. без языка'
gui.ppm2.emotes.gulp = 'Сглотнуть от страха'
gui.ppm2.emotes.blah = 'бла бла бла'
gui.ppm2.emotes.happi = 'Счастье!'
gui.ppm2.emotes.happi_grin = 'Счастливая улыбка'
gui.ppm2.emotes.duck = 'УТОЧКА'
gui.ppm2.emotes.ducks = 'АТАКА УТОЧЕК'
gui.ppm2.emotes.quack = 'КРЯ'
gui.ppm2.emotes.suggestive = 'Оч. с языком'

message.ppm2.emotes.invalid = 'Нет эмоции с таким ID: %s'

gui.ppm2.editor.intro.text = "Представляю вам... своего... Робохирурга для поней! Он позволит вам стать\n" ..
	"пони, и да, этот процесс НЕОБРАТИМ! Но неволнуйтесь, вы не потеряете какие либо клетки головного\n" ..
	"мозга, так как он работает очень аккуратно...\n\n" ..
	"А если честно я не знаю, ты, биологическое существо! Он обнимет тебя так, как никто иной.\n" ..
	"И да, не умрите в процессе, иначе это ОБНУЛИТ ВАШУ ГАРАНТИЮ НА ЖИЗНЬ! И вы не сможете стать пони!\n" ..
	"----\n\n\n" ..
	"ВНИМЕНИЕ: Не разбирайте робохирурга.\nНе ложите свои руки/копыта в двигающиеся части робохирурга.\n" ..
	"Не отключать от сети.\nНе противостоять его действиям.\n" ..
	"Всегда уважайте своего робохирурга.\n" ..
	"Не бейте робохирурга по лицу.\n" ..
	"DBot's DLibCo не несёт никакой ответственности за вред приченённый робохирургом.\n" ..
	"Гарантия обнуляется когда пользователь погибает.\n" ..
	"Товар не подлежит возврату."
gui.ppm2.editor.intro.title = 'Добро пожаловать, Биологическое сущес... Человек!'
gui.ppm2.editor.intro.okay = "к, я все равно это никогда не читаю"

message.ppm2.debug.race_condition = 'У NetworkedPonyData состояние гонки с движком игры. Ожидаю...'

gui.ppm2.spawnmenu.newmodel = 'Создать новую модель'
gui.ppm2.spawnmenu.newmodelnj = 'Создать новую модель NJ'
gui.ppm2.spawnmenu.oldmodel = 'Создать старую модель'
gui.ppm2.spawnmenu.oldmodelnj = 'Создать старую модель NJ'
gui.ppm2.spawnmenu.cppmmodel = 'Создать CPPM модель'
gui.ppm2.spawnmenu.cppmmodelnj = 'Создать CPPM модель NJ'
gui.ppm2.spawnmenu.cleanup = 'Принудительно собрать мусор'
gui.ppm2.spawnmenu.reload = 'Перезагрузить вашу пони'
gui.ppm2.spawnmenu.require = 'Запросить данные с сервера'
gui.ppm2.spawnmenu.drawhooves = 'Отрисовывать копыта как руки'
gui.ppm2.spawnmenu.nohoofsounds = 'Отключить звуки копыт'
gui.ppm2.spawnmenu.noflexes = 'Отключить flexes (эмоции)'
gui.ppm2.spawnmenu.advancedmode = 'Включить расширенный режим редактора'
gui.ppm2.spawnmenu.reflections = 'Включить отражения в реальном времени'
gui.ppm2.spawnmenu.reflections_drawdist = 'Дистанция для отрисовки'
gui.ppm2.spawnmenu.reflections_renderdist = 'Точность отражений'
gui.ppm2.spawnmenu.doublejump = 'Двойной прыжок включает режим полета'

tip.ppm2.in_editor = 'В редакторе PPM/2'
tip.ppm2.camera = "PPM/2 камера игрока %s"
