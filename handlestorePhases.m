function phases = handlestorePhases(sleepPhases, phaseType)
    phases = [];
    for i = 1:size(sleepPhases, 1)
        if sleepPhases(i, 3) == phaseType
            phases = [phases; sleepPhases(i, 1), sleepPhases(i, 2)];
        end
    end
end