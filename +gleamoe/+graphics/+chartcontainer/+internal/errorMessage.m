function messageText = errorMessage(err)
%errorMessage Return a useful message from MATLAB or Baltamatica catch data.
    messageText = '';

    try
        messageText = err.message;
    catch
    end

    if isempty(messageText)
        try
            messageText = lasterr; %#ok<LERR>
        catch
        end
    end

    if isempty(messageText)
        try
            messageText = char(err);
        catch
            messageText = 'Unknown error';
        end
    end
end
