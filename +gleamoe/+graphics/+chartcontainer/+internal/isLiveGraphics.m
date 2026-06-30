function tf = isLiveGraphics(value)
%isLiveGraphics True if a graphics handle appears usable.
    tf = false;
    if isempty(value)
        return
    end

    try
        tf = isgraphics(value);
        return
    catch
    end

    try
        tf = ishandle(value);
        return
    catch
    end

    tf = isstruct(value) && (isfield(value, 'GraphicsType') || isfield(value, 'ObjectType'));
end
