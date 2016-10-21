% The Preprocessor is composed of following functions, each located in a
% subdirectory of the Preprocessor directory. For help on the listing of
% files in any given subdirectory, type help Preprocessor/<subdirectory>.
% For example: help Preprocessor/analysis. For help on how to use any
% individual function, type help <functionname>, e.g. help xtp_show
%
%   SCRUB
%  
%   Files
%     scrub      - generates a copy of the input file with patient name data
%                  removed from lines 2 and 7.
%     scrubem    - calls scrub iteratively for multiple files you specify.
% 
%   ENVIRONMENT
%  
%   Files
%     xtp_build_environment         - creates global vriables for use with
%                                     XTP preprocessor routines
% 
%   GETEPOCHS
%  
%   Files
%     xtp_convertEpochs          - converts epochs from numeric format (#
%                                  seconds since 7/30/07 to date format
%     xtp_convertSegments        - takes segments in date format and converts
%                                  them to # seconds since origin (7/30/07)
%     xtp_countEpochs            - counts the # of epochs for each condition
%                                  in an epoch list variable that is
%                                  organized by condition.
%     xtp_getEpochs              - select epochs from a list of clean segments
%     xtp_insertEpoch            - adjusts epochs for missing segment. the
%                                  epoch list variable is organized by
%                                  condition.
%     xtp_printEpochs            - prints the number of epochs for each
%                                  condition in an epochlist variable that is
%                                  organized by condition. 
%     xtp_readEpochs             - reads an epoch list file and creates an
%                                  epoch list variable for use by
%                                  xtp_cutSnippets
% 
%   PREPROCESS
%  
%   Files
%     xtp_preprocess                 - Composite function to call all the
%                                      subfunctions necessary to read XLT
%                                      files, cut snippets, montage data,
%                                      prefilter and filter.
% 
%   READFILE
%  
%   Files
%     xtp_readXLTfile         - given an XLTek export file, and optionally a
%                               number of leads to read, generates a matlab
%                               structure array containing the EEG data
%     xtp_checkEOF            - Returns the next two lines of the specified 
%                               file, as a sanity check to see if all
%                               relevant data has been read.
%     xtp_consolidateXLTfiles - (may be obsolete)
%     xtp_readXLTfiles        - (not currently supported)
% 
%   CUTSNIPPETS
%  
%   Files
%     xtp_cutSnippets               - given a data structure containing
%                                     filedata (output from xtp_readXLTfile)
%                                     and a list of epoch start and end times
%                                     (or start times and durations), returns
%                                     a matlab structure (snippets).
% 
%   MONTAGE
%  
%   Files
%     xtp_montage         - Given a data structure containing one or more
%                           snippets of eeg data, produces a montaged version
%                           of that data using the headbox/montage provided.
% 
%   PREFILTER
%  
%   Files
%     xtp_prefilter      - given a datastructure containing (montaged) eeg
%                          data, transforms each snippet to a matlab
%                          timeseries and detrends the data.
% 
%   FILTER
%  
%   Files
%     xtp_filter       - Takes an XLTek preprocessor data structure (with
%                        fields metadata and data) and applies the filters as
%                        specified by the PARAMS fields 
% 
%   PLOT
%  
%   Files
%     xtp_plot      - Plots timeseries data that has been read from XLTek
%                     export files into an XTP variable. Assumes the data has
%                     been cut into snippets and montaged.
% 
%   MTSPECTRUMC
%  
%   Files
%     xtp_mtspectrumc                       - calls mtspectrumc for data
%                                             exported from XLTek using XTP 
%     xtp_subplotSpectra                    - calls xtp_plotSpectra for all channels
%     xtp_plotSpectra                       - Plots two xtp spectral
%                                             structures (as output from
%                                             xtp_mtspectrumc) in a single figure.
%     xtp_plotSpectraByChannel              - (may be obsolete)
%     xtp_plotSpectraByCondition            - (may be obsolete)
%     xtp_subplotCompositeSpectra           - (may be obsolete) calls xtp_plotCompositeSpectra for all channels. input a cell array of
%     xtp_plotCompositeSpectra              - (may be obsolete) Plots multiple xtp spectral structures (as output from xtp_mtspectrumc,
% 
%   COHERENCYC
%  
%   Files
%     xtp_coherencyc       - This function calls chronux coherencyc for each pair of leads specified.
%     xtp_plotCoherency    - Plots two coherency traces on the same axis, with error bars if given.
% 
%   ANALYSIS
%  
%   Files
%     xtp_powerBand             - Given a power spectrum, generates the
%                                 corresponding spectrum with total power
%                                 integrated over frequency bands you specify.
%     xtp_shuffle               - Shuffles data from trials among several spectra. 
%     xtp_shuffleWrapper        - iteratively repeats a call to xtp_shuffle,
%                                 running a test statistic of your choice on
%                                 the shuffled data.
%     xtp_findPvals             - hardcoded function to generate p values
%                                 given a list of variances that that were
%                                 calculated as output from xtp_shuffleWrapper.
% 
%   UTILITIES
%  
%   Files
%     xtp_aggregate          - compiles one big data structure by
%                              sequentially appending the datastructures
%                              provided.
%     xtp_makeGlobal         - converts local variables to global variables.
%                              useful if you've forgotten to make your epoch
%                              list a global variable.
%     xtp_datestr            - given an integer representing number of
%                              seconds from an origin point in time, and
%                              given the origin itself, converts the number
%                              to a date in string format.
%     xtp_mirror             - converts a 2D array to its mirror image,
%                              reflected about the midline in the dimension
%                              specified. called by xtp_plotSpectra
%     xtp_orderby            - Orders vectors and matrices according to a predefined order.
%     xtp_repositionTopLabel - function to reposition the top label when a
%                              figure is resized. Keeps the label to 20
%                              pixels tall and centered in the width of the figure.
%     xtp_reSource           - This function updates the source field of the
%                              given set of spectra. It should be used with
%                              caution because it breaks the audit trail. 
%     xtp_sample             - script that generates a sample timeseries
%     xtp_localPeaks         - (not currently supported) finds the local max
%                              within a given frequency range for a list of spectra.
