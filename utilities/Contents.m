% UTILITIES
%
% Files
%   xtp_aggregate          - compiles one big data structure by
%                            sequentially appending the datastructures
%                            provided.
%   xtp_makeGlobal         - converts local variables to global variables.
%                            useful if you've forgotten to make your epoch
%                            list a global variable.
%   xtp_datestr            - given an integer representing number of
%                            seconds from an origin point in time, and
%                            given the origin itself, converts the number
%                            to a date in string format.
%   xtp_mirror             - converts a 2D array to its mirror image,
%                            reflected about the midline in the dimension
%                            specified. called by xtp_plotSpectra
%   xtp_orderby            - Orders vectors and matrices according to a predefined order.
%   xtp_repositionTopLabel - function to reposition the top label when a
%                            figure is resized. Keeps the label to 20
%                            pixels tall and centered in the width of the figure.
%   xtp_reSource           - This function updates the source field of the
%                            given set of spectra. It should be used with
%                            caution because it breaks the audit trail. 
%   xtp_sample             - script that generates a sample timeseries
%   xtp_localPeaks         - (not currently supported) finds the local max
%                            within a given frequency range for a list of spectra.
%   xtp_show               - displays the data in environment variables
%                            such as XTP_HEADBOXES, XTP_HB_MONTAGES,
%                            XTP_COHERENCY_PAIRS
