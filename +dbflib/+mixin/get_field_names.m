function fields = getFieldNames(dbfInfo)
    dc = dbflib.mixin.DBFConsts;
    fields = {dbfInfo.FieldInfo.Name};
    fields= char(matlab.lang.makeUniqueStrings(fields, ...
                                               1:length(fields), ...
                                               dc.FIELD_NAME_NUMVALS));
    fields(fields == ' ') = 0;
    if size(fields, 2) < 11
        fields(1, 11) = 0;
    end
end
