function value = mustBeChoice(value, choices, propName)
%mustBeChoice Validate a case-insensitive text option.
    value = gleamoe.graphics.chartcontainer.internal.mustBeText(value, propName);
    hit = strcmpi(value, choices);
    if ~any(hit)
        error('gleamoe:chartcontainer:InvalidProperty', ...
            '%s must be one of: %s.', propName, strjoin(choices, ', '));
    end
    value = choices{find(hit, 1, 'first')};
end
