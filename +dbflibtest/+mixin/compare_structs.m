function equal = compare_structs(struct1, struct2)
    %COMPARE_STRUCTS Summary of this function goes here
    %   Detailed explanation goes here

    equal = true;

    flds1 = fieldnames(struct1);
    flds2 = fieldnames(struct2);

    % Check if all fields exist in both structs
    if ~isempty(setdiff(flds1, flds2)) || ...
            ~isempty(setdiff(flds2, flds1))
        equal = false;
        return
    end

    % Check if structsize of both structs are equal
    if numel(struct1) ~= numel(struct2)
        equal = false;
        return
    end

    % For each struct in structarray check contents
    for n = 1:numel(struct1)
        % For each field in the struct check equal classes and contents
        for fld = flds1(:)'
            fld = fld{1}; %#ok<FXSET>
            fld1 = struct1(n).(fld);
            fld2 = struct2(n).(fld);

            % Check class of both fields
            if ~strcmp(class(fld1), class(fld2))
                equal = false;
                return
            end
            
            % If substruct check recursively, else check equality
            if isstruct(fld1)
                equal = dbflibtest.mixin.compare_structs(fld1, fld2);
                if ~equal
                    return
                end
            elseif fld1 ~= fld2
                equal = false;
                return
            end
        end
    end
end
