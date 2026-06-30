function [parent, args] = extractParent(argsIn)
%extractParent Pull a leading graphics parent or Parent name-value pair.
    args = argsIn;
    parent = [];

    if ~isempty(args) && isParentCandidate(args{1})
        parent = args{1};
        args = args(2:end);
    end

    if isempty(args)
        return
    end

    keep = true(1, numel(args));
    idx = 1;
    while idx <= numel(args)
        if isName(args{idx}) && strcmpi(char(args{idx}), 'Parent')
            if idx == numel(args)
                error('gleamoe:chartcontainer:MissingParentValue', ...
                    'The Parent name-value argument requires a value.');
            end
            parent = args{idx + 1};
            keep(idx:idx + 1) = false;
            idx = idx + 2;
        else
            idx = idx + 1;
        end
    end

    args = args(keep);
end

function tf = isParentCandidate(value)
    tf = ~isName(value) && gleamoe.graphics.chartcontainer.internal.isGraphicsLike(value);
end

function tf = isName(value)
    tf = ischar(value) || (isstring(value) && isscalar(value));
end
