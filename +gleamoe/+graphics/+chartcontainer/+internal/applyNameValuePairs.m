function applyNameValuePairs(this, args)
%applyNameValuePairs Set public properties from MATLAB-style name-value args.
    if isempty(args)
        return
    end

    if rem(numel(args), 2) ~= 0
        error('gleamoe:chartcontainer:NameValuePairs', ...
            'Name-value arguments must appear in pairs.');
    end

    names = properties(this);
    for idx = 1:2:numel(args)
        rawName = args{idx};
        if ~(ischar(rawName) || (isstring(rawName) && isscalar(rawName)))
            error('gleamoe:chartcontainer:InvalidName', ...
                'Name-value argument names must be character vectors or string scalars.');
        end

        name = matchProperty(char(rawName), names);
        if isempty(name)
            error('gleamoe:chartcontainer:UnknownProperty', ...
                'Unknown chart property "%s".', char(rawName));
        end

        this.(name) = args{idx + 1};
    end
end

function name = matchProperty(rawName, names)
    name = '';
    hits = strcmp(rawName, names);
    if any(hits)
        name = names{find(hits, 1, 'first')};
        return
    end

    hits = strcmpi(rawName, names);
    if any(hits)
        name = names{find(hits, 1, 'first')};
    end
end
