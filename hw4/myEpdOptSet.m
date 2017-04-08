function epdOpt=myEpdOptSet
% myEpdOptSet: Returns the options (parameters) for EPD

epdOpt.frameSize = 256;
epdOpt.overlap = 0;
epdOpt.volumeRatio = 0.1;


epdOpt.frameDuration=256/8000;		% Frame size (fs=16000 ===> frameSize=256)
epdOpt.overlapDuration=0;		% Frame overlap
% The followings are mainly for method='vol'
epdOpt.volRatio=0.1;
epdOpt.vMinMaxPercentile=3;
% For method='volzcr';
epdOpt.volRatio2=0.2;	% Not used for now   
epdOpt.zcrRatio=0.1;
epdOpt.zcrShiftGain=4;
% For epdByEntropy
epdOpt.veRatio=0.1;
epdOpt.veMinMaxPercentile=3;
% For method='volhod'
epdOpt.vhRatio=0.012;	% 0.11
epdOpt.diffOrder=1;
epdOpt.volWeight=0.76;
epdOpt.vhMinMaxPercentile=2.3;		% 5.0%
epdOpt.extendNum=1;				% Extend front and back
epdOpt.minSegment=0.068;			% Sound segments (in seconds) shorter than or equal to this value are removed
epdOpt.maxSilBetweenSegment=0.416;	% 
epdOpt.minLastWordDuration=0.2;		%