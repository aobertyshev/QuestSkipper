QuestSkipper = QuestSkipper or {}

function QuestSkipper.InitSavedVariables()
    QuestSkipper.SavedVariables = ZO_SavedVars:NewCharacterIdSettings("QuestSkipperVars", 1, nil, nil)
    if (QuestSkipper.SavedVariables.SkipDialogues == nil) then
        QuestSkipper.SavedVariables.SkipDialogues = true
    end
    if (QuestSkipper.SavedVariables.SkipStableTraining == nil) then
        QuestSkipper.SavedVariables.SkipStableTraining = true
    end
    if (QuestSkipper.SavedVariables.SkipBooks == nil) then
        QuestSkipper.SavedVariables.SkipBooks = true
    end
    if (QuestSkipper.SavedVariables.SkipImportantChoices == nil) then
        QuestSkipper.SavedVariables.SkipImportantChoices = false
    end
    if (QuestSkipper.SavedVariables.HorseSkillsOrder == nil) then
        QuestSkipper.SavedVariables.HorseSkillsOrder = "Speed\nStamina\nCapacity"
    end
end

function QuestSkipper.InitSettings()
    local panelName = "QuestSkipperSettingsPanel"
     
    local panelData = {
        type = "panel",
        name = QuestSkipper.Name,
        displayName = QuestSkipper.Name,
        version = QuestSkipper.Version,
        author = "@helixanon",
    }
    local optionsData = {
        {
            type = "checkbox",
            name = "Skip dialogues",
            getFunc = function() return QuestSkipper.SavedVariables.SkipDialogues end,
            setFunc = function(value) QuestSkipper.SavedVariables.SkipDialogues = value end
        },
        {
            type = "checkbox",
            name = "Skip important choices",
            tooltip = "Whether to skip or not quest-specific choices (red text). If enabled, will always pick the first option.",
            getFunc = function() return QuestSkipper.SavedVariables.SkipImportantChoices end,
            setFunc = function(value) QuestSkipper.SavedVariables.SkipImportantChoices = value end
        },
        {
            type = "checkbox",
            name = "Skip books",
            tooltip = "Read books without opening them.",
            getFunc = function() return QuestSkipper.SavedVariables.SkipBooks end,
            setFunc = function(value) QuestSkipper.SavedVariables.SkipBooks = value end
        },
        {
            type = "checkbox",
            name = "Skip stable training",
            getFunc = function() return QuestSkipper.SavedVariables.SkipStableTraining end,
            setFunc = function(value) QuestSkipper.SavedVariables.SkipStableTraining = value end
        },
        {
            type        = "editbox",
            name        = "Riding skills order",
            getFunc     = function() return QuestSkipper.SavedVariables.HorseSkillsOrder end,
            setFunc     = function(value) QuestSkipper.SavedVariables.HorseSkillsOrder = value end,
            isMultiline = true,
            textType    = TEXT_TYPE_ALL,
            width       = "full",
            tooltip     = "If \"Skip stable training\" option is ON, will train skills in this order."
        }
    }
    LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
    LibAddonMenu2:RegisterOptionControls(panelName, optionsData)
end
