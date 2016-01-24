function out = str2date(in)
% Convert char array from DBF to cell array of serial datenumbers
    if isempty(in)
        out = {NaN};
        return
    end

    for k = size(in, 1):-1:1
        out{k} = datenummx([sscanf(in(k, :), '%4d%2d%2d')', 0, 0, 0]);
    end
end
