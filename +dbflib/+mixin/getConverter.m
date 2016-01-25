function typeConverters = getConverter(dbftypes)
% Construct struct array with MATLAB types & conversion function handles.

    % typeidx has ascii values for N, F, C and D (in that order)
    typeidx = [78, 70, 67, 68, 76];
    typename = {'double', 'double', 'char', 'double', 'logical'};
    typeconv = {@dbflib.mixin.str2double, ...
                @dbflib.mixin.str2double, ...
                @cellstr, ...
                @dbflib.mixin.str2date, ...
                @dbflib.mixin.str2logical};
    typeConverters_ = struct('MATLABType', typename, 'ConvFunc', typeconv);

    % Unsupported types: Memo,N/ANameVariable,Binary,General,Picture
    unsupported = struct('MATLABType', 'unsupported', ...
                         'ConvFunc',   @cellstr);

    numFields = length(dbftypes);
    for k = numFields:-1:1
        idx = double(dbftypes(k)) == typeidx;
        if any(idx)
            typeConverters(k) = typeConverters_(idx);
        else
            typeConverters(k) = unsupported;
        end
    end
end
