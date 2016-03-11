function info = build_info(data, info)
%BUILD_INFO Builds/completes an info struct to write DBF data to file
%   Complementary function to collect data necessary to write DBF data.
%
%   Inputs:
%       data (cell):
%           Cell array containing the data, one column per field, one row
%           per record. Necessary to determine datatype and field length
%       info (struct):
%           info can contain any of the following options:
%           - A cell array with the fieldnames, length must match the
%             number of columns in data. Datatype and precission are
%             determined automatically as the minimum to contain all data
%             in the column
%           - A (partial) info struct as returned by dbflib.info, all
%             fields are checked for consitency with the data. Missing or
%             outdated fields are updated with the correct value.
%           - The substruct FieldInfo as in the struct returned by
%             dbflib.info, entire struct is moved automatically to the
%             field FileInfo.
%           There is no significant performance advantage for either of
%           these options as all fields are checked anyway.
%           Dates are stored numerically and cannot be distinguished from
%           other numbers. Therefore, if dates are not specified explicitly
%           they will be stored as numbers and no longer be recognisible as
%           dates. Should a field contain only whole-valued doubles, it is
%           also stored as an integer.
%
%   Outputs:
%       info (struct):
%           Struct containing the necessary 
    const = dbflib.mixin.DBFConsts;

    narginchk(2, 2)
    if iscell(info)
        fldnames = info;
        info = struct();
        info.FieldInfo = struct('Name', fldnames, ...
                                'Length', 0, ...
                                'Decimals', 0, ...
                                'RawType', '');
    elseif isstruct(info)
        if isfield(info, 'Name')
            fldinfo = info;
            info = struct('FieldInfo', fldinfo);
        elseif ~isfield(info, 'FieldInfo') || ...
                ~isfield(info.FieldInfo, 'Name')
            throw(MException('DBFLIB:BUILD_INFO:InvalidInfo', ...
                             'Missing FieldInfo'));
        end
    else
        throw(MException('DBFLIB:BUILD_INFO:InvalidInfo', ...
                         'Datatype is not supported as info'));
    end
    info.DBFVersion = 3;
    info.FileModDate = now;

    info.NumRecords = size(data, 1);
    info.NumFields = size(data, 2);

    info.HeaderLength = const.FILE_HEADER_LENGTH + ...
        info.NumFields*const.FIELD_RECORD_LENGTH + ...
        const.HEADER_TERMINATOR_LENGTH;
    info.RecordLength = 0;

    assert(length(info.FieldInfo) == info.NumFields, ...
           'DBFLIB:InvalidNumFields', ...
           ['Number of defined fields (%d) does not match number ' ...
            'of fields in data (%d).'], ...
           length(info.FieldInfo), info.NumFields)
    info = get_field_info(data, info);

    if info.NumFields > 0
        info.RecordLength = sum([info.FieldInfo.Length]) + ...
            const.DELETION_INDICATOR_LENGTH;
    end
end

function [info] = get_field_info(data, info)
    types = {'int', 'N'; ...
             'double', 'F'; ...
             'char', 'C'; ...
             'date', 'D'; ...
             'logical', 'L'};
    for k = size(data, 2):-1:1
        fldinfo = info.FieldInfo(k);
        if ~isfield(fldinfo, 'RawType') || isempty(fldinfo.RawType)
            if isfield(fldinfo, 'Type') && ~isempty(fldinfo.Type)
                info.FieldInfo(k).RawType = types(strcmp(fldinfo.Type, types(:, 1)), 2);
            else
                fld_data = data(:, k);
                if all(cellfun(@isnumeric, fld_data))
                    fld_data = [fld_data{:}];
                    if isa(fld_data,'integer') || ...
                            all(imag(fld_data)==0 & mod(fld_data, 1)==0)
                        info.FieldInfo(k).RawType = 'N';
                    else
                        info.FieldInfo(k).RawType = 'F';
                    end
                elseif all(cellfun(@islogical, fld_data))
                    info.FieldInfo(k).RawType = 'L';
                else
                    info.FieldInfo(k).RawType = 'C';
                end
            end
        end
        switch info.FieldInfo(k).RawType
            case 'N'
                fld_data = [data{:, k}];
                assert(isnumeric(fld_data) && ...
                    (isa(fld_data,'integer') || ...
                    all(imag(fld_data)==0 & mod(fld_data, 1)==0)), ...
                       'Data does not match columntype ')
                len = max(floor(log10(fld_data)))+1;
                if isfield(fldinfo, 'Length') && ~isempty(fldinfo.Length)
                    len = max(len, fldinfo.Length);
                end
                info.FieldInfo(k).Length = len;
                info.FieldInfo(k).Decimals = 0;
            case 'F'
                fld_data = [data{:, k}];
                info.FieldInfo(k).Length = 20;
                decimals = 20 - max(ceil(log10(fld_data)));
                decimals = min(decimals, 18);
                if isfield(fldinfo, 'Decimals') && ...
                        fldinfo.Decimals > decimals
                    warning('DBFLIB:BUILD_INFO:PrecisionLoss', ...
                            ['Specified number of decimals is greater ' ...
                             'than can possibly be stored'])
                end
                info.FieldInfo(k).Decimals = decimals;
            case 'D'
                info.FieldInfo(k).Length = 8;
                info.FieldInfo(k).Decimals = 0;
            case 'L'
                info.FieldInfo(k).Length = 1;
                info.FieldInfo(k).Decimals = 0;
            case 'C'
                len = max(cellfun(@length, data(:, k)));
                if isfield(fldinfo, 'Length') && ~isempty(fldinfo.Length)
                    len = max(len, fldinfo.Length);
                end
                if len > 254
                    warning('DBFLIB:BUILD_INFO:PrecisionLoss', ...
                            ['Character fields cannot contain more ' ...
                             'than 254 characters, values will be ' ...
                             'truncated'])
                    len = 254;
                end
                info.FieldInfo(k).Length = len;
                info.FieldInfo(k).Decimals = 0;
            otherwise
                info.FieldInfo(k).RawType = 'C';
                len = size(char(data(:, k)), 2) ;
                if isfield(fldinfo, 'Length') && ~isempty(fldinfo.Length)
                    len = max(len, fldinfo.Length);
                end
                info.FieldInfo(k).Length = len;
                info.FieldInfo(k).Decimals = 0;                
        end
    end
end
