function out = str2double(in)
% Convert char array from DBF to cell array of doubles
    if isempty(in)
        out = {NaN};
        return
    end

    for k = size(in, 1):-1:1
        out{k} = empty2nan(sscanf(in(k, :), '%f', 1));
    end
end

function val = empty2nan(val)
    if isempty(val)
        val = NaN;
    end
end
