function value = mustBeFourVector(value, propName)
%mustBeFourVector Validate a finite 1-by-4 numeric vector.
    if ~isnumeric(value) || numel(value) ~= 4 || any(~isfinite(value(:)))
        error('gleamoe:chartcontainer:InvalidProperty', ...
            '%s must be a finite numeric vector with four elements.', propName);
    end
    value = reshape(double(value), 1, 4);
end
