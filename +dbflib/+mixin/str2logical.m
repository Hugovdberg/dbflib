function out = str2logical(in)
% Convert char array from DBF to cell array of true/false values
    if isempty(in)
        out = {NaN};
        return
    end

    for k = size(in, 1):-1:1
        out{k} = empty2nan(logical(sscanf(in(k, :), '%d', 1)));
    end
end

function val = empty2nan(val)
    if isempty(val)
        val = NaN;
    end
end
