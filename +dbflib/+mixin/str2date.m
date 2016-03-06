function out = str2date(in)
% Convert char array from DBF to cell array of serial datenumbers
    if isempty(in)
        out = {NaN};
        return
    end

    for k = size(in, 1):-1:1
        arr = sscanf(in(k, :), '%4d%2d%2d')';
        if ~all(arr==0)
            out{k} = datenummx(arr);
        else
            out{k} = NaN;
        end
    end
end
