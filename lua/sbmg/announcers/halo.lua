ANNOUNCER.PrintName = "#sbmg.announcers.halo"
ANNOUNCER.Description = "#sbmg.announcers.halo.desc"

ANNOUNCER.SortOrder = 1

ANNOUNCER.GenericLines = {
    Start = false,

    Win = "sbmg_vo/halo/h3/general/game_over[game_over].wav",
    Lose = "sbmg_vo/halo/h3/general/game_over[game_over].wav",
    Tie = "sbmg_vo/halo/h3/general/game_over[game_over].wav",

    EndCountdown = { -- Number index indicates the seconds left
        [1800] = "sbmg_vo/halo/h3/general/thirty_mins_remaining[thirty_mins_remaining].wav",
        [900] = "sbmg_vo/halo/h3/general/fifteen_mins_remaining[fifteen_mins_remaining].wav",
        [300] = "sbmg_vo/halo/h3/general/five_mins_remaining[five_mins_remaining].wav",
        [60] = "sbmg_vo/halo/h3/general/one_min_remaining[one_min_remaining].wav",
        [30] = "sbmg_vo/halo/h3/general/thirty_secs_remaining[thirty_secs_remaining].wav",
        [10] = "sbmg_vo/halo/h3/general/ten_secs_remaining[ten_secs_remaining].wav",
    }
}

ANNOUNCER.MinigameLines = {
    ctf = {
        Start = "sbmg_vo/halo/h3/capture_the_flag/capture_the_flag[capture_the_flag].wav",
        OurFlagTaken = "sbmg_vo/halo/h3/capture_the_flag/flag_stolen[flag_stolen].wav",
        OurFlagDropped = "sbmg_vo/halo/h3/capture_the_flag/flag_dropped[flag_dropped].wav",
        OurFlagCaptured = "sbmg_vo/halo/h3/capture_the_flag/flag_captured[flag_captured].wav",
        OurFlagReturned = "sbmg_vo/halo/h3/capture_the_flag/flag_recovered[flag_recovered].wav",
        TheirFlagTaken = "sbmg_vo/halo/h3/capture_the_flag/flag_taken[flag_taken].wav",
        TheirFlagDropped = "sbmg_vo/halo/h3/capture_the_flag/flag_dropped[flag_dropped].wav",
        TheirFlagCaptured = "sbmg_vo/halo/h3/capture_the_flag/flag_captured[flag_captured].wav",
        TheirFlagReturned = "sbmg_vo/halo/h3/capture_the_flag/flag_recovered[flag_recovered].wav",
    },
    ad = {
        Start = false,
        StartAttack = "vo/announcer_attack_controlpoints.mp3",
        StartDefend = "vo/announcer_defend_controlpoints.mp3",
        OurPointCapture = {"vo/announcer_control_point_warning.mp3", "vo/announcer_control_point_warning2.mp3", "vo/announcer_control_point_warning3.mp3"},
        OurPointTaken = "vo/announcer_we_lost_control.mp3",
        TheirPointCapture = nil,
        TheirPointTaken = {"vo/announcer_we_secured_control.mp3", "vo/announcer_we_captured_control.mp3"},
    },
    raid = {
        Start = false,
        StartAttack = "vo/announcer_attack_controlpoints.mp3",
        StartDefend = "vo/announcer_defend_controlpoints.mp3",
        OurPointCapture = {"vo/announcer_control_point_warning.mp3", "vo/announcer_control_point_warning2.mp3", "vo/announcer_control_point_warning3.mp3"},
        OurPointTaken = "vo/announcer_we_lost_control.mp3",
        TheirPointCapture = nil,
        TheirPointTaken = {"vo/announcer_we_secured_control.mp3", "vo/announcer_we_captured_control.mp3"},
    },
    dom = {
        Start = "vo/announcer_capture_controlpoints.mp3",
        OurPointCapture = {"vo/announcer_control_point_warning.mp3", "vo/announcer_control_point_warning2.mp3", "vo/announcer_control_point_warning3.mp3"},
        OurPointTaken = "vo/announcer_we_lost_control.mp3",
        TheirPointCapture = nil,
        TheirPointTaken = {"vo/announcer_we_secured_control.mp3", "vo/announcer_we_captured_control.mp3"},
    },
}