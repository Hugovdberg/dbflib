function fieldsIndex = validate_fields(info, fields)
%VALIDATEFIELDS Determines index of fields to read from DBF.

allFields = {info.FieldInfo.Name};
if isempty(fields)
    if ~iscell(fields)
        % Default case: User omitted the parameter, return all fields.
        fieldsIndex = 1:info.NumFields;
    else
        % User supplied '{}', explicitly skip all fields.
        fieldsIndex = [];
    end
else
    [reqs, fieldsIndex] = ismember(fields, allFields);
    if ~all(reqs)
        warning(...
            'DBFREAD:InvalidFieldRequest', ...
            'Requested field ''%s'' does not match DBF field names.', ...
            fields{~reqs}...
            )
        fieldsIndex = fieldsIndex(reqs);
    end
end
