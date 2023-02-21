--[[

    Standify for Stand by StealthyAD.
    Based on Startup Sounds by Lance

    "Upload easiest your own musics and use quickly as fast as possible."

    INTRODUCION: 
    Standify can use wav files which you can import each favorite music, 
    Inspired X-Force features and Lance's Startup Sounds which we can
    upload own musics  but Stand don't have these features so I decided 
    to create and using some luas script to support.

    Features:
    - Compatible All Stand Versions.
    - Multi Language Included (English (default), French, Spanish, Portuguese, Russian)
    - .wav file compatible and refresh music features.

]]--

----======================================----
---             Core Functions
--- The most essential part of Lua Script.
----======================================----

    local aalib = require("aalib")
    local StandifyPlaySound = aalib.play_sound
    local SND_ASYNC<const> = 0x0001
    local SND_FILENAME<const> = 0x00020000
    local SCRIPT_VERSION = "0.19.4"
    local edition_menu = "99.5"

    util.require_natives(1663599433)
    util.keep_running()

    ----=====================================----
    ---        Core/Variables Functions
    --- Defined where the function is located
    ----=====================================----

    local StandifyRoot = menu.my_root()
    local StandifyYield = util.yield
    local StandifyToast = util.toast
    local StandifyRestart = util.restart_script

    ----=======================================----
    --- File Directory
    --- Locate songs.wav and stop music easily.
    ----=======================================----

    local script_store_dir = filesystem.store_dir() .. SCRIPT_NAME .. '\\songs' -- Redirects to %appdata%\Stand\Lua Scripts\store\Standify\songs
    if not filesystem.is_dir(script_store_dir) then
        filesystem.mkdirs(script_store_dir)
    end

    local script_store_dir_stop = filesystem.store_dir() .. SCRIPT_NAME .. '/stop_sounds' -- Redirects to %appdata%\Stand\Lua Scripts\store\Standify\stop_sounds
    if not filesystem.is_dir(script_store_dir_stop) then
        filesystem.mkdirs(script_store_dir_stop)
    end

    ----=============================================----
    ---                 Functions
    --- The Most important part how the script works
    ----=============================================----

    local function ends_with(str, ending)
        return ending == "" or str:sub(-#ending) == ending
    end

    local StandifyFiles = {}
        function UpdateAutoMusics()
            Music_TempFiles = {}
            for i, path in ipairs(filesystem.list_files(script_store_dir)) do
                local file_str = path:gsub(script_store_dir, ''):gsub("\\","")
                if ends_with(file_str, '.wav') then
                    Music_TempFiles[#Music_TempFiles+1] = file_str
                end
            end
            StandifyFiles = Music_TempFiles
        end
        UpdateAutoMusics()

    local function join_path(parent, child)
        local sub = parent:sub(-1)
        if sub == "/" or sub == "\\" then
            return parent .. child
        else
            return parent .. "/" .. child
        end
    end

    local current_sound_handle = nil
    local random_enabled = false

    local function AutoPlay(sound_location)
        if current_sound_handle then
            aalib.stop_sound(current_sound_handle)
            current_sound_handle = nil
        end
    
        current_sound_handle = aalib.play_sound(sound_location, SND_FILENAME | SND_ASYNC, function()
            if random_enabled then
                AutoPlay(sound_location)
            end
        end)
    end

    local function StandifyLoading(directory)
        local StandifyLoadedSongs = {}
        for _, filepath in ipairs(filesystem.list_files(directory)) do
            local _, filename, ext = string.match(filepath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
            if not filesystem.is_dir(filepath) and ext == "wav" then
                local name = string.gsub(filename, "%.wav$", "")
                local sound_location = join_path(directory, filename)
                StandifyLoadedSongs[#StandifyLoadedSongs + 1] = {file=name, sound=sound_location}
            end
        end
        return StandifyLoadedSongs
    end

    function GetFileNameFromPath(path) -- Redirect to the filename
        if path and path ~= "" then -- check if path is not nil or empty
            return path:match("^.+/(.+)$")
        end
        return nil
    end
	
    ----=============================================----
    ---                Updates Features
    --- Update manually/automatically the Lua Scripts
    ---     Import from Hexarobi Auto-Updater.
    ----=============================================----

    local default_check_interval = 604800
    local auto_update_config = {
        source_url="https://raw.githubusercontent.com/StealthyAD/Standify/main/Standify.lua",
        script_relpath=SCRIPT_RELPATH,
        switch_to_branch=selected_branch,
        verify_file_begins_with="--",
        check_interval=86400,
        silent_updates=true,
    }

    -- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
    local status, auto_updater = pcall(require, "auto-updater")
    if not status then
        local auto_update_complete = nil StandifyToast("Installing auto-updater...", TOAST_ALL)
        async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
            function(result, headers, status_code)
                local function parse_auto_update_result(result, headers, status_code)
                    local error_prefix = "Error downloading auto-updater: "
                    if status_code ~= 200 then StandifyToast(error_prefix..status_code, TOAST_ALL) return false end
                    if not result or result == "" then StandifyToast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                    filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                    local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                    if file == nil then StandifyToast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                    file:write(result) file:close() StandifyToast("Successfully installed auto-updater lib", TOAST_ALL) return true
                end
                auto_update_complete = parse_auto_update_result(result, headers, status_code)
            end, function() StandifyToast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
        async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
        if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
        auto_updater = require("auto-updater")
    end
    if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end
    
    -- Run Auto Update
    auto_updater.run_auto_update({
        source_url="https://raw.githubusercontent.com/StealthyAD/Standify/main/Standify.lua",
        script_relpath=SCRIPT_RELPATH,
        verify_file_begins_with="--"
    })
    auto_updater.run_auto_update(auto_update_config)


    ----=========================================================----
    ---               Translation Features
    --- Translate Easier the language based on your language game
    ----=========================================================----


    user_lang = lang.get_current()
    local en_table = {"en","en-us","hornyuwu","uwu","sex"}
    local english
    local supported_lang
    for _,lang in pairs(en_table) do
        if user_lang == lang then
            english = true
            supported_lang = true
            break
        end
    end

    if not supported_lang then
        local SupportedLang = function()
            local supported_lang_table = {"fr", "de", "es", "pt", "ru"}
            for _,tested_lang in pairs(supported_lang_table) do
                if tested_lang == user_lang then
                    supported_lang = true
                    return
                end
            end
            english = true
            StandifyToast("> Standify\nSorry your language isn't supported. Script language set to English.")
        end
        SupportedLang()
    end

    local tr_table = {
        fr = { -- French Language (Français)
            ["Refresh Script"] = "Actualiser le Script",
            ["Main Menu"] = "Menu Principal",
            ["Open Music Folders"] = "Ouvrir le dossier Musique",
            ["Stop Music"] = "Arrêter la musique",
            ["Saved Playlists"] = "Playlists sauvegardés",
            ["Miscellaneous"] = "Divers Options",
            ["Refresh instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Ré-actualise instantanément le script si il y'a des problèmes qui peuvent dégénérer.\nNOTE: Cela va couper instantanément la musique.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Modifier la disposition de votre musique et profitez-en au maximum.\nNOTE: vous devrez obligatoirement mettre sous forme de fichier .wav\nLes fichiers MP3 ou d'autres fichiers contenant des fichiers invalides ne seront pas acceptés.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Il arrêtera votre musique instantanément. \nNOTE : Ne supprimez pas le dossier appelé Stop Sounds, la musique ne s'arrêtera pas et sera mise en boucle. Ne renommez pas le fichier.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Avoir crée le lua Startup Sound et je me suis inspiré pour créer le lua pour créer des playlists et rendre plus facile.",
            ["Provides much features & essentials for Lua Scripts."] = "Fournit beaucoup de fonctionnalités et d'éléments essentiels pour les scripts Lua.",
            ["Visit my GitHub Page"] = "Visite ma page GitHub",
            ["Join my TikTok"] = "Rejoins mon TikTok",
            ["> Standify\nSelected Music: "] = "> Standify\nMusique choisie: ",
            ["> Standify\nMusic file does not exist:"] = "> Standify\nLe fichier musical n'existe pas :",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTE : Vous devez obtenir le fichier, sinon vous ne pourrez pas arrêter le son.",
            ["> Standify\nMusic stopped successfully."] = "> Standify\nMusique arrêté avec succès.",
            ["Hello "] = "Bonjour ",
            ["\nWelcome to Standify "] = "\nBienvenue sur le script Standify ",
            ["Informations"] = "Informations",
            ["Credits"] = "Crédits",
            ["Resources"] = "Ressources",
            ["Version: "] = "Version: ",
            ["Stand Edition: "] = "Stand Edition: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "Attention: Dossier lourd, vérifiez que vous avez un gros stockage, en moyenne un fichier .wav est entre 25-50 Mo.",
            ["WAV Compress & Converter"] = "Compresseur et convertisseur WAV",
            ["The script will automatically check for updates at most daily, but you can manually check using this option anytime."] = "Le script vérifiera automatiquement les mises à jour au plus tard tous les jours, mais vous pouvez vérifier manuellement en utilisant cette option à tout moment.",
            ["Check for Updates"] = "Vérifier les mises à jour",
            ["> Standify\nNo updates found."] = "> Standify\nPas de mise à jour trouvé.",
            -- Converter & Compress
            ["Compressor"] = "Compresseur",
            ["Converter"] = "Convertisseur",
            -- Random Music
            ["Play Random Music"] = "Joue une musique aléatoire",
            ["Play a random music.\nNOTE: You have each interval to click the action to select random music."] = "Jouer une musique aléatoire.\nNOTE : Vous devez cliquer à chaque intervalle sur l'action pour sélectionner la musique aléatoire.",	
            ["> Standify\nRandom music selected: "] = "> Standify\nMusique aléatoire choisie: ",
            ["> Standify\nThere is no music in the storage folder."] = "> Standify\nIl n'y a pas de musique dans le dossier de stockage.",
        },

        de = { -- German Language (Deutsch)
            ["Refresh Script"] = "Das Skript aktualisieren",
            ["Main Menu"] = "Hauptmenü",
            ["Open Music Folders"] = "Musikordner öffnen",
            ["Stop Music"] = "Musik anhalten",
            ["Saved Playlists"] = "Gespeicherte Playlists",
            ["Miscellaneous"] = "Diverse",
            ["Refresh instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Aktualisieren Sie das Skript sofort, wenn Sie Probleme haben.\nHinweis: Die Musik wird sofort abgeschaltet.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Bearbeiten Sie Ihre Musik und genießen Sie sie.\nHinweis: Sie müssen eine .wav-Datei einfügen.\nMP3 oder andere Dateien mit ungültigen Dateien werden nicht akzeptiert.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Die Musik wird sofort gestoppt. HINWEIS: Löschen Sie nicht den Ordner 'Stop Sounds', sonst wird die Musik nicht gestoppt und in einer Schleife abgespielt. Benennen Sie die Datei nicht um.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Erstellt Startup Sound und ich verbessere die Lua, um Playlists zu erstellen und einfacher zu machen.",
            ["Provides much features & essentials for Lua Scripts."] = "Bietet viele Funktionen und Grundlagen für Lua-Skripte.",
            ["Visit my GitHub Page"] = "Besuchen Sie meine Github-Seite",
            ["Join my TikTok"] = "Meinem TikTok beitreten",
            ["> Standify\nSelected Music: "] = "> Standify\nAusgewählte Musik: ",
            ["> Standify\nMusic file does not exist:"] = "> Standify\nDie Musikdatei existiert nicht:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nHinweis: Sie müssen die Datei erhalten, sonst können Sie den Ton nicht anhalten.",
            ["> Standify\nMusic stopped successfully."] = "> Standify\nWurde erfolgreich beendet.",
            ["Hello "] = "Guten Tag ",
            ["\nWelcome to Standify "] = "\nWillkommen im script Standify ",
            ["Informations"] = "Informationen",
            ["Credits"] = "Impressum",
            ["Resources"] = "Ressourcen",
            ["Version: "] = "Version: ",
            ["Stand Edition: "] = "Stand Ausgabe: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "WARNUNG: Schwerer Ordner, also prüfen Sie, ob Sie viel Speicherplatz haben, mindestens eine durchschnittliche .wav-Datei: 25-100 MB.",
            ["WAV Compress & Converter"] = "WAV-Kompressor & Konverter",
            ["The script will automatically check for updates at most daily, but you can manually check using this option anytime."] = "Das Skript sucht höchstens einmal täglich automatisch nach Aktualisierungen, aber Sie können diese Option auch jederzeit manuell nutzen.",
            ["Check for Updates"] = "Überprüfung auf Aktualisierung",
            ["> Standify\nNo updates found."] = "> Standify\nKeine Updates gefunden.",
            -- Converter & Compress
            ["Compressor"] = "Kompressor",
            ["Converter"] = "Konverter",
            -- Random Music
            ["Play Random Music"] = "Zufällige Musik abspielen",	
            ["Play a random music.\nNOTE: You have each interval to click the action to select random music."] = "Zufallsmusik abspielen.\nHINWEIS: Sie müssen in jedem Intervall auf die Aktion klicken, um Zufallsmusik auszuwählen.",
            ["> Standify\nRandom music selected: "] = "> Standify\nZufällig ausgewählte Musik: ",
            ["> Standify\nThere is no music in the storage folder."] = "> Standify\nEs befindet sich keine Musik im Speicherordner.",
        },

        es = { -- Spanish Language (Español)
            ["Refresh Script"] = "Actualizar script",
            ["Main Menu"] = "Menú principal",
            ["Open Music Folders"] = "Abrir carpetas de música",
            ["Stop Music"] = "Detener música",
            ["Saved Playlists"] = "Listas de reproducción guardadas",
            ["Miscellaneous"] = "Varios",
            ["Refresh instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Actualice instantáneamente el script si tiene algún problema.\nNOTA: Se apagará instantáneamente la música.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Edita tu música y disfruta.\nNOTA: Necesitas poner archivo .wav.\nNo se aceptan MP3 u otros archivos que contengan archivos inválidos.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Detendrá tu música instantáneamente.\nNOTA: No borres la carpeta llamada Detener Sonidos, la música no se detendrá y se reproducirá en bucle. No cambies el nombre del archivo. Se detendrá la música al instante",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Creado Startup Sound y mejoro el lua para crear Listas de Reproducción y hacerlo más fácil.",
            ["Provides much features & essentials for Lua Scripts."] = "Proporciona muchas características y elementos esenciales para scripts Lua.",
            ["Visit my GitHub Page"] = "Visita mi página de GitHub",
            ["Join my TikTok"] = "Únete a mi TikTok",
            ["> Standify\nSelected Music: "] = "> Standify\nMúsica seleccionada: ",
            ["> Standify\nMusic file does not exist:"] = "> Standify\nEl archivo de música no existe:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTA: Es necesario obtener el archivo, de lo contrario no se puede detener el sonido.",
            ["> Standify\nMusic stopped successfully."] = "> Standify\nLa música se detuvo con éxito.",
            ["Hello "] = "Hola ",
            ["\nWelcome to Standify "] = "\nBienvenido a Standify ",
            ["Informations"] = "Información",
            ["Credits"] = "Créditos",
            ["Resources"] = "Recursos",
            ["Version: "] = "Versión: ",
            ["Stand Edition: "] = "Stand Edición: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "ADVERTENCIA: Carpeta pesada, así que compruebe si tiene gran almacenamiento, al menos archivo .wav promedio: 25-100 MB.",
            ["WAV Compress & Converter"] = "Compresor y conversor WAV",
            ["The script will automatically check for updates at most daily, but you can manually check using this option anytime."] = "El script comprobará automáticamente si hay actualizaciones como máximo a diario, pero puede comprobarlo manualmente utilizando esta opción en cualquier momento.",
            ["Check for Updates"] = "Comprobar la actualización",
            ["> Standify\nNo updates found."] = "> Standify\nNo se han encontrado actualizaciones.",
            -- Converter & Compress
            ["Compressor"] = "Compresor",
            ["Converter"] = "Conversor",
            -- Random Music
            ["Play Random Music"] = "Reproducir música aleatoria",
            ["Play a random music.\nNOTE: You have each interval to click the action to select random music."] = "Reproducir una música al azar.\nNOTA: Tienes cada intervalo para hacer clic en la acción para seleccionar la música al azar.",
            ["> Standify\nRandom music selected: "] = "> Standify\nMúsica seleccionada al azar: ",
            ["> Standify\nThere is no music in the storage folder."] = "> Standify\nNo hay música en la carpeta de almacenamiento.",
        },
        pt = { -- Portuguese/Brazil Language (Português)
            ["Refresh Script"] = "Atualize o script",
            ["Main Menu"] = "Menu principal",
            ["Open Music Folders"] = "Pastas de Música Abertas",
            ["Stop Music"] = "Parar a música",
            ["Saved Playlists"] = "Listas de Reprodução Guardadas",
            ["Miscellaneous"] = "Miscelânea",
            ["Refresh instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Actualizar instantaneamente o guião se tiver algum problema.\nNOTE: Irá encerrar instantaneamente a música.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Edite a sua música e desfrute.\nNOTE: É necessário colocar ficheiro .wav.\nMP3 ou outro ficheiro contendo ficheiros inválidos não são aceites.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Não apague a pasta chamada Stop Sounds, a música não pára e faz um looping. Não renomeie o ficheiro.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Criei o Startup Sound e melhorei a lua para criar listas de reprodução e tornar mais fácil.",
            ["Provides much features & essentials for Lua Scripts."] = "Fornece muitas características & essências para Lua Scripts.",
            ["Visit my GitHub Page"] = "Visite a minha página GitHub",
            ["Join my TikTok"] = "Junte-se ao meu TikTok",
            ["> Standify\nSelected Music: "] = "> Standify\nMúsica seleccionada: ",
            ["> Standify\nMusic file does not exist:"] = "> Standify\nFicheiro de música não existe:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTA: É necessário obter o ficheiro, caso contrário não se pode parar o som.",
            ["> Standify\nMusic stopped successfully."] = "> Standify\nA música parou com sucesso.",
            ["Hello "] = "Olá ",
            ["\nWelcome to Standify "] = "\nBem-vindo ao Standify ",
            ["Informations"] = "Informações",
            ["Credits"] = "Créditos",
            ["Resources"] = "Recursos",
            ["Version: "] = "Versão: ",
            ["Stand Edition: "] = "Stand Edição: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "ADVERTÊNCIA: pasta pesada, por isso verifique se tem um grande armazenamento, pelo menos um ficheiro .wav médio: 25-100 MB.",
            ["WAV Compress & Converter"] = "WAV Compressor & Conversor",
            ["The script will automatically check for updates at most daily, but you can manually check using this option anytime."] = "O script verificará automaticamente as actualizações no máximo diariamente, mas pode verificar manualmente usando esta opção em qualquer altura.",
            ["Check for Updates"] = "Verificar por Actualização",
            ["> Standify\nNo updates found."] = "Nenhuma actualização encontrada",
            -- Converter & Compress
            ["Compressor"] = "Compressor",
            ["Converter"] = "Conversor",
            -- Random Music
            ["Play Random Music"] = "Reproduzir música aleatória",
            ["Play a random music.\nNOTE: You have each interval to click the action to select random music."] = "Tocar uma música aleatória.\nNOTA: Você tem cada intervalo para clicar na ação para selecionar música aleatória.",
            ["> Standify\nRandom music selected: "] = "> Standify\nMúsica aleatória selecionada: ",
            ["> Standify\nThere is no music in the storage folder."] = "> Standify\nNão há música na pasta de armazenamento.",
        },
        ru = { -- Russian Language (русский)
            ["Refresh Script"] = "Обновить скрипт",
            ["Main Menu"] = "Главное меню",
            ["Open Music Folders"] = "Открыть папки с музыкой",
            ["Stop Music"] = "Остановить музыку",
            ["Saved Playlists"] = "Сохраненные плейлисты",
            ["Miscellaneous"] = "Разное",
            ["Refresh instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "При возникновении проблем мгновенно обновите скрипт.\nПРИМЕЧАНИЕ: Он мгновенно выключит музыку.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Редактируйте музыку и наслаждайтесь.\nNOTE: Вам нужно вставить .wav файл.\nMP3 или другие файлы, содержащие недействительный файл, не принимаются.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Это мгновенно остановит вашу музыку.\nNOTE: Не удаляйте папку под названием Stop Sounds, музыка не остановится и зациклится. Не переименовывайте файл.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Создал Startup Sound и улучшаю lua, чтобы создавать плейлисты и сделать проще.",
            ["Provides much features & essentials for Lua Scripts."] = "Предоставляет много возможностей и основ для Lua скриптов.",
            ["Visit my GitHub Page"] = "Посетите мою страницу на GitHub",
            ["Join my TikTok"] = "Присоединяйтесь к моему TikTok",
            ["> Standify\nSelected Music: "] = "> Standify\nВыбранная музыка: ",
            ["> Standify\nMusic file does not exist:"] = "> Standify\nМузыкальный файл не существует:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTE: Вам нужно получить файл, иначе вы не сможете остановить звук.",
            ["> Standify\nMusic stopped successfully."] = "> Standify\nМузыка успешно остановлена.",
            ["Hello "] = "Привет ",
            ["\nWelcome to Standify "] = "\nДобро пожаловать в Standify ",
            ["Informations"] = "Информация",
            ["Credits"] = "Кредиты",
            ["Resources"] = "Ресурсы",
            ["Version: "] = "Версия: ",
            ["Stand Edition: "] = "Stand Издание: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "ВНИМАНИЕ: тяжелая папка, поэтому проверьте, есть ли у вас большой объем памяти, по крайней мере, средний .wav файл: 25-100 МБ.",
            ["WAV Compress & Converter"] = "Сжатие и преобразование WAV",
            ["The script will automatically check for updates at most daily, but you can manually check using this option anytime."] = "Скрипт будет автоматически проверять наличие обновлений не чаще, чем ежедневно, но вы можете вручную проверять их с помощью этой опции в любое время.",
            ["Check for Updates"] = "Проверка обновления",
            ["> Standify\nNo updates found."] = "Обновления не найдены",
            -- Converter & Compress
            ["Compressor"] = "компрессор",
            ["Converter"] = "Конвертер",
            -- Random Music
            ["Play Random Music"] = "Воспроизведение случайной музыки",
            ["Play a random music.\nNOTE: You have each interval to click the action to select random music."] = "Воспроизведение случайной музыки.\nПРИМЕЧАНИЕ: У вас есть каждый интервал, чтобы нажать на действие для выбора случайной музыки.",
            ["> Standify\nRandom music selected: "] = "> Standify\nСлучайный выбор музыки: ",
            ["> Standify\nThere is no music in the storage folder."] = "> Standify\nВ папке хранения нет музыки."
        }
    }

    ForceTranslate = function(str)
        if not english then
            local forcetranslate_str = tr_table[user_lang][str]
            if forcetranslate_str == nil or forcetranslate_str == "" then
                StandifyToast("> Standify (translation missing) : '"..str.."'",TOAST_CONSOLE)
            else
                return forcetranslate_str
            end
        end
        return str
    end

    ----=====================================================----
    ---               Main Menu Features
    ---     All of the functions, actions, list are available
    ----=====================================================----

    local sound_handle = nil

    StandifyRoot:hyperlink(ForceTranslate("Open Music Folders"), "file://"..script_store_dir, ForceTranslate("Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted.")) -- Open Music Folder contains your own Musics
    StandifyRoot:action(ForceTranslate("Refresh Script"), {'Standifyrefresh'}, ForceTranslate("Refresh instantly the script if have any problems.\nNOTE: It will Instantly shut down music."), function() -- Refresh Script
        sound_handle = StandifyPlaySound(join_path(script_store_dir_stop, "stop.wav"), SND_FILENAME | SND_ASYNC)
        StandifyRestart()
    end)

    StandifyRoot:divider(ForceTranslate("Main Menu")) -- Main Menu Divider

    
    ----============================================================================----
    ---                         Saved Playlists
    --- All of your musics stored on %appdata%\Stand\Lua Scripts\Standify\songs\
    ----============================================================================----

    local songs_direct = join_path(script_store_dir, "")
    local StandifyLoadedSongs = StandifyLoading(songs_direct)
    local StandifyFiles = {}
    for _, song in ipairs(StandifyLoadedSongs) do
        StandifyFiles[#StandifyFiles + 1] = song.file
    end
    
    local function StandifyPlay(sound_location)
        if current_sound_handle then
            current_sound_handle = nil
        end
        current_sound_handle = StandifyPlaySound(sound_location, SND_FILENAME | SND_ASYNC)
    end
    
    local StandifyList = StandifyRoot:list_action(ForceTranslate("Saved Playlists"), {}, ForceTranslate("WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."), StandifyFiles, function(selected_index)
        local selected_file = StandifyFiles[selected_index]
        for _, song in ipairs(StandifyLoadedSongs) do
            if song.file == selected_file then
                local sound_location = song.sound
                if not filesystem.exists(sound_location) then
                    StandifyToast("> Standify : Sound file does not exist: " .. sound_location)
                else
                    local display_text = string.gsub(selected_file, "%.wav$", "")
                    StandifyPlay(sound_location)
                    StandifyToast(ForceTranslate("> Standify\nSelected Music: ") .. display_text)
                end
                break
            end
        end
    end)

    ----=====================================================----
    ---               Hyperlinks
    ---     Only for download converter or sometimes
    ----=====================================================----

    local StandifyConprVerter = StandifyRoot:list(ForceTranslate("WAV Compress & Converter")) -- Website Converter & Compress WAV. MP3 are not available
    StandifyConprVerter:divider(ForceTranslate("Compressor"))
    StandifyConprVerter:hyperlink("WAV Compressor", "https://www.freeconvert.com/wav-compressor")
    StandifyConprVerter:hyperlink("xconvert", "https://www.xconvert.com/compress-wav")
    StandifyConprVerter:hyperlink("youcompress", "https://www.youcompress.com/wav/")
    StandifyConprVerter:divider(ForceTranslate("Converter"))
    StandifyConprVerter:hyperlink("WAV Converter", "https://www.freeconvert.com/wav-converter")
    StandifyConprVerter:hyperlink("cloudconvert", "https://cloudconvert.com/wav-converter")
    StandifyConprVerter:hyperlink("online-convert", "https://audio.online-convert.com/convert-to-wav")
    StandifyConprVerter:hyperlink("online-audio-coverter", "https://online-audio-converter.com/")

    ----=====================================================----
    ---               Random Music Manual
    ---     Just click one time to choose your random music
    ----=====================================================----

    local played_songs = {} 
    local function StandifyAuto()
        random_enabled = not random_enabled
        if random_enabled and current_sound_handle == nil then
            local song_files = filesystem.list_files(script_store_dir)
            if #song_files > 0 then
                local song_path
                repeat 
                    song_path = song_files[math.random(#song_files)]
                until not played_songs[song_path]
                played_songs[song_path] = true 
                AutoPlay(song_path)
                local song_title = string.match(song_path, ".+\\([^%.]+)%.%w+$")
                StandifyToast(ForceTranslate("> Standify\nRandom music selected: ") .. song_title)
            else
                StandifyToast(ForceTranslate("> Standify\nThere is no music in the storage folder."))
            end
        elseif not random_enabled and current_sound_handle then
            current_sound_handle = nil
        end
    end

    StandifyRoot:action(ForceTranslate("Play Random Music"), {'standifyrandom'}, ForceTranslate("Play a random music.\nNOTE: You have each interval to click the action to select random music."), function(selected_index)
        StandifyAuto()
    end)

    ----================================================----
    ---               Stop Sounds
    ---     Automatically end the musics while playing.
    ----================================================----

    StandifyRoot:action(ForceTranslate("Stop Music"), {'Standifystop'}, ForceTranslate("It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."), function(selected_index) -- Force automatically stop your musics
        local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
        if not filesystem.exists(sound_location_1) then
            StandifyToast(ForceTranslate("> Standify\nMusic file does not exist: ") .. sound_location_1.. ForceTranslate("\n\nNOTE: You need to get the file, otherwise you can't stop the sound."))
        else
            sound_handle = StandifyPlaySound(sound_location_1, SND_FILENAME | SND_ASYNC)
            if StandifyFiles and StandifyFiles ~= "" then -- check if StandifyFiles is not nil or empty
                StandifyToast(ForceTranslate('> Standify\nMusic stopped successfully.'))
            end
        end
    end)

    ----================================================----
    ---               Loop Features
    ---        Useful features to refresh Musics
    ----================================================----

    util.create_thread(function()
        while true do
            UpdateAutoMusics()
            menu.set_list_action_options(StandifyList, StandifyFiles)
            StandifyYield(5000)
        end
    end)

    if not SCRIPT_SILENT_START then
        StandifyToast(ForceTranslate("Hello ").. players.get_name(players.user()).. ForceTranslate("\nWelcome to Standify ") ..SCRIPT_VERSION)
    end

    util.on_stop(function()
        local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
        StandifyPlaySound(sound_location_1, SND_FILENAME | SND_ASYNC)
    end)

    ----=====================================================----
    ---               Credits/GitHub Page & Updates
    ---        Script Meta for checking credits/page/updates
    ----=====================================================----

    local StandifyMiscs = StandifyRoot:list(ForceTranslate("Miscellaneous"))

        StandifyMiscs:divider(ForceTranslate("Informations"))
        StandifyMiscs:readonly(ForceTranslate("Version: ") ..SCRIPT_VERSION)
        StandifyMiscs:readonly(ForceTranslate("Stand Edition: ") ..edition_menu)
	    StandifyMiscs:action(ForceTranslate("Check for Updates"), {}, ForceTranslate("The script will automatically check for updates at most daily, but you can manually check using this option anytime."), function()
        auto_update_config.check_interval = 0
            if auto_updater.run_auto_update(auto_update_config) then
                StandifyToast(ForceTranslate("> Standify\nNo updates found."))
            end
        end)

        StandifyMiscs:divider(ForceTranslate("Credits"))
        local StandifyStealthy = StandifyMiscs:list("StealthyAD.#8293")
        StandifyStealthy:hyperlink(ForceTranslate("Visit my GitHub Page"), "https://github.com/StealthyAD/Standify")
        StandifyStealthy:hyperlink(ForceTranslate("Join my TikTok"), "https://www.tiktok.com/@xstealthyhd")
        StandifyMiscs:action("Lance", {}, ForceTranslate("Created Startup Sound and I improve the lua to create Playlists and make easier."), function()end)

        StandifyMiscs:divider(ForceTranslate("Resources"))
        StandifyMiscs:hyperlink("Stand API", "https://stand.gg/help/lua-api-documentation", ForceTranslate("Provides much features & essentials for Lua Scripts."))
