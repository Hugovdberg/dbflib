function [dbfData, dbfInfo] = read(file, records, fields)
%READ Read the specified records and fields from a DBF file.

    dc = dbf.mixin.DBFConsts;

    standalone = ischar(file);
    if standalone
        [~, ~, ext] = fileparts(file);
        if isempty(ext)
            file = [file, '.dbf'];
        end

        [fid, errmsg] = fopen(file, dc.READ_BINARY, dc.LITTLE_ENDIAN);
        assert(isempty(errmsg), ...
               'DBFREAD:OpenFileError', ...
               'Failed to open file %s.\nError: %s', file, errmsg)
    else
        fid = file;
    end

    dbfInfo = dbf.info(fid);

    if nargin < 3
        fieldsIndex = 1:dbfInfo.NumFields;
        dbfInfo.RequestedFieldNames = {dbfInfo.FieldInfo.Name};
    else
        fieldsIndex = dbf.mixin.validateFields(dbfInfo, fields);
        dbfInfo.RequestedFieldNames = {dbfInfo.FieldInfo(fieldsIndex).Name};
    end

    if nargin < 2 || isempty(records) || ~all(isfinite(records))
        records = 1:dbfInfo.NumRecords;
    elseif max(records) > dbfInfo.NumRecords
        error('DBFREAD:invalidRecordNumber', ...
              'Record# %d does not exist. (#records: %d)',...
              max(records), dbfInfo.NumRecords)
    end

    skipRecords = min(records)-1;
    recordRange = max(records)-skipRecords;
    records = records-skipRecords;
    dbfData = cell(length(records), length(fieldsIndex));
    for k = 1:length(fieldsIndex)
        n = fieldsIndex(k);
        
        fieldOffset = dbfInfo.HeaderLength + ...
                      dbfInfo.FieldInfo(n).Offset + ...
                      skipRecords*dbfInfo.RecordLength + ...
                      dc.DELETION_INDICATOR_LENGTH;
        fseek(fid, fieldOffset, dc.BEGIN_OF_FILE);
        formatString = sprintf('%d*uint8=>char', ...
                               dbfInfo.FieldInfo(n).Length);
        skip = dbfInfo.RecordLength - dbfInfo.FieldInfo(n).Length;
        data = fread(fid, ...
                     [dbfInfo.FieldInfo(n).Length, recordRange], ...
                     formatString, ...
                     skip, ...
                     dc.LITTLE_ENDIAN);
        dbfData(:,k) = dbfInfo.FieldInfo(n).ConvFunc(data(:, records)');
    end

    if standalone
        fclose(fid);
    end
end
