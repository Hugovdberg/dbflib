function [fid, standalone] = get_file_handle(file, permission)
%GET_FILE_HANDLE Returns handle to opened file
%   If a string is provided the file is opened, if a number is given it is
%   checked to be a valid handle to an open file.
%
%   Inputs:
%       file (char or double):
%           Either a string specifying filename, or a number as returned by
%           fopen. If extension dbf is missing from filename it is appended
%           automatically. If a number is specified it is checked to be a
%           valid handle.
%       permission (char, optional):
%           Permission string as defined for <a
%           href="matlab:help('fopen')">fopen</a>, defaults to reading in
%           binary mode.
%
%   Outputs:
%       fid (double):
%           Handle to opened file
%       standalone (logical):
%           Boolean whether or not a string was specified. If so it is
%           considered to be in standalone mode, and thus it is safe to
%           close the file after finishing operations. If a number was
%           given consider the file to be opened for multiple purposes and
%           let the caller close the file.
    const = dbflib.mixin.DBFConsts;

    if nargin < 2
        permission = const.READ_BINARY;
    end
    machinefmt = const.LITTLE_ENDIAN;

    standalone = ischar(file);
    if standalone
        [~, ~, ext] = fileparts(file);
        if isempty(ext)
            file = [file, '.dbf'];
        end

        fid = [];
        for k = fopen('all')
            [f, p] = fopen(k);
            if strcmp(f, file) && strcmp(p, permission)
                fid = k;
                standalone = false;
                break
            end
        end
        if isempty(fid)
            [fid, err] = fopen(file, permission, machinefmt);
            assert(isempty(err), ...
                   'DBFLIB:OpenFileError', ...
                   'Failed to open file %s.\nError: %s', file, err)
        end
    else
        assert(~isempty(fopen(file)), ...
               'DBFLIB:OpenFileError', ...
               'Invalid filehandle, provide filename or valid handle')
        fid = file;
    end
end

