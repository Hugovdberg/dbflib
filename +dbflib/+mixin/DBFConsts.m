classdef DBFConsts
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        % File reading constants
        READ_BINARY = 'rb';
        WRITE_BINARY = 'wb';
        BIG_ENDIAN = 'ieee-be';
        LITTLE_ENDIAN = 'ieee-le';
        BEGIN_OF_FILE = -1;
        CURRENT_POS = 0;
        END_OF_FILE = 1;
        READ_CONTIGUOUS = 0;
        WRITE_CONTIGUOUS = 0;

        % Data types 
        NO_DATA = -1e38;
        INT8 = 'uint8';
        INT16 = 'uint16';
        INT32 = 'uint32';
        INTEGER = 'int32';
        DOUBLE = 'float64';

        DELETION_INDICATOR_LENGTH = 1;
        % Header indices
        FILE_HEADER_LENGTH = 32;
        FIELD_RECORD_LENGTH = 32;
        HEADER_TERMINATOR = 13;
        HEADER_TERMINATOR_LENGTH = 1;
        FILE_TERMINATOR = 26;

        % DBF_VERSION
        DBF_VERSION_OFFSET = 0;
        DBF_VERSION_NUMVALS = 1;
        DBF_VERSION_DATATYPE = 'uint8';

        % DATE_MODIFIED
        DATE_MODIFIED_OFFSET = 1;
        DATE_MODIFIED_NUMVALS = 3;
        DATE_MODIFIED_DATATYPE = 'uint8';

        % NUM_RECORDS
        NUM_RECORDS_OFFSET = 4;
        NUM_RECORDS_NUMVALS = 1;
        NUM_RECORDS_DATATYPE = 'uint32';

        % HEADER_LENGTH
        HEADER_LENGTH_OFFSET = 8;
        HEADER_LENGTH_NUMVALS = 1;
        HEADER_LENGTH_DATATYPE = 'uint16';

        % RECORD_LENGTH
        RECORD_LENGTH_OFFSET = 10;
        RECORD_LENGTH_NUMVALS = 1;
        RECORD_LENGTH_DATATYPE = 'uint16';

        % TABLE_FLAGS
        TABLE_FLAGS_OFFSET = 28;
        TABLE_FLAGS_NUMVALS = 1;
        TABLE_FLAGS_DATATYPE = 'uint8';

        % CODEPAGE
        CODEPAGE_OFFSET = 29;
        CODEPAGE_NUMVALS = 1;
        CODEPAGE_DATATYPE = 'uint8';

        % FIELD_NAME
        FIELD_NAME_OFFSET = 0;
        FIELD_NAME_NUMVALS = 11;
        FIELD_NAME_DATATYPE = '11*uint8=>char';
        FIELD_WRITE_NAME_DATATYPE = '11*uint8';

        % FIELD_TYPE
        FIELD_TYPE_OFFSET = 11;
        FIELD_TYPE_NUMVALS = 1;
        FIELD_TYPE_DATATYPE = 'uint8=>char';
        FIELD_WRITE_TYPE_DATATYPE = 'uint8';

        % FIELD_LENGTH
        FIELD_LENGTH_OFFSET = 16;
        FIELD_LENGTH_NUMVALS = 1;
        FIELD_LENGTH_DATATYPE = 'uint8';

        % FIELD_PRECISION
        FIELD_PRECISION_OFFSET = 17;
        FIELD_PRECISION_NUMVALS = 1;
        FIELD_PRECISION_DATATYPE = 'uint8';

        % FIELD_FLAGS
        FIELD_FLAGS_OFFSET = 18;
        FIELD_FLAGS_NUMVALS = 1;
        FIELD_FLAGS_DATATYPE = 'uint8';
    end
    
    methods
    end
    
end

