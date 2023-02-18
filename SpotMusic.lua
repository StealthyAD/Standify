-------------------------------
---      SpotMusic by
---       StealthyAD
---    For Stand Mod Menu
-------------------------------

-------------------
-- Core Functions
-------------------

local aalib = require("aalib")
local PlaySound = aalib.play_sound
local SND_ASYNC<const> = 0x0001
local SND_FILENAME<const> = 0x00020000
local version = "0.12"

util.require_natives(1663599433)
util.keep_running()

--------------------------------
-- Root Parts
--------------------------------

    local SpotRoot = menu.my_root()

--------------------------------
-- File Storage Direction
--------------------------------

local script_store_dir = filesystem.store_dir() .. SCRIPT_NAME .. '\\songs'
if not filesystem.is_dir(script_store_dir) then
    filesystem.mkdirs(script_store_dir)
end

local script_store_dir_stop = filesystem.store_dir() .. SCRIPT_NAME .. '\\stop_sounds'
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

    local Music_Files = {}
        function update_all_music_files()
            Music_TempFiles = {}
            for i, path in ipairs(filesystem.list_files(script_store_dir)) do
                local file_str = path:gsub(script_store_dir, '')
                if ends_with(file_str, '.wav') then
                    Music_TempFiles[#Music_TempFiles+1] = file_str
                end
            end
            Music_Files = Music_TempFiles
        end
        update_all_music_files()

    local function join_path(parent, child)
        local sub = parent:sub(-1)
        if sub == "/" or sub == "\\" then
            return parent .. child
        else
            return parent .. "/" .. child
        end
    end

    local function load_songs(directory)
        local loaded_songs = {}
        for _, filepath in ipairs(filesystem.list_files(directory)) do
            local _, filename, ext = string.match(filepath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
            if not filesystem.is_dir(script_store_dir) and ext == "wav" then
                local sound_location = join_path(script_store_dir, filename)
                loaded_songs[#loaded_songs + 1] = {file=filename, sound=aalib.play_sound(sound_location, SND_FILENAME | SND_ASYNC)}
            end
        end
        return loaded_songs
    end

--------------------------------
-- Main Menu Features
--------------------------------

    SpotRoot:action("Restart Script", {'spotrestart'}, "", function()
        util.restart_script()
    end)
    SpotRoot:divider("Main Menu")
    SpotRoot:hyperlink("Open Music Folders", "file://"..script_store_dir, "Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted.")

    --------------------------------
    -- Stop Sounds
    --------------------------------

    local sound_handle = nil

    SpotRoot:action("Stop Music", {'spotstopmusic'}, "It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file.", function()
        local sound_location = join_path(script_store_dir_stop, "stop.wav")
        if not filesystem.exists(sound_location) then
            util.toast("[SpotMusic] : Sound file does not exist: " .. sound_location)
        else
        sound_handle = aalib.play_sound(sound_location, SND_FILENAME | SND_ASYNC)
        if sound_handle ~= nil then
            aalib.stop_sound(sound_handle)
            sound_handle = nil
            end
        end
    end)

    --------------------------------
    -- Saved Playlists
    --------------------------------

    local songs_direct = join_path(script_store_dir, "")
    local songs = load_songs(songs_direct)
    
    local MusicAdding = SpotRoot:list_action("Saved Playlists", {}, "", Music_Files, function(selected_index)
        local selected_file = Music_Files[selected_index]
        local sound_location = join_path(script_store_dir, selected_file)
        if not filesystem.exists(sound_location) then
            util.toast("Sound file does not exist: " .. sound_location)
        else
            PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
        end
    end)

    --------------------------------
    -- Execution File Looped
    --------------------------------

    util.create_thread(function()
        while true do
            update_all_music_files()
            menu.set_list_action_options(MusicAdding, Music_Files)
            util.yield(5000)
        end
    end)

    if not SCRIPT_SILENT_START then
        util.toast("Hello ".. players.get_name(players.user()).. "\nWelcome to SpotMusic.")
    end

    --------------------------------
    -- Credits & GitHub
    --------------------------------

    local SpotCreditsAndMiscs = SpotRoot:list("Miscs")
    SpotCreditsAndMiscs:action("Version: " ..version, {}, "", function()end)
    SpotCreditsAndMiscs:hyperlink("Github Link", "https://github.com/StealthyAD/SpotMusic")
    SpotCreditsAndMiscs:divider("Credits")
    
    SpotCreditsAndMiscs:action("StealthyAD. (Developer SpotMusic)", {}, "", function()end)
    SpotCreditsAndMiscs:action("Lance", {}, "Created Startup Sound but improving the lua to create Playlists", function()end)
