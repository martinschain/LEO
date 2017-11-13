# LEO
Code and sample data for Likelihood Estimation of Occupancy

This repository contains code that enables application of Likelihood Estimation of Occupancy, written by Martin Schain, Columbia University, 2017.

To execute the code, you need MATLAB. The current code has been tested using MATLAB R2016a. You may experience issues when using other MATLAB versions.

In addition to the files included in this repository, we recommend that you download the code that calculates a non-linear shrinkage of the covariance matrix. That code is downloadable from 
http://www.econ.uzh.ch/en/people/faculty/wolf/publications.html#9
under the heading: 
Ledoit O. and Wolf, M. (2017).
Numerical implementation of the QuEST function.
Computational Statistics & Data Analysis 115, 199-223.
Make sure that all the files are in your MATLAB path before running LEO.

For some mac-users, the standard routine to print data into an excel file doesn’t work well. If you use a mac, download the file cell2csv.m from
https://www.mathworks.com/matlabcentral/fileexchange/7601-cell2csv?focused=5063322&tab=function
and add it to the MATLAB path.

In this repository, you will also find two sample excel files. To execute LEO with your data, simply replace the numbers in these files with your data. The number of ROIs are arbitrarily set, but make sure that you use the same ROIs in both the test-retest data and the baseline-blocking data. Also make sure that the order the of the ROIs are consistent between the two datasets. 

If you don’t have test-retest data available, you can only run LEO using the Identity matrix in place of the covariance matrix. In the output file, you will also obtain estimates of V_ND and occupancy calculated with Lassen plot. 

For comments or questions regarding this code, please contact Martin Schain.
