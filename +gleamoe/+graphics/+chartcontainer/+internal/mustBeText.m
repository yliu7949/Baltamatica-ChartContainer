function value = mustBeText(value, propName)
%mustBeText Normalize character vector or string scalar.
    if isstring(value) && isscalar(value)
        value = char(value);
    end
    if ~ischar(value)
        error('gleamoe:chartcontainer:InvalidProperty', ...
            '%s must be a character vector or string scalar.', propName);
    end
end
