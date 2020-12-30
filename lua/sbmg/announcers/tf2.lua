ANNOUNCER.PrintName = "#sbmg.announcers.tf2"
ANNOUNCER.Description = "#sbmg.announcers.tf2.desc"

ANNOUNCER.SortOrder = 1

ANNOUNCER.GenericLines = {
    Start = {
        "vo/announcer_am_roundstart01.mp3",
        "vo/announcer_am_roundstart02.mp3",
        "vo/announcer_am_roundstart03.mp3",
        "vo/announcer_am_roundstart04.mp3"
    },

    Win = "misc/your_team_won.mp3",
    Lose = "misc/your_team_lost.mp3",
    Tie = "misc/your_team_stalemate.mp3",

    EndCountdown = { -- Number index indicates the seconds left
        [500] = "vo/announcer_ends_5min.mp3",
        [60] = "vo/announcer_ends_60sec.mp3",
        [30] = "vo/announcer_ends_30sec.mp3",
        [10] = "vo/announcer_ends_10sec.mp3",
        [5] = "vo/announcer_ends_5sec.mp3",
        [4] = "vo/announcer_ends_4sec.mp3",
        [3] = "vo/announcer_ends_3sec.mp3",
        [2] = "vo/announcer_ends_2sec.mp3",
        [1] = "vo/announcer_ends_1sec.mp3",
    }
}

ANNOUNCER.MinigameLines = {
    ctf = {
        Start = "vo/announcer_capture_intel.mp3",
        OurFlagTaken = {"vo/intel_enemystolen.mp3", "vo/intel_enemystolen2.mp3", "vo/intel_enemystolen3.mp3", "vo/intel_enemystolen4.mp3"},
        OurFlagDropped = {"vo/intel_enemydropped.mp3", "vo/intel_enemydropped2.mp3"},
        OurFlagCaptured = {"vo/intel_enemycaptured.mp3", "vo/intel_enemycaptured2.mp3"},
        OurFlagReturned = {"vo/intel_enemyreturned.mp3", "vo/intel_enemyreturned2.mp3", "vo/intel_enemyreturned3.mp3"},
        TheirFlagTaken = "vo/intel_teamstolen.mp3",
        TheirFlagDropped = {"vo/intel_teamdropped.mp3", "vo/intel_teamdropped2.mp3"},
        TheirFlagCaptured = {"vo/intel_teamcaptured.mp3", "vo/intel_teamcaptured2.mp3"},
        TheirFlagReturned = "vo/intel_teamreturned.mp3",
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