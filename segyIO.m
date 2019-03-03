%% Note
% Ready segy from two lab measurements and write out a merged segy
% crews toolbox must be added to path; 
% reference directory :crews/segy; 
% ref files: 'examplecode.m', 'readsegy.m', 'writesegy.m'
%% segy file path
clear;
fDir = 'C:\DFiles\Geophysics\Project\LabModel\LabMeasurement_062018\DelayTest_02282019';
nsample = 3000; dt = 100; %us
nrepeat = 20; 
% delay test from 06/14/2018
f1 = '3LPSp300W100WY061918-DelayTest.sgy'; % 60 repeats (source and receiver at the same spotss)
% delay test from 02/28/2019
fList = {'Delay-Psph300-0221819.sgy', 'Delay-Psph300-0221819-2.sgy', 'Delay-Psph300-0221819-3.sgy',...
    'Delay-Psph300-0221819-offset20mm.sgy'};
% The first three files have only one receiver location; each with 20
% repeated recording; the last one has 11 receiver locations; starting with
% zero offset and receiver moves 20 mm. Each recording is repeated 20 times
%% read segy and stack
[trcdat,segyrevision,sampint,fmtcode,txtfmt,bytorder,txthdr,binhdr,exthdr,trchdr,bindef,trcdef]=...
    readsegy(fullfile(fDir, f1));
dataOut = zeros(nsample, 15);
dataOut(:, 1) = mean(trcdat, 2);
for i=1:3
    tmp = readsegy(fullfile(fDir, cell2mat(fList(i))));
    dataOut(:, 1 + i) = mean(tmp, 2);
end
trcdata = readsegy(fullfile(fDir, cell2mat(fList(4))));
for i = 1: size(trcdata, 2)/nrepeat
    dataOut(:, 4+i) = mean(trcdata(:, 1+(i-1)*nrepeat : i * nrepeat), 2);
end
%% write stacked traces as segy
% textural header
txthdrOut = txthdr;
txthdrOut(2, :) = pad('C02 Physical Model Data Acquistion System     Date:06/14/2018, 02/28/2019 ', 80);
txthdrOut(4, :) = pad('C04 Project: delay test for crosswell measurements', 80);
txthdrOut(5, :) = pad('C05 System: SOLID             Units: METERS        Scale:   1000', 80);
txthdrOut(6, :) = pad('C06 Receiver Channels: 15      First trace acquired in 2018; the rest in 2019', 80);
txthdrOut(7, :) = pad('C07 y offset of the 1st-5th trace is 0 and increases 20mm afterwards', 80);
txthdrOut(24, :) = pad('C24 Sample Rate:         100 us', 80);
txthdrOut(27, :) = pad('C27 Time Scale:         1000', 80);

% binary header
bhdr = SegyBinaryHeader;
bhdr.SamplesPerTrace = nsample; bhdr.SegyRevision = 0; bhdr.SampleInterval = dt; bhdr.FormatCode = 1;
[binhdrOut, bindef] = bhdr.new;
binhdrOut.DataTrcPerEns = 1; 

% trace header
trc = SegyTrace; %Create a new SegyTrace object
trc.SegyRevision = 0; %Update SegyRevision
trc.FormatCode = 1; 

ntrace=15;
[trchdr, trcdat, trcdef] = trc.new(ntrace, nsample, dt); %Return new trace header, trace data and trace definition
trchdr.TrcNumFile = int32(1:15);
trchdr.FieldRecNum = int32(ones(1, 15));
trchdr.GroupY(6:15) = int32(20:20:200);
trchdr.SrcRecOffset = trchdr.GroupY;
trchdr.CoordScalar = int16(ones(1,15));
trchdr.ShotPointNum = int32(ones(1, 15));
writesegy(fullfile(fDir, 'DelayTest.sgy'),dataOut, 0, 1e-4, 1, 'ascii', ...
               'b', txthdrOut,binhdrOut,[], trchdr, bindef, trcdef,0);
