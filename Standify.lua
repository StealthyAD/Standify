--[[

    Standify for Stand by StealthyAD.
    Based on Startup Sounds by Lance

    "Portable Spotify Stand and listen."

    INTRODUCION: 
    Standify can use wav files which you can import each favorite music, 
    Inspired X-Force features and Lance's Startup Sounds which we can
    upload own musics  but Stand don't have these features so I decided 
    to create and using some luas script to support.

    Features:
    - Compatible All Stand Versions.
    - Multi Language Included (English (default), French, Spanish, German and Russian)
    - .wav file compatible music features.

]]--

    ----======================================----
    ---             Core Functions
    --- The most essential part of Lua Script.
    ----======================================----

        local aalib = require("aalib")
        local StandifyPlaySound = aalib.play_sound
        local SND_ASYNC<const> = 0x0001
        local SND_FILENAME<const> = 0x00020000
        local StandifyVersion = "0.22"
        local StandifyMSG = "> Standify "..StandifyVersion

        util.keep_running()

    ----=====================================----
    ---        Core/Variables Functions
    --- Defined where the function is located
    ----=====================================----

        local StandifyRoot = menu.my_root()
        local StandifyYield = util.yield
        local StandifyToast = util.toast

        local StandNotify = function(str) if ToggleNotify then if NotifMode == 2 then util.show_corner_help("~o~"..StandifyMSG.."~s~~n~"..str ) else StandifyToast(StandifyMSG.."\n"..str) end end end  -- credit to akatozi

        local ScriptDir <const> = filesystem.scripts_dir()
        local required_files <const> = {
            "lib\\Standify\\Translations.lua",
        }

        for _, file in pairs(required_files) do
            local file_path = ScriptDir .. file
            if not filesystem.exists(file_path) then
                StandNotify("Sorry, you missed these documents:" .. file_path, TOAST_ALL)
            end
        end

        local trans = require "Standify.Translations"

    ----=======================================----
    ---               File Directory
    --- Locate songs.wav and stop music easily.
    ----=======================================----

        local script_store_dir = filesystem.store_dir() .. SCRIPT_NAME -- Redirects to %appdata%\Stand\Lua Scripts\store\Standify
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

        local played_songs = {} 
        local song_files = filesystem.list_files(script_store_dir)
        local last_auto_time = 0
        local max_selection_attempts = 100
        
        local function StandifyAuto()
            local current_time = os.time()
            local remaining_time = menu.get_value(StandifyCooldown) - (current_time - last_auto_time)
            if remaining_time <= 0 then
                last_auto_time = current_time
                if song_files and #song_files > 0 then
                    local song_path
                    local selection_attempts = 0
                    repeat 
                        song_path = song_files[math.random(#song_files)]
                        selection_attempts = selection_attempts + 1
                    until not played_songs[song_path] or selection_attempts >= max_selection_attempts
                    if not played_songs[song_path] then
                        played_songs[song_path] = true 
                        AutoPlay(song_path)
                        local song_title = string.match(song_path, ".+\\([^%.]+)%.%w+$")
                        if song_title then
                            StandNotify("\n"..FT("Random music selected: ") .. song_title)
                        end
                    else
                        StandNotify("\n"..FT("All songs have been played."))
                    end
                end
            else
                local remaining_minutes = math.floor(remaining_time / 60)
                local remaining_seconds = remaining_time % 60
                local remaining_time_string = ""
                if remaining_minutes > 0 then
                    remaining_time_string = remaining_time_string .. remaining_minutes .. " " .. (remaining_minutes > 1 and FT("minutes") or FT("minute")) .. " "
                    if remaining_seconds > 0 then
                        remaining_time_string = remaining_time_string .. FT("and ")
                    end
                end
                if remaining_seconds > 0 then 
                    remaining_time_string = remaining_time_string .. remaining_seconds .. " " .. (remaining_seconds > 1 and FT("seconds") or FT("second"))
                end
                StandNotify("\n"..FT("Please wait ") .. remaining_time_string .. FT(" before playing another song."))
            end
        end

        local function StandifyPlay(sound_location)
            if current_sound_handle then
                current_sound_handle = nil
            end
            current_sound_handle = StandifyPlaySound(sound_location, SND_FILENAME | SND_ASYNC)
        end

        local added_files = {}
        local songs_direct = join_path(script_store_dir, "")
        local StandifyLoadedSongs = StandifyLoading(songs_direct)

        local function CheckSongs() -- Verify if the .wav is in Standify Folder (songs)
            local new_song_files = filesystem.list_files(script_store_dir)
            for _, song_path in ipairs(new_song_files) do
                if not song_files[song_path] and string.match(song_path, "%.wav$") then
                    StandifyLoadedSongs = StandifyLoading(songs_direct)
                    StandifyFiles = {}
                    for _, song in ipairs(StandifyLoadedSongs) do
                        StandifyFiles[#StandifyFiles + 1] = song.file
                        song_files[song.file] = true
                    end
                    break
                end
            end
        end

        local function check_music_folder()
            local StandifyFiles = {}
            for _, song in ipairs(StandifyLoadedSongs) do
                StandifyFiles[#StandifyFiles + 1] = song.file
                song_files[song.file] = true
            end
            local current_files = {}
            for i, path in ipairs(filesystem.list_files(script_store_dir)) do
                local file_str = path:gsub(script_store_dir, ''):gsub("\\","")
                if ends_with(file_str, '.wav') and not song_files[file_str] then
                    current_files[#current_files+1] = file_str
                end
            end
            
            -- Check for removed files
            for i, file in ipairs(StandifyFiles) do
                local sound_location = join_path(script_store_dir, file .. ".wav")
                if not filesystem.exists(sound_location) then
                    for j, song in ipairs(StandifyLoadedSongs) do
                        if song.file == file then
                            table.remove(StandifyLoadedSongs, j)
                            StandNotify("\n"..FT("Removed Music: ") .. file .. "\n"..FT("Each time you delete music, we advise you to refresh the music using 'Refresh Musics'."))
                            break
                        end
                    end
                    table.remove(StandifyFiles, i)
                    song_files = {}
                    for _, name in ipairs(StandifyFiles) do
                        song_files[name .. ".wav"] = true
                    end
                end
            end
            
            -- Check for new files
            for _, file in ipairs(current_files) do
                if not song_files[file] and not added_files[file] then
                    local sound_location = join_path(script_store_dir, file)
                    if filesystem.exists(sound_location) then
                        local file_name = string.gsub(file, "%.wav$", "")
                        local song_found = false
                        for _, song in ipairs(StandifyLoadedSongs) do
                            if song.file == file_name then
                                song_found = true
                                break
                            end
                        end
                        if not song_found then
                            StandifyLoadedSongs[#StandifyLoadedSongs + 1] = {file=file_name, sound=sound_location}
                            StandifyFiles[#StandifyFiles + 1] = file_name
                            song_files[file] = true
                            added_files[file] = true
                            StandNotify("\n"..FT("New Music Added: ") .. file_name.. "\n"..FT("Each time you add music, we advise you to refresh the music using 'Refresh Musics'."))
                        end
                    end
                end
            end
        end

    ----=============================================----
    ---                Updates Features
    --- Update manually/automatically the Lua Scripts
    ----=============================================----

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

        local default_check_interval = 604800
        local auto_update_config = {
            source_url="https://raw.githubusercontent.com/StealthyAD/Standify/main/Standify.lua",
            script_relpath=SCRIPT_RELPATH,
            switch_to_branch=selected_branch,
            verify_file_begins_with="--",
            check_interval=86400,
            silent_updates=true,
            dependencies={
                {
                    name="translations",
                    source_url="https://raw.githubusercontent.com/StealthyAD/Standify/main/lib/Standify/Translations.lua",
                    script_relpath="lib/Standify/Translations.lua",
                    check_interval=default_check_interval,
                },
            }
        }

        auto_updater.run_auto_update(auto_update_config)

    ----=============================================================----
    ---                     Translation Features
    ---     Translate Easier the language based on your language game
    ---    (credits to akatozi, so I would really need to get translator)
    ----=================================================================----

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
                StandifyToast(StandifyMSG.. "\nSorry your language isn't supported. Script language set to English.")
            end
            SupportedLang()
        end

        FT = function(str)
            if not english then
                local FT_str = trans.tr_table[user_lang][str]
                if FT_str == nil or FT_str == "" then
                    StandifyToast(StandifyMSG.. " (translation missing) : '"..str.."'",TOAST_CONSOLE)
                else
                    return FT_str
                end
            end
            return str
        end

    ----============================================================================----
    ---                       Load Musics + Random Music
    ---    All of your musics stored on %appdata%\Stand\Lua Scripts\Standify\songs\
    ----============================================================================----

        local StandifyList = StandifyRoot:list(FT("Load Musics"))
        local StandifyOptions = StandifyList:list(FT("Options"))
        StandifyList:action(FT("Open Music Folders"), {}, FT("Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted."), function()
            util.open_folder(script_store_dir)
        end)

        StandifyList:action(FT("Play Random Music"), {'standifyrandom'}, FT("Play a random music."), function()
            StandifyAuto()
        end)

        StandifyCooldown = StandifyOptions:slider(FT("Cooldown Random Music"), {"standifycrm"}, FT("Each interval has a specific time, do not spam like crazy and calm down."), 30, 300, 30, 1, function()end)

        local links = {
            {"WAV Compressor", "https://www.freeconvert.com/wav-compressor"},
            {"xconvert", "https://www.xconvert.com/compress-wav"},
            {"youcompress", "https://www.youcompress.com/wav/"},
            {"YouTube WAV Converter", "https://www.ukc.com.np/p/youtube-wav.html"},
            {"WAV Converter", "https://www.freeconvert.com/wav-converter"},
            {"cloudconvert", "https://cloudconvert.com/wav-converter"},
            {"online-convert", "https://audio.online-convert.com/convert-to-wav"},
            {"online-audio-converter", "https://online-audio-converter.com/"}
        }
        
        local StandifyConprVerter = StandifyOptions:list(FT("WAV Compress & Converter"))
        StandifyConprVerter:divider(FT("Compressor")) for i = 1, 3 do StandifyConprVerter:hyperlink(links[i][1], links[i][2]) end
        StandifyConprVerter:divider(FT("Converter")) for i = 4, #links do StandifyConprVerter:hyperlink(links[i][1], links[i][2]) end
        
        StandifyList:action(FT("Refresh Musics"), {}, "", function()
            local countDown = 3000
            while countDown > 0 do
                local seconds = math.ceil(countDown / 1000)
                local secondsString = FT("seconds")
                if seconds == 1 then
                    secondsString = FT("second")
                end
                StandNotify(FT("Refreshing music in ") .. seconds .. " " .. secondsString .. "...")
                util.yield(1000) 
                countDown = countDown - 1000 
            end
            util.restart_script()
            StandNotify(FT("Refresh music complete."))
        end)        
        
        StandifyList:divider(FT("Browse Musics"))

        local StandifyLoadedSongs = StandifyLoading(songs_direct)
        local StandifyFiles = {}
        for _, song in ipairs(StandifyLoadedSongs) do
            StandifyFiles[#StandifyFiles + 1] = song.file
            song_files[song.file] = true
        end

        for i, file in ipairs(StandifyFiles) do
            local display_text = string.gsub(file, "%.wav$", "")
            StandifyList:action(FT("Play ") .. display_text, {"play"..display_text}, FT("Play the music: ")..display_text, function()
                for _, song in ipairs(StandifyLoadedSongs) do
                    if song.file == file then
                        local sound_location = song.sound
                        if not filesystem.exists(sound_location) then
                            local sound_file = string.match(sound_location, "[^/\\]+$")
                            local sound_file_name = string.gsub(sound_file, "%.wav$", "")
                            StandNotify("\n"..FT("Sound file does not exist: ") .. sound_file_name .."\n"..FT("Please try to start the music again later."))
                            local stopsound = join_path(script_store_dir_stop, "stop.wav")
                            StandifyPlaySound(stopsound, SND_FILENAME | SND_ASYNC)
                        else
                            StandifyPlay(sound_location)
                            StandNotify("\n"..FT("Selected Music: ") .. display_text)
                        end
                        break
                    end
                end
            end)
        end

    ----================================================----
    ---               Stop Sounds
    ---     Automatically end the musics while playing.
    ----================================================----

        StandifyRoot:action(FT("Stop Music"), {'standifystop'}, FT("It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file."), function(selected_index) -- Force automatically stop your musics
            local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
            if not filesystem.exists(sound_location_1) then
                StandNotify("\n"..FT("Music file does not exist: ") .. sound_location_1.."\n\n".. FT("NOTE: You need to get the file, otherwise you can't stop the sound."))
            else
                StandifyPlaySound(sound_location_1, SND_FILENAME | SND_ASYNC)
            end
        end)

    ----================================================----
    ---               Loop Features
    ---        Useful features to refresh Musics
    ----================================================----

        util.create_thread(function()
            while true do
                UpdateAutoMusics()
                check_music_folder()
                CheckSongs()
                StandifyYield(250)
            end
        end)

        util.on_stop(function()
            local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
            StandifyPlaySound(sound_location_1, SND_FILENAME | SND_ASYNC)
        end)

    ----=====================================================----
    ---               Credits/GitHub Page & Updates
    ---        Script Meta for checking credits/page/updates
    ----=====================================================----

        local StandifySettings = StandifyRoot:list(FT("Settings"))

        StandifySettings:divider(FT("Informations"))
        StandifySettings:readonly(FT("Script Version"), StandifyVersion)

        NotifMode = "Stand"
        StandifySettings:list_select(FT("Notify Message"), {}, "", {"Stand", "Help Message"}, 1, function(selected_mode)
            NotifMode = selected_mode
        end)

        ToggleNotify = true
        StandifySettings:toggle(FT("Toggle Notify"), {}, "", function(on)
            util.yield()
            ToggleNotify = on
        end, true)

        StandifySettings:action(FT("Changelog"), {}, "", function()
            async_http.init("raw.githubusercontent.com","/StealthyAD/stand-Standify/main/Changelog",function(content)
                if content ~= "404: Not Found" then
                    local changelog = string.gsub(content, "\n$", "")
                        StandNotify("\n"..changelog)
                end
            end)
            async_http.dispatch()
        end)

        StandifySettings:divider(FT("Credits"))
        StandifySettings:hyperlink("StealthyAD.", "https://github.com/StealthyAD")

        StandifySettings:divider(FT("Resources & Updates"))

	    StandifySettings:hyperlink(FT("GitHub Source"), "https://github.com/StealthyAD/Standify")
	    StandifySettings:action(FT("Check for Updates"), {}, FT("The script will automatically check for updates at most daily, but you can manually check using this option anytime."), function()
        auto_update_config.check_interval = 0
            if auto_updater.run_auto_update(auto_update_config) then
                StandNotify("\n"..FT("No updates found."))
            end
        end)

        StandifySettings:action(FT("Clean Reinstall"), {}, FT("Force an update to the latest version, regardless of current version."), function()
            auto_update_config.clean_reinstall = true
            auto_updater.run_auto_update(auto_update_config)
        end)
