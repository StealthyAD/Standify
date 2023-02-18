-------------------------------
---      SpotMusic by
---       StealthyAD
---    For Stand Mod Menu
-------------------------------

-------------------
-- Core Functions
-------------------

local aalib = require("aalib")
local SpotPlaySound = aalib.play_sound
local SND_ASYNC<const> = 0x0001
local SND_FILENAME<const> = 0x00020000
local version = "0.13"

util.require_natives(1663599433)
util.keep_running()

--------------------------------
-- Root Parts
--------------------------------

    local SpotRoot = menu.my_root()

--------------------------------
-- File Storage Direction
--------------------------------

local script_store_dir = filesystem.store_dir() .. SCRIPT_NAME .. '/songs'
if not filesystem.is_dir(script_store_dir) then
    filesystem.mkdirs(script_store_dir)
end

local script_store_dir_stop = filesystem.store_dir() .. SCRIPT_NAME .. '/stop_sounds'
if not filesystem.is_dir(script_store_dir_stop) then
    filesystem.mkdirs(script_store_dir_stop)
end

--------------------------------
-- Function Execution Important
--------------------------------

    if not filesystem.is_dir(script_store_dir) then
        util.toast("SpotMusic Files are not installed.")
    end

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
-- Main Menu Features
--------------------------------

    local sound_handle = nil

    SpotRoot:action("Restart Script", {'spotrestart'}, "Restart instantly the script if have any problems.\nNOTE: It will Instantly shut down music.", function()
        sound_handle = aalib.play_sound(join_path(script_store_dir_stop, "stop.wav"), SND_FILENAME | SND_ASYNC)
        util.restart_script()
    end)

    SpotRoot:divider("Main Menu")
    SpotRoot:hyperlink("Open Music Folders", "file://"..script_store_dir, "Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted.")

    --------------------------------
    -- Stop Sounds
    --------------------------------

    SpotRoot:action("Stop Music", {'spotstopmusic'}, "It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file.", function(selected_index)
        local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
        if not filesystem.exists(sound_location_1) then
            util.toast("> SpotMusic : Sound file does not exist: " .. sound_location_1.."\n\nNOTE: You need to get the file, otherwise you can't stop the sound.")
        else
            sound_handle = aalib.play_sound(sound_location_1, SND_FILENAME | SND_ASYNC)
            if SpotFiles and SpotFiles ~= "" then -- check if SpotFiles is not nil or empty
                util.toast('> SpotMusic\nMusic stopped.')
            end
        end
    end)

    --------------------------------
    -- Saved Playlists
    --------------------------------

    local songs_direct = join_path(script_store_dir, "")
    local songs = SpotLoading(songs_direct)
    
    local MusicAdding = SpotRoot:list_action("Saved Playlists", {}, "", SpotFiles, function(selected_index)
        local selected_file = SpotFiles[selected_index]
        local sound_location = join_path(script_store_dir, selected_file)
        if not filesystem.exists(sound_location) then
            util.toast("> SpotMusic : Sound file does not exist: " .. sound_location)
        else
            local display_text = string.gsub(string.gsub(selected_file, "%.wav$", ""), "%.WAV$", "")
            SpotPlaySound(sound_location, SND_FILENAME | SND_ASYNC)
            util.toast("> SpotMusic\nMusic choosen: " .. display_text)
        end
    end)

    --------------------------------
    -- Execution File Looped
    --------------------------------

    util.create_thread(function()
        while true do
            UpdateAutoMusics()
            menu.set_list_action_options(MusicAdding, SpotFiles)
            util.yield(5000)
        end
    end)

    if not SCRIPT_SILENT_START then
        util.toast("Hello ".. players.get_name(players.user()).. "\nWelcome to SpotMusic " ..version)
    end

    if SCRIPT_SILENT_STOP then
        util.toast("> SpotMusic\n\nThank you for using the script and enjoy for the last feature v"..version)
    end

    --------------------------------
    -- Credits & GitHub
    --------------------------------

    local SpotMiscs = SpotRoot:list("Miscellaneous")
    ----------------
    -- Informations
    ----------------

        SpotMiscs:divider("Informations")
        SpotMiscs:action("Version: " ..version, {}, "", function()end)
        SpotMiscs:hyperlink("Github Link", "https://github.com/StealthyAD/SpotMusic")

    -------------
    -- Credits
    -------------

        SpotMiscs:divider("Credits")
        SpotMiscs:action("StealthyAD.#8293 (Developer SpotMusic)", {}, "", function()end)
        SpotMiscs:action("Lance", {}, "Created Startup Sound and I improve the lua to create Playlists and make easier.", function()end)
    
    -------------
    -- Resources
    -------------

        SpotMiscs:divider("Resources")
        SpotMiscs:hyperlink("Stand API", "https://stand.gg/help/lua-api-documentation", "Provides much features & essentials for Lua Scripts.")
        SpotMiscs:hyperlink("NativeDB", "https://nativedb.dotindustries.dev/natives", "Provided for natives.")
