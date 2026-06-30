function opts = parseCreateAxesOptions(args)
%parseCreateAxesOptions Parse internal createAxes options.
    opts = struct('Type', 'cartesian', 'Tile', []);
    idx = 1;
    while idx <= numel(args)
        name = args{idx};
        if ~(ischar(name) || (isstring(name) && isscalar(name)))
            error('gleamoe:chartcontainer:CreateAxesOptions', ...
                'createAxes options must be name-value pairs.');
        end
        if idx == numel(args)
            error('gleamoe:chartcontainer:CreateAxesOptions', ...
                'createAxes option "%s" requires a value.', char(name));
        end

        value = args{idx + 1};
        switch lower(char(name))
            case 'type'
                opts.Type = lower(char(value));
            case 'tile'
                opts.Tile = value;
            otherwise
                error('gleamoe:chartcontainer:CreateAxesOptions', ...
                    'Unknown createAxes option "%s".', char(name));
        end
        idx = idx + 2;
    end
end
