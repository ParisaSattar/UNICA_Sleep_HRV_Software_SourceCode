function transitions = handlePhaseTransitions(sleepPhases, fromPhase, toPhase)
    transitions = [];
    for i = 2:size(sleepPhases, 1)
        prevPhase = sleepPhases(i - 1, 3); % Previous phase
        currentPhase = sleepPhases(i, 3); % Current phase
        if prevPhase == fromPhase && currentPhase == toPhase
            transitions = [transitions; sleepPhases(i, 1), sleepPhases(i, 2)];
        end
    end
end