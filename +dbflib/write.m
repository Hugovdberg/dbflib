function write(file, data, info)
%WRITE Writes cell array as DBF file

    const = dbflib.mixin.DBFConsts;

    if nargin < 3
        info = dbflib.mixin.build_info(data);
    end
    
    standalone = ischar(file);
    if standalone
        [~, ~, ext] = fileparts(file);
        if isempty(ext)
            file = [file, '.dbf'];
        end

        if exist(file, 'file')
            choice = questdlg('Overwrite file?', 'Confirm overwriting', 'No');
            if ~strcmpi(choice, 'yes')
                return
            end
        end
        [fid, errmsg] = fopen(file, const.WRITE_BINARY, const.LITTLE_ENDIAN);
        assert(isempty(errmsg), ...
               'DBFREAD:OpenFileError', ...
               'Failed to open file %s.\nError: %s', file, errmsg)
    else
        fid = file;
    end

    try
        fseek(fid, const.DBF_VERSION_OFFSET, const.BEGIN_OF_FILE);
        fwrite(fid, 3, const.INT8, 0, const.LITTLE_ENDIAN);

        dateparts = datevec(info.FileModDate);
        dateparts(1) = dateparts(1)-1900;
        fwrite(fid, dateparts(1:3), const.INT8, 0, const.LITTLE_ENDIAN);

        fwrite(fid, info.NumRecords, const.INT32, 0, const.LITTLE_ENDIAN);

        fwrite(fid, [info.HeaderLength, info.RecordLength], ...
               const.INT16, 0, const.LITTLE_ENDIAN);

        fseek(fid, const.FIELD_NAME_NUMVALS, const.BEGIN_OF_FILE);
        fields = dbflib.mixin.get_field_names(info)';
        fwrite(fid, ...
               fields, ...
               const.FIELD_WRITE_NAME_DATATYPE, ...
               const.FIELD_RECORD_LENGTH-const.FIELD_NAME_NUMVALS, ...
               const.LITTLE_ENDIAN);

        fseek(fid, const.FIELD_TYPE_OFFSET+const.FIELD_TYPE_NUMVALS, const.BEGIN_OF_FILE);
        fwrite(fid, ...
               cast(char({info.FieldInfo.RawType})', 'uint8'), ...
               const.FIELD_WRITE_TYPE_DATATYPE, ...
               const.FIELD_RECORD_LENGTH-const.FIELD_TYPE_NUMVALS, ...
               const.LITTLE_ENDIAN);

        fseek(fid, const.FIELD_LENGTH_OFFSET+const.FIELD_LENGTH_NUMVALS, const.BEGIN_OF_FILE);
        fwrite(fid, ...
               cast([info.FieldInfo.Length], 'uint8'), ...
               const.FIELD_LENGTH_DATATYPE, ...
               const.FIELD_RECORD_LENGTH-const.FIELD_LENGTH_NUMVALS, ...
               const.LITTLE_ENDIAN);

        fseek(fid, const.FIELD_PRECISION_OFFSET+const.FIELD_PRECISION_NUMVALS, const.BEGIN_OF_FILE);
        fwrite(fid, ...
               [info.FieldInfo.Decimals], ...
               const.FIELD_PRECISION_DATATYPE, ...
               const.FIELD_RECORD_LENGTH-const.FIELD_PRECISION_NUMVALS, ...
               const.LITTLE_ENDIAN);

        fseek(fid, const.FIELD_FLAGS_OFFSET+const.FIELD_FLAGS_NUMVALS, const.BEGIN_OF_FILE);
        fwrite(fid, ...
               [info.FieldInfo.Flags], ...
               const.FIELD_FLAGS_DATATYPE, ...
               const.FIELD_RECORD_LENGTH-const.FIELD_FLAGS_NUMVALS, ...
               const.LITTLE_ENDIAN);

        fseek(fid, ...
              const.FILE_HEADER_LENGTH + ...
                  info.NumFields*const.FIELD_RECORD_LENGTH, ...
              const.BEGIN_OF_FILE);
        fwrite(fid, const.HEADER_TERMINATOR, const.INT8, 0, const.LITTLE_ENDIAN);

        for k = 1:info.NumFields
%             fielddata = dbfData(:, k);
            clear fielddata
            fieldlength = info.FieldInfo(k).Length;
            switch info.FieldInfo(k).RawType
                case {'N', 'F'}
                    % numeric
                    formatstr = sprintf('%%%d.%df', ...
                                        fieldlength, ...
                                        info.FieldInfo(k).Decimals);
                    writeprec = sprintf('%d*uint8', fieldlength);
                    fielddata = reshape(sprintf(formatstr, ...
                                                data{:, k})', ...
                                        fieldlength, ...
                                        []);
                case 'D'
                    % date
                    writeprec = '8*uint8';
                    formatstr = '%04d%02d%02d';
                    for l = info.NumRecords:-1:1
                        vec = datevec(data{l, k});
                        if any(isnan(vec))
                            fielddata(l, :) = '00000000';
                        else
                            fielddata(l, :) = sprintf(formatstr, vec(1:3));
                        end
                    end
                    fielddata = fielddata';
                case 'C'
                    writeprec = sprintf('%d*uint8', fieldlength);
                    fielddata = char(data(:, k));
                    if size(fielddata, 2) < fieldlength
                        fielddata(1, fieldlength) = 0;
                    elseif size(fielddata, 2) > fieldlength
                        warning('Data exceeds field length for ''%s''', ...
                                info.FieldInfo(k).Name)
                        fielddata = fielddata(:, 1:fieldlength);
                    end
                    fielddata = fielddata';
                otherwise
                    error('Fieldtype not implemented yet for writing')
            end
            offset = info.HeaderLength + ...
                const.DELETION_INDICATOR_LENGTH + ...
                info.FieldInfo(k).Offset + ...
                info.FieldInfo(k).Length - ...
                info.RecordLength;
            fseek(fid, offset, const.BEGIN_OF_FILE);
%             fwrite(fid, fielddata(:, 1)', writeprec, ...
%                    0, ...
%                    const.LITTLE_ENDIAN)
%             if info.NumRecords > 1
%                 fwrite(fid, fielddata(:, 2:end), writeprec, ...
%                        info.RecordLength-fieldlength, ...
%                        const.LITTLE_ENDIAN)
%             end
            fwrite(fid, fielddata, writeprec, info.RecordLength-fieldlength, const.LITTLE_ENDIAN);
        end
        fseek(fid, ...
              info.HeaderLength+const.HEADER_TERMINATOR_LENGTH+...
                info.NumRecords*info.RecordLength, ...
              const.BEGIN_OF_FILE);
        fwrite(fid, const.FILE_TERMINATOR, 'uint8');
    catch err
        if standalone
            fclose(fid);
        end
        rethrow(err)
    end

    if standalone
        fclose(fid);
    end
end
