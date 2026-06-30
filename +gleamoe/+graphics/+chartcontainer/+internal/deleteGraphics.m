function deleteGraphics(value)
%deleteGraphics Best-effort deletion for MATLAB and Baltamatica graphics.
    if isempty(value)
        return
    end

    try
        delete(value);
    catch
    end
end
