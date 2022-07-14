clc
clear all
% close all
%path = 'TwoHumanData\';
rawDataReader('2243.setup.json','adc_data','datacube',0);
load('adc_data');
load('datacube');

mmWaveJsonFileName = '2243.mmwave.json';
mmWaveJSON = jsondecode(fileread(mmWaveJsonFileName));

ConfigParams = mmWaveJSON.mmWaveDevices.rfConfig.rlProfiles.rlProfileCfg_t;

% Radar parameters
c               = 3e8;
fstart          = adcRawData.rfParams.startFreq*1e9;
numADCSamples   = adcRawData.rfParams.numRangeBins;
fs              = adcRawData.rfParams.sampleRate*1e6;
Slope           = adcRawData.rfParams.freqSlope*1e12; % MHz/us
idleTime        = ConfigParams.idleTimeConst_usec*1e-6;
adc_start_time  = ConfigParams.adcStartTimeConst_usec*1e-6;
f0              = fstart+Slope*adc_start_time;
lambda          = c/f0;
adc_sample_time = numADCSamples/fs;
f1              = fstart+Slope*(adc_start_time+adc_sample_time);
BW              = f1 - f0;
rampEndTime     = ConfigParams.rampEndTime_usec*1e-6;
rangeRes        = c/(2*BW);
Tcri            = rampEndTime + idleTime;
fcrf            = 1/Tcri;
tbar            = (0:numADCSamples-1)/fs;

ch_1F           = squeeze(radarCube.data{50}(:,3,:));

TotalChirps     = adcRawData.rfParams.numDopplerBins;
fst             = (0:TotalChirps-1)/TotalChirps*fcrf;
nch             = radarCube.dim.numRxChan;

f               = (0:numADCSamples-1)/numADCSamples*fs;
ridx            = c*f/(2*Slope);%-c*fs/(2*2*Slope);
avgFTsig        = mean(ch_1F.',2).';
% avgFTsig        = avgFTsig.*(ridx.^2);
figure; plot(ridx,(abs(avgFTsig+eps)))
xlim([0 12])
% figure; plot(ridx,mean(10*log10(abs(ch_1F).'+eps),2))
% % xlim([0,10])
% figure;imagesc(10*log10(abs(ch_1F)))

f_stidx        = (-TotalChirps/2:TotalChirps/2-1)/TotalChirps*fcrf;
% ch_1F          = ch_1F - (ones(TotalChirps,1)*mean(ch_1F,1));
ch_2F          = fftshift(fft(ch_1F,[],1),1);
figure; 
imagesc(ridx,f_stidx,10*log10(abs(ch_2F)))
% , [30 50]
% xlim([0 10])
axis xy
title('Range Doppler Map')
xlabel('Range (m)')
ylabel('Doppler Frequency (Hz)')
xlim([0 11])