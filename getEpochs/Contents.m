% GETEPOCHS
%
% Files
%   xtp_convertEpochs          - converts epochs from numeric format (#
%                                seconds since 7/30/07 to date format
%   xtp_convertSegments        - takes segments in date format and converts
%                                them to # seconds since origin (7/30/07)
%   xtp_countEpochs            - counts the # of epochs for each condition
%                                in an epoch list variable that is
%                                organized by condition.
%   xtp_getEpochs              - select epochs from a list of clean segments
%   xtp_insertEpoch            - adjusts epochs for missing segment. the
%                                epoch list variable is organized by
%                                condition.
%   xtp_printEpochs            - prints the number of epochs for each
%                                condition in an epochlist variable that is
%                                organized by condition. 
%   xtp_readEpochs             - reads an epoch list file and creates an
%                                epoch list variable for use by
%                                xtp_cutSnippets
