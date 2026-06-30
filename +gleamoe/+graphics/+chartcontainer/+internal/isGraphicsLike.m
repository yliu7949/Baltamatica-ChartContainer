function tf = isGraphicsLike(value)
%isGraphicsLike True for MATLAB or Baltamatica graphics handles/structs.
    tf = false;
    if isempty(value)
        return
    end

    try
        tf = isgraphics(value);
        if tf
            return
        end
    catch
    end

    try
        tf = ishandle(value);
        if tf
            return
        end
    catch
    end

    if isstruct(value) && (isfield(value, 'GraphicsType') || isfield(value, 'ObjectType'))
        tf = true;
    end
end
