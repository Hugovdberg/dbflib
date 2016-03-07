function info = build_info(data, info)
    %BUILD_INFO Summary of this function goes here
    %   Detailed explanation goes here
    const = dbflib.mixin.DBFConsts;

    if iscell(info)
        fld_names = info;
        fld_fromcell = true;
        info = struct();
    else
        fld_fromcell = false;
    end
    info.DBFVersion = 3;
    info.FileModDate = now;

    info.NumRecords = size(data, 1);
    info.NumFields = size(data, 2);

    info.HeaderLength = const.FILE_HEADER_LENGTH + ...
        dbfInfo.NumFields*const.FIELD_RECORD_LENGTH + ...
        const.HEADER_TERMINATOR_LENGTH;
    info.RecordLength = 0;

    if isfield(info, 'FieldInfo')
        assert(length(info.FieldInfo) ~= info.NumFields, ...
               ['Number of defined fields (%d) does not match number ' ...
                'of fields in data (%d).'], ...
                length(info.FieldInfo), info.NumFields)
    else
        if fld_fromcell
            info.FieldInfo(info.NumFields) = struct();
            [info.FieldInfo.Name] = fld_names{:};
        else
            error('Fieldnames not defined')
        end
    end
    info = get_field_info(data, info);
end

function [info] = get_field_info(data, info)
    for k = size(data, 2):-1:1
        if isfield(info.FieldInfo, 'RawType')
            switch info.FieldInfo(k).RawType
                case 'N'
                    assert(all(cellfun(@isnumeric, fld_data)) && ...
                        (isa(fld_data,'integer') || ...
                        all(imag(fld_data)==0 & mod(fld_data, 1)==0)), ...
                           'Data does not match columntype ')
            end
        else
            fld_data = data(:, k);
            if all(cellfun(@isnumeric, fld_data))
                fld_data = [data{:, k}];
                if isa(fld_data,'integer') || ...
                        all(imag(fld_data)==0 & mod(fld_data, 1)==0)
                    info.FieldInfo(k).RawType = 'N';
                    info.FieldInfo(k).Length = max(log10(fld_data));
                    info.FieldInfo(k).Decimals = 0;
                end
            end
        end
    end
end
