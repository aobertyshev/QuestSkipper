--certainly not the best practice but oh well
--todo move to settings.lua
local LAM = LibAddonMenu2
local panelName = "QuestSkipperSettingsPanel"
 
local panelData = {
    type = "panel",
    name = "QuestSkipper",
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
      width       = "full"
    }
}

QuestSkipper = {}
QuestSkipper.name = "QuestSkipper"
QuestSkipper.HorseSkillsMap = {
    ["Speed"] = RIDING_TRAIN_SPEED,
    ["Stamina"] = RIDING_TRAIN_STAMINA,
    ["Capacity"] = RIDING_TRAIN_CARRYING_CAPACITY
}

function QuestSkipper:Initialize()
    QuestSkipper.SavedVariables = ZO_SavedVars:NewCharacterIdSettings("QuestSkipperVars", 1, nil, nil)
    if (QuestSkipper.SavedVariables.SkipDialogues == nil) then
        QuestSkipper.SavedVariables.SkipDialogues = true
    end
    if (QuestSkipper.SavedVariables.SkipStableTraining == nil) then
        QuestSkipper.SavedVariables.SkipStableTraining = true
    end
    if (QuestSkipper.SavedVariables.HorseSkillsOrder == nil) then
        QuestSkipper.SavedVariables.HorseSkillsOrder = "Speed\nStamina\nCapacity"
    end
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_OFFERED, self.QuestOffered)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_COMPLETE_DIALOG, self.QuestComplete)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_BEGIN, self.ChatterBegin)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CONVERSATION_UPDATED, self.ConversationUpdated)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsData)
end

function QuestSkipper:ToggleDialogues()
    QuestSkipper.SavedVariables.SkipDialogues = not QuestSkipper.SavedVariables.SkipDialogues
    d('Dialogue skip is now ' .. (QuestSkipper.SavedVariables.SkipDialogues and 'enabled' or 'disabled') .. '.')
end

function QuestSkipper.ConversationUpdated(eventCode, bodyText, optionCount)
    QuestSkipper.ChatterBegin(eventCode, optionCount)
end

function QuestSkipper.ChatterBegin(eventCode, optionCount)
    if ((QuestSkipper.SavedVariables.SkipDialogues) and (optionCount == 0)) then 
        EndInteraction(INTERACTION_CONVERSATION)
    end
    for i = 1, optionCount do
        local optionString, optionType, optionalArgument, isImportant, chosenBefore = GetChatterOption(i)
        -- d(optionType .. ' ' .. optionString)
        if ((optionType == CHATTER_START_STABLE) and (QuestSkipper.SavedVariables.SkipStableTraining)) then
            SelectChatterOption(i)
            for skill in string.gmatch(QuestSkipper.SavedVariables.HorseSkillsOrder, "[^\n]+") do
                TrainRiding(QuestSkipper.HorseSkillsMap[skill])
            end
            EndInteraction(INTERACTION_CONVERSATION)
            break
        end
        if ((not chosenBefore) and (QuestSkipper.SavedVariables.SkipDialogues) and (
            optionType == CHATTER_START_NEW_QUEST_BESTOWAL or
            optionType == CHATTER_START_COMPLETE_QUEST or
            optionType == CHATTER_START_TALK or
            optionType == CHATTER_START_SHOP or
            -- optionType == CHATTER_TALK_CHOICE_PAY_BOUNTY or
            -- optionType == CHATTER_START_BANK or
            -- optionType == CHATTER_START_TRADINGHOUSE or
            optionType == CHATTER_TALK_CHOICE
        )) then
            SelectChatterOption(i)
            return
        end
    end
    if (QuestSkipper.SavedVariables.SkipDialogues) then
        EndInteraction(INTERACTION_CONVERSATION)
    end
end

function QuestSkipper.QuestComplete(eventCode)
    if (QuestSkipper.SavedVariables.SkipDialogues) then
        CompleteQuest()
    end
end

function QuestSkipper.QuestOffered(eventCode)
    if (QuestSkipper.SavedVariables.SkipDialogues) then
        AcceptOfferedQuest()
        EndInteraction(INTERACTION_CONVERSATION)
    end
end

function QuestSkipper.OnAddOnLoaded(event, addonName)
    if addonName == QuestSkipper.name then
        QuestSkipper:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(QuestSkipper.name, EVENT_ADD_ON_LOADED, QuestSkipper.OnAddOnLoaded)