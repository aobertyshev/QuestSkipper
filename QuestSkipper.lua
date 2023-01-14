QuestSkipper = QuestSkipper or {}
QuestSkipper.Name = "QuestSkipper"
QuestSkipper.Version = "1.2.0"
QuestSkipper.HorseSkillsMap = {
    ["Speed"] = RIDING_TRAIN_SPEED,
    ["Stamina"] = RIDING_TRAIN_STAMINA,
    ["Capacity"] = RIDING_TRAIN_CARRYING_CAPACITY
}

function QuestSkipper:ToggleDialogues()
    QuestSkipper.SavedVariables.SkipDialogues = not QuestSkipper.SavedVariables.SkipDialogues
    d('Dialogue skip is now ' .. (QuestSkipper.SavedVariables.SkipDialogues and 'enabled' or 'disabled') .. '.')
end

function QuestSkipper.ShowBook()
    if QuestSkipper.SavedVariables.SkipBooks then
        EndInteraction(INTERACTION_BOOK)
    end
end

function QuestSkipper.ConversationUpdated(eventCode, bodyText, optionCount)
    QuestSkipper.ChatterBegin(eventCode, optionCount)
end

function QuestSkipper.ChatterBegin(eventCode, optionCount)
    if ((QuestSkipper.SavedVariables.SkipDialogues) and (optionCount == 0)) then
        --skip if we have nothing to say to an NPC
        EndInteraction(INTERACTION_CONVERSATION)
    end
    for i = 1, optionCount do
        local optionString, optionType, optionalArgument, isImportant, chosenBefore = GetChatterOption(i)
        --d(optionCount .. ' ' .. optionString .. ' ' .. optionType .. ' ' .. optionalArgument .. ' ' .. tostring(isImportant) .. ' ' .. tostring(chosenBefore))
        if
        --if the choice is in red text (important) and there's more than 1 choice
        (isImportant and (optionCount > 1) and (not QuestSkipper.SavedVariables.SkipImportantChoices)) or
        --merchant
        (optionType == CHATTER_START_SHOP) or
        --banker
        (optionType == CHATTER_START_BANK) or
        --guild bank
        (optionType == CHATTER_START_GUILDBANK) or
        --guild store
        (optionType == CHATTER_START_TRADINGHOUSE) then
            --if encountered any of the above options, stop
            return
        end
        if ((optionType == CHATTER_START_STABLE) and (QuestSkipper.SavedVariables.SkipStableTraining)) then
            SelectChatterOption(i)
            --Will train skills in order
            --TrainRiding will not work for a skill that's already at max, thus it's possible to simply bruteforce the "next" skill
            for skill in string.gmatch(QuestSkipper.SavedVariables.HorseSkillsOrder, "[^\n]+") do
                TrainRiding(QuestSkipper.HorseSkillsMap[skill])
            end
            EndInteraction(INTERACTION_CONVERSATION)
            break
        end
        if
        ((not chosenBefore) and (QuestSkipper.SavedVariables.SkipDialogues) and (
        --usually the first dialogue options when the conversation has started
        optionType == CHATTER_START_TALK or
        --just a common phrase
        optionType == CHATTER_TALK_CHOICE or
        --accepting quest
        optionType == CHATTER_START_NEW_QUEST_BESTOWAL or
        --completing quest
        optionType == CHATTER_START_COMPLETE_QUEST or
        --when the option is to pay money (e.g. bribe, not bounty)
        optionType == CHATTER_TALK_CHOICE_MONEY or
        --when the option is to pay bounty
        optionType == CHATTER_TALK_CHOICE_PAY_BOUNTY
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
    if addonName ~= QuestSkipper.Name then return end

    QuestSkipper.InitSavedVariables()
    QuestSkipper.InitSettings()
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_QUEST_OFFERED, QuestSkipper.QuestOffered)
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_QUEST_COMPLETE_DIALOG, QuestSkipper.QuestComplete)
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_CHATTER_BEGIN, QuestSkipper.ChatterBegin)
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_CONVERSATION_UPDATED, QuestSkipper.ConversationUpdated)
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_SHOW_BOOK, QuestSkipper.ShowBook)
    EVENT_MANAGER:UnregisterForEvent(QuestSkipper.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_ADD_ON_LOADED, QuestSkipper.OnAddOnLoaded)
