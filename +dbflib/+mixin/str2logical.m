function out = str2logical(in)
% Convert char array from DBF to cell array of true/false values
%   
    if isempty(in)
        out = {NaN};
        return
    end

    truths = {'Y', 'y', 'T', 't'};
    out = ismember(in, truths);
    doubtfuls = strcmp(in, '?');
    if any(doubtfuls)
        out = double(out);
        out(doubtfuls) = NaN;
    end
end
