function fields = get_field_names(dbfInfo)
    dc = dbflib.mixin.DBFConsts;
    fields = {dbfInfo.FieldInfo.Name};
    fields= char(matlab.lang.makeUniqueStrings(fields, ...
                                               1:length(fields), ...
                                               dc.FIELD_NAME_NUMVALS));
    fields(fields == ' ') = 0;
    if size(fields, 2) < dc.FIELD_NAME_NUMVALS
        fields(1, dc.FIELD_NAME_NUMVALS) = 0;
    end
end
