-------------------------------
---      SpotMusic by
---       StealthyAD
---    For Stand Mod Menu
---     Multi-Language
-------------------------------

-------------------
-- Core Functions
-------------------

local aalib = require("aalib")
local SpotPlaySound = aalib.play_sound
local SND_ASYNC<const> = 0x0001
local SND_FILENAME<const> = 0x00020000
local SCRIPT_VERSION = "0.15.6"
local edition_menu = "99.3"

util.require_natives(1663599433)
util.keep_running()

--------------------------------
-- Root Parts
--------------------------------

    local SpotRoot = menu.my_root()

--------------------------------
-- File Storage Direction
--------------------------------

local script_store_dir = filesystem.store_dir() .. SCRIPT_NAME .. '\\songs' -- Redirects to %appdata%\Stand\Lua Scripts\store\SpotMusic\songs
if not filesystem.is_dir(script_store_dir) then
    filesystem.mkdirs(script_store_dir)
end

local script_store_dir_stop = filesystem.store_dir() .. SCRIPT_NAME .. '/stop_sounds' -- Redirects to %appdata%\Stand\Lua Scripts\store\SpotMusic\stop_sounds
if not filesystem.is_dir(script_store_dir_stop) then
    filesystem.mkdirs(script_store_dir_stop)
end

--------------------------------
-- Function Execution Important
--------------------------------

    local function ends_with(str, ending)
        return ending == "" or str:sub(-#ending) == ending
    end

    local SpotFiles = {}
        function UpdateAutoMusics()
            Music_TempFiles = {}
            for i, path in ipairs(filesystem.list_files(script_store_dir)) do
                local file_str = path:gsub(script_store_dir, ''):gsub("\\","")
                if ends_with(file_str, '.wav') then
                    Music_TempFiles[#Music_TempFiles+1] = file_str
                end
            end
            SpotFiles = Music_TempFiles
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

    local function SpotLoading(directory)
        local SpotLoadedSongs = {}
        for _, filepath in ipairs(filesystem.list_files(directory)) do
            local _, filename, ext = string.match(filepath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
            if not filesystem.is_dir(script_store_dir) and ext == "wav" then
                local name = string.gsub(filename, "%.wav$", "")
                local sound_location = join_path(script_store_dir, name .. ".wav")
                SpotLoadedSongs[#SpotLoadedSongs + 1] = {file=name, sound=aalib.play_sound(sound_location, SND_FILENAME | SND_ASYNC)}
            end
        end
        return SpotLoadedSongs
    end

    function GetFileNameFromPath(path) -- Redirect to the filename
        if path and path ~= "" then -- check if path is not nil or empty
            return path:match("^.+/(.+)$")
        end
        return nil
    end

--------------------------------
-- Update Features
--------------------------------

    local default_check_interval = 604800
    local auto_update_config = {
        source_url="https://raw.githubusercontent.com/StealthyAD/SpotMusic/main/SpotMusic.lua",
        script_relpath=SCRIPT_RELPATH,
        switch_to_branch=selected_branch,
        verify_file_begins_with="--",
        check_interval=86400,
        silent_updates=true,
    }

    -- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
    local status, auto_updater = pcall(require, "auto-updater")
    if not status then
        local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
        async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
            function(result, headers, status_code)
                local function parse_auto_update_result(result, headers, status_code)
                    local error_prefix = "Error downloading auto-updater: "
                    if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                    if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                    filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                    local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                    if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                    file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
                end
                auto_update_complete = parse_auto_update_result(result, headers, status_code)
            end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
        async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
        if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
        auto_updater = require("auto-updater")
    end
    if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end
    
    -- Run Auto Update
    auto_updater.run_auto_update({
        source_url="https://raw.githubusercontent.com/StealthyAD/SpotMusic/main/SpotMusic.lua",
        script_relpath=SCRIPT_RELPATH,
        verify_file_begins_with="--"
    })
    -- Manual Update
    menu.action(SpotRoot, "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
        auto_update_config.check_interval = 0
        if auto_updater.run_auto_update(auto_update_config) then
            util.toast("No updates found")
        end
    end)

    auto_updater.run_auto_update(auto_update_config)

--------------------------------
-- Translations Features
--------------------------------

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
            local supported_lang_table = {"fr", "de", "it", "es", "pt", "ru"}
            for _,tested_lang in pairs(supported_lang_table) do
                if tested_lang == user_lang then
                    supported_lang = true
                    return
                end
            end
            english = true
            util.toast("> SpotMusic\nSorry your language isn't supported. Script language set to English.")
        end
        SupportedLang()
    end

    local tr_table = {
        fr = { -- French Language (Français)
            ["Restart Script"] = "Redémarrer le Script",
            ["Main Menu"] = "Menu Principal",
            ["Open Music Folders"] = "Ouvrir le dossier Musique",
            ["Stop Music"] = "Arrêter la musique",
            ["Saved Playlists"] = "Playlists sauvegardés",
            ["Miscellaneous"] = "Divers Options",
            ["Restart instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Redémarre instantanément le script si il y'a des problèmes qui peuvent dégénérer.\nNOTE: Cela va couper instantanément la musique.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Modifier la disposition de votre musique et profitez-en au maximum.\nNOTE: vous devrez obligatoirement mettre sous forme de fichier .wav\nLes fichiers MP3 ou d'autres fichiers contenant des fichiers invalides ne seront pas acceptés.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Il arrêtera votre musique instantanément. \nNOTE : Ne supprimez pas le dossier appelé Stop Sounds, la musique ne s'arrêtera pas et sera mise en boucle. Ne renommez pas le fichier.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Avoir crée le lua Startup Sound et j'ai amélioré le lua pour créer des playlists et rendre plus facile.",
            ["Provides much features & essentials for Lua Scripts."] = "Fournit beaucoup de fonctionnalités et d'éléments essentiels pour les scripts Lua.",
            ["Provided for using GTAV natives."] = "Fourni en utilisant les natives.",
            ["Visit my GitHub Page"] = "Visite ma page GitHub",
            ["Join my TikTok"] = "Rejoins mon TikTok",
            ["> SpotMusic\nSelected Music: "] = "> SpotMusic\nMusique choisie: ",
            ["> SpotMusic\nMusic file does not exist:"] = "> SpotMusic\nLe fichier musical n'existe pas :",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTE : Vous devez obtenir le fichier, sinon vous ne pourrez pas arrêter le son.",
            ["> SpotMusic\nMusic stopped successfully."] = "> SpotMusic\nMusique arrêté avec succès.",
            ["Hello "] = "Bonjour ",
            ["\nWelcome to SpotMusic "] = "\nBienvenue sur le script SpotMusic ",
            ["Informations"] = "Informations",
            ["Credits"] = "Crédits",
            ["Resources"] = "Ressources",
            ["StealthyAD.#8293 (Developer SpotMusic)"] = "StealthyAD.#8293 (Développeur SpotMusic)",
            ["Version: "] = "Version: ",
            ["Menu Edition Stand: "] = "Edition du menu Stand: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "Attention: Dossier lourd, vérifiez que vous avez un gros stockage, en moyenne un fichier .wav est entre 25-50 Mo.",
            ["WAV Compress"] = "Compresseur WAV",
        },

        de = { -- German Language (Deutsch)
            ["Restart Script"] = "Neustart-Skript",
            ["Main Menu"] = "Hauptmenü",
            ["Open Music Folders"] = "Musikordner öffnen",
            ["Stop Music"] = "Musik anhalten",
            ["Saved Playlists"] = "Gespeicherte Playlists",
            ["Miscellaneous"] = "Diverse",
            ["Restart instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Starten Sie das Skript bei Problemen sofort neu.\nHinweis: Die Musik wird sofort abgeschaltet.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Bearbeiten Sie Ihre Musik und genießen Sie sie.\nHinweis: Sie müssen eine .wav-Datei einfügen.\nMP3 oder andere Dateien mit ungültigen Dateien werden nicht akzeptiert.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Die Musik wird sofort gestoppt. HINWEIS: Löschen Sie nicht den Ordner 'Stop Sounds', sonst wird die Musik nicht gestoppt und in einer Schleife abgespielt. Benennen Sie die Datei nicht um.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Erstellt Startup Sound und ich verbessere die Lua, um Playlists zu erstellen und einfacher zu machen.",
            ["Provides much features & essentials for Lua Scripts."] = "Bietet viele Funktionen und Grundlagen für Lua-Skripte.",
            ["Provided for using GTAV natives."] = "Vorgesehen für die Verwendung von GTAV-Eingeborenen.",
            ["Visit my GitHub Page"] = "Besuchen Sie meine Github-Seite",
            ["Join my TikTok"] = "Meinem TikTok beitreten",
            ["> SpotMusic\nSelected Music: "] = "> SpotMusic\nAusgewählte Musik: ",
            ["> SpotMusic\nMusic file does not exist:"] = "> SpotMusic\nDie Musikdatei existiert nicht:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nHinweis: Sie müssen die Datei erhalten, sonst können Sie den Ton nicht anhalten.",
            ["> SpotMusic\nMusic stopped successfully."] = "> SpotMusic\nWurde erfolgreich beendet.",
            ["Hello "] = "Guten Tag ",
            ["\nWelcome to SpotMusic "] = "\nWillkommen im script SpotMusic ",
            ["Informations"] = "Informationen",
            ["Credits"] = "Impressum",
            ["Resources"] = "Ressourcen",
            ["StealthyAD.#8293 (Developer SpotMusic)"] = "StealthyAD.#8293 (Entwickler SpotMusic)",
            ["Version: "] = "Version: ",
            ["Menu Edition Stand: "] = "Editionsmenü Stand: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "WARNUNG: Schwerer Ordner, also prüfen Sie, ob Sie viel Speicherplatz haben, mindestens eine durchschnittliche .wav-Datei: 25-100 MB.",
            ["WAV Compress"] = "WAV-Kompressor",
        },
        it = { -- Italian Language (Italiano)
            ["Restart Script"] = "Script di riavvio",
            ["Main Menu"] = "Menu principale",
            ["Open Music Folders"] = "Aprire le cartelle musicali",
            ["Stop Music"] = "Fermare la musica",
            ["Saved Playlists"] = "Playlist salvate",
            ["Miscellaneous"] = "Varie",
            ["Restart instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Riavviare immediatamente lo script in caso di problemi.\nNOTA: la musica si spegnerà immediatamente.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Modifica la tua musica e divertiti.\nNOTA: è necessario inserire un file .wav.\nNon sono accettati file .mp3 o altri file contenenti file non validi.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "La musica si interromperà all'istante.\nNOTA: non eliminare la cartella denominata Stop Sounds, la musica non si interromperà e rimarrà in loop. Non rinominare i file.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Creato Startup Sound e migliorato il lua per creare Playlist e rendere più facile.",
            ["Provides much features & essentials for Lua Scripts."] = "Fornisce molte funzioni ed elementi essenziali per gli script Lua.",
            ["Provided for using GTAV natives."] = "Fornito per l'utilizzo dei nativi di GTAV.",
            ["Visit my GitHub Page"] = "Visita la mia pagina GitHub",
            ["Join my TikTok"] = "Unisciti al mio TikTok",
            ["> SpotMusic\nSelected Music: "] = "> SpotMusic\nMusica selezionata:",
            ["> SpotMusic\nMusic file does not exist:"] = "> SpotMusic : Il file musicale non esiste:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTA: è necessario ottenere il file, altrimenti non è possibile interrompere il suono.",
            ["> SpotMusic\nMusic stopped successfully."] = "> SpotMusic\nSi è fermato correttamente.",
            ["Hello "] = "Ciao ",
            ["\nWelcome to SpotMusic "] = "\nBenvenuti a SpotMusic ",
            ["Informations"] = "Informazioni",
            ["Credits"] = "Crediti",
            ["Resources"] = "Risorse",
            ["StealthyAD.#8293 (Developer SpotMusic)"] = "StealthyAD.#8293 (Sviluppatore SpotMusic)",
            ["Version: "] = "Versione: ",
            ["Menu Edition Stand: "] = "Menu dell'edizione Stand: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "ADVERTENCIA: Carpeta pesada, así que compruebe si tiene gran almacenamiento, al menos archivo .wav promedio: 25-100 MB.",
            ["WAV Compress"] = "Compressore WAV",
        },

        es = { -- Spanish Language (Español)
            ["Restart Script"] = "Script de reinicio",
            ["Main Menu"] = "Menú principal",
            ["Open Music Folders"] = "Abrir carpetas de música",
            ["Stop Music"] = "Detener música",
            ["Saved Playlists"] = "Listas de reproducción guardadas",
            ["Miscellaneous"] = "Varios",
            ["Restart instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Reinicia instantáneamente el script si tienes algún problema.\nNOTA: Apagará instantáneamente la música.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Edita tu música y disfruta.\nNOTA: Necesitas poner archivo .wav.\nNo se aceptan MP3 u otros archivos que contengan archivos inválidos.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Detendrá tu música instantáneamente.\nNOTA: No borres la carpeta llamada Detener Sonidos, la música no se detendrá y se reproducirá en bucle. No cambies el nombre del archivo. Se detendrá la música al instante",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Creado Startup Sound y mejoro el lua para crear Listas de Reproducción y hacerlo más fácil.",
            ["Provides much features & essentials for Lua Scripts."] = "Proporciona muchas características y elementos esenciales para scripts Lua.",
            ["Provided for using GTAV natives."] = "Proporcionado para usar los nativos de GTAV",
            ["Visit my GitHub Page"] = "Visita mi página de GitHub",
            ["Join my TikTok"] = "Únete a mi TikTok",
            ["> SpotMusic\nSelected Music: "] = "> SpotMusic\nMúsica seleccionada: ",
            ["> SpotMusic\nMusic file does not exist:"] = "> SpotMusic\nEl archivo de música no existe:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTA: Es necesario obtener el archivo, de lo contrario no se puede detener el sonido.",
            ["> SpotMusic\nMusic stopped successfully."] = "> SpotMusic\nLa música se detuvo con éxito.",
            ["Hello "] = "Hola ",
            ["\nWelcome to SpotMusic "] = "\nBienvenido a SpotMusic ",
            ["Informations"] = "Información",
            ["Credits"] = "Créditos",
            ["Resources"] = "Recursos",
            ["StealthyAD.#8293 (Developer SpotMusic)"] = "StealthyAD.#8293 (Desarrollador SpotMusic)",
            ["Version: "] = "Versión: ",
            ["Menu Edition Stand: "] = "Menú Edición Stand: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "ADVERTENCIA: Carpeta pesada, así que compruebe si tiene gran almacenamiento, al menos archivo .wav promedio: 25-100 MB.",
            ["WAV Compress"] = "Compresor WAV",
        },
        pt = { -- Portuguese/Brazil Language (Português)
            ["Restart Script"] = "Reiniciar o Roteiro",
            ["Main Menu"] = "Menu principal",
            ["Open Music Folders"] = "Pastas de Música Abertas",
            ["Stop Music"] = "Parar a música",
            ["Saved Playlists"] = "Listas de Reprodução Guardadas",
            ["Miscellaneous"] = "Miscelânea",
            ["Restart instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Reinicie instantaneamente o guião se tiver algum problema.\nNOTE: Irá encerrar instantaneamente a música",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Edite a sua música e desfrute.\nNOTE: É necessário colocar ficheiro .wav.\nMP3 ou outro ficheiro contendo ficheiros inválidos não são aceites.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Não apague a pasta chamada Stop Sounds, a música não pára e faz um looping. Não renomeie o ficheiro.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Criei o Startup Sound e melhorei a lua para criar listas de reprodução e tornar mais fácil.",
            ["Provides much features & essentials for Lua Scripts."] = "Fornece muitas características & essências para Lua Scripts.",
            ["Provided for using GTAV natives."] = "Fornecido para a utilização de nativos de GTAV.",
            ["Visit my GitHub Page"] = "Visite a minha página GitHub",
            ["Join my TikTok"] = "Junte-se ao meu TikTok",
            ["> SpotMusic\nSelected Music: "] = "> SpotMusic\nMúsica seleccionada: ",
            ["> SpotMusic\nMusic file does not exist:"] = "> SpotMusic\nFicheiro de música não existe:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTA: É necessário obter o ficheiro, caso contrário não se pode parar o som.",
            ["> SpotMusic\nMusic stopped successfully."] = "> SpotMusic\nA música parou com sucesso.",
            ["Hello "] = "Olá ",
            ["\nWelcome to SpotMusic "] = "\nBem-vindo ao SpotMusic ",
            ["Informations"] = "Informações",
            ["Credits"] = "Créditos",
            ["Resources"] = "Recursos",
            ["StealthyAD.#8293 (Developer SpotMusic)"] = "StealthyAD.#8293 (Desenvolvedor SpotMusic)",
            ["Version: "] = "Versão: ",
            ["Menu Edition Stand: "] = "Menu Edição Stand: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "ADVERTÊNCIA: pasta pesada, por isso verifique se tem um grande armazenamento, pelo menos um ficheiro .wav médio: 25-100 MB.",
            ["WAV Compress"] = "Compressor WAV",
        },
        ru = { -- Russian Language (русский)
            ["Restart Script"] = "Сценарий перезапуска",
            ["Main Menu"] = "Главное меню",
            ["Open Music Folders"] = "Открыть папки с музыкой",
            ["Stop Music"] = "Остановить музыку",
            ["Saved Playlists"] = "Сохраненные плейлисты",
            ["Miscellaneous"] = "Разное",
            ["Restart instantly the script if have any problems.\nNOTE: It will Instantly shut down music."] = "Перезапустите скрипт, если возникнут проблемы.\nNOTE: Он мгновенно выключит музыку.",
            ["Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."] = "Редактируйте музыку и наслаждайтесь.\nNOTE: Вам нужно вставить .wav файл.\nMP3 или другие файлы, содержащие недействительный файл, не принимаются.",
            ["It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."] = "Это мгновенно остановит вашу музыку.\nNOTE: Не удаляйте папку под названием Stop Sounds, музыка не остановится и зациклится. Не переименовывайте файл.",
            ["Created Startup Sound and I improve the lua to create Playlists and make easier."] = "Создал Startup Sound и улучшаю lua, чтобы создавать плейлисты и сделать проще.",
            ["Provides much features & essentials for Lua Scripts."] = "Предоставляет много возможностей и основ для Lua скриптов.",
            ["Provided for using GTAV natives."] = "Обеспечивает использование GTAV natives.",
            ["Visit my GitHub Page"] = "Посетите мою страницу на GitHub",
            ["Join my TikTok"] = "Присоединяйтесь к моему TikTok",
            ["> SpotMusic\nSelected Music: "] = "> SpotMusic\nВыбранная музыка: ",
            ["> SpotMusic\nMusic file does not exist:"] = "> SpotMusic\nМузыкальный файл не существует:",
            ["\n\nNOTE: You need to get the file, otherwise you can't stop the sound."] = "\n\nNOTE: Вам нужно получить файл, иначе вы не сможете остановить звук.",
            ["> SpotMusic\nMusic stopped successfully."] = "> SpotMusic\nМузыка успешно остановлена.",
            ["Hello "] = "Привет ",
            ["\nWelcome to SpotMusic "] = "\nДобро пожаловать в SpotMusic ",
            ["Informations"] = "Информация",
            ["Credits"] = "Кредиты",
            ["Resources"] = "Ресурсы",
            ["StealthyAD.#8293 (Developer SpotMusic)"] = "StealthyAD.#8293 (Разрабо SpotMusic)",
            ["Version: "] = "Версия: ",
            ["Menu Edition Stand: "] = "Меню издания Stand: ",
            ["WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."] = "ВНИМАНИЕ: тяжелая папка, поэтому проверьте, есть ли у вас большой объем памяти, по крайней мере, средний .wav файл: 25-100 МБ.",
            ["WAV Compress"] = "WAV-компрессор"
        }
    }

    ForceTranslate = function(str)
        if not english then
            local forcetranslate_str = tr_table[user_lang][str]
            if forcetranslate_str == nil or forcetranslate_str == "" then
                util.toast("> SpotMusic (translation missing) : '"..str.."'",TOAST_CONSOLE)
            else
                return forcetranslate_str
            end
        end
        return str
    end

--------------------------------
-- Main Menu Features
--------------------------------

    local sound_handle = nil

    SpotRoot:action(ForceTranslate("Restart Script"), {'spotrestart'}, ForceTranslate("Restart instantly the script if have any problems.\nNOTE: It will Instantly shut down music."), function()
        sound_handle = aalib.play_sound(join_path(script_store_dir_stop, "stop.wav"), SND_FILENAME | SND_ASYNC)
        util.restart_script()
    end)

    SpotRoot:divider(ForceTranslate("Main Menu"))
    SpotRoot:hyperlink(ForceTranslate("WAV Compress"), "https://www.freeconvert.com/wav-compressor")
    SpotRoot:hyperlink(ForceTranslate("Open Music Folders"), "file://"..script_store_dir, ForceTranslate("Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."))

    --------------------------------
    -- Stop Sounds
    --------------------------------

    SpotRoot:action(ForceTranslate("Stop Music"), {'spotstopmusic'}, ForceTranslate("It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."), function(selected_index)
        local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
        if not filesystem.exists(sound_location_1) then
            util.toast(ForceTranslate("> SpotMusic\nMusic file does not exist: ") .. sound_location_1.. ForceTranslate("\n\nNOTE: You need to get the file, otherwise you can't stop the sound."))
        else
            sound_handle = aalib.play_sound(sound_location_1, SND_FILENAME | SND_ASYNC)
            if SpotFiles and SpotFiles ~= "" then -- check if SpotFiles is not nil or empty
                util.toast(ForceTranslate('> SpotMusic\nMusic stopped successfully.'))
            end
        end
    end)

    --------------------------------
    -- Saved Playlists
    --------------------------------

    local songs_direct = join_path(script_store_dir, "")
    local songs = SpotLoading(songs_direct)
    
    local SpotMusicList = SpotRoot:list_action(ForceTranslate("Saved Playlists"), {}, ForceTranslate("WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB."), SpotFiles, function(selected_index)
        local selected_file = SpotFiles[selected_index]
        local sound_location = join_path(script_store_dir, selected_file)
        if not filesystem.exists(sound_location) then
            util.toast("> SpotMusic : Sound file does not exist: " .. sound_location)
        else
            local display_text = string.gsub(string.gsub(selected_file, "%.wav$", ""), "%.WAV$", "")
            SpotPlaySound(sound_location, SND_FILENAME | SND_ASYNC)
            util.toast(ForceTranslate("> SpotMusic\nSelected Music: ") .. display_text)
        end
    end)

    --------------------------------
    -- Execution File Looped
    --------------------------------

    util.create_thread(function()
        while true do
            UpdateAutoMusics()
            menu.set_list_action_options(SpotMusicList, SpotFiles)
            util.yield(5000)
        end
    end)

    if not SCRIPT_SILENT_START then
        util.toast(ForceTranslate("Hello ").. players.get_name(players.user()).. ForceTranslate("\nWelcome to SpotMusic ") ..SCRIPT_VERSION)
    end

    --------------------------------
    -- Credits & GitHub
    --------------------------------

    local SpotMiscs = SpotRoot:list(ForceTranslate("Miscellaneous"))
    ----------------
    -- Informations
    ----------------

        SpotMiscs:divider(ForceTranslate("Informations"))
        SpotMiscs:action(ForceTranslate("Version: ") ..SCRIPT_VERSION, {}, "", function()end)
        SpotMiscs:action(ForceTranslate("Menu Edition Stand: ") ..edition_menu, {}, "", function()end)

    -------------
    -- Credits
    -------------

        SpotMiscs:divider(ForceTranslate("Credits"))
        local SpotStealthy = SpotMiscs:list(ForceTranslate("StealthyAD.#8293 (Developer SpotMusic)"))
        SpotStealthy:hyperlink(ForceTranslate("Visit my GitHub Page"), "https://github.com/StealthyAD/SpotMusic")
        SpotStealthy:hyperlink(ForceTranslate("Join my TikTok"), "https://www.tiktok.com/@xstealthyhd")
        SpotMiscs:action("Lance", {}, ForceTranslate("Created Startup Sound and I improve the lua to create Playlists and make easier."), function()end)
    
    -------------
    -- Resources
    -------------

        SpotMiscs:divider(ForceTranslate("Resources"))
        SpotMiscs:hyperlink("Stand API", "https://stand.gg/help/lua-api-documentation", ForceTranslate("Provides much features & essentials for Lua Scripts."))
        SpotMiscs:hyperlink("NativeDB", "https://nativedb.dotindustries.dev/natives", ForceTranslate("Provided for using GTAV natives."))
