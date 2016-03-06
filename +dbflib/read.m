function [data, info] = read(file, records, fields)
%READ Read the specified records and fields from a DBF file.

    const = dbflib.mixin.DBFConsts;

    standalone = ischar(file);
    if standalone
        [~, ~, ext] = fileparts(file);
        if isempty(ext)
            file = [file, '.dbf'];
        end

        [fid, errmsg] = fopen(file, const.READ_BINARY, const.LITTLE_ENDIAN);
        assert(isempty(errmsg), ...
               'DBFREAD:OpenFileError', ...
               'Failed to open file %s.\nError: %s', file, errmsg)
    else
        fid = file;
    end

    info = dbflib.info(fid);

    if nargin < 3
        fieldsIndex = 1:info.NumFields;
        info.RequestedFieldNames = {info.FieldInfo.Name};
    else
        fieldsIndex = dbflib.mixin.validate_fields(info, fields);
        info.RequestedFieldNames = {info.FieldInfo(fieldsIndex).Name};
    end

    if nargin < 2 || isempty(records) || ~all(isfinite(records))
        records = 1:info.NumRecords;
    elseif max(records) > info.NumRecords
        error('DBFREAD:invalidRecordNumber', ...
              'Record# %d does not exist. (#records: %d)',...
              max(records), info.NumRecords)
    end

    skipRecords = min(records)-1;
    recordRange = max(records)-skipRecords;
    records = records-skipRecords;
    data = cell(length(records), length(fieldsIndex));
    for k = 1:length(fieldsIndex)
        n = fieldsIndex(k);
        
        fieldOffset = info.HeaderLength + ...
                      info.FieldInfo(n).Offset + ...
                      skipRecords*info.RecordLength + ...
                      const.DELETION_INDICATOR_LENGTH;
        fseek(fid, fieldOffset, const.BEGIN_OF_FILE);
        formatString = sprintf('%d*uint8=>char', ...
                               info.FieldInfo(n).Length);
        skip = info.RecordLength - info.FieldInfo(n).Length;
        tmp = fread(fid, ...
                    [info.FieldInfo(n).Length, recordRange], ...
                    formatString, ...
                    skip, ...
                    const.LITTLE_ENDIAN);
        data(:,k) = info.FieldInfo(n).ConvFunc(tmp(:, records)');
    end

    if standalone
        fclose(fid);
    end
end
