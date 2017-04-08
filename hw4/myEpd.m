function [epInSampleIndex, epInFrameIndex] = myEpd(au, epdOpt, showPlot)
% myEpd: a simple example of EPD
%
%	Usage:
%		[epInSampleIndex, epInFrameIndex] = endPointDetect(au, showPlot, epdOpt)
%			epInSampleIndex: two-element end-points in sample index
%			epInFrameIndex: two-element end-points in frame index
%			au: input wave object
%			epdOpt: parameters for EPD
%			showPlot: 0 for silence operation, 1 for plotting
%
%	Example:
%		waveFile='SingaporeIsAFinePlace.wav';
%		au=waveFile2obj(waveFile);
%		epdOpt=myEpdOptSet;
%		showPlot = 1;
%		out = myEpd(au, epdOpt, showPlot);

%	Roger Jang, 20040413, 20070320, 20130329

if nargin<1, selfdemo; return; end
if nargin<2, epdOpt=myEpdOptSet; end
if nargin<3, showPlot=0; end

% read volumes
wave=au.signal; fs=au.fs;
frameSize=epdOpt.frameSize; overlap=epdOpt.overlap;
minSegment=round(epdOpt.minSegment*fs/(frameSize-overlap));
wave=double(wave);				% convert to double data type (轉成資料型態是 double 的變數)
wave=wave-mean(wave);				% zero-mean substraction (零點校正)
frameMat=enframe(wave, frameSize, overlap);	% frame blocking (切出音框)
frameMat=frameZeroJustify(frameMat, frameSize, 4);
frameNum=size(frameMat, 2);			% no. of frames (音框的個數)
volume=frame2volume(frameMat);			% compute volume (計算音量)

temp=sort(volume);
index=round(frameNum*epdOpt.vMinMaxPercentile/100); if index==0, index=1; end
volMin=temp(index);
volMax=temp(frameNum-index+1);
volumeTh=(volMax-volMin)*epdOpt.volumeRatio+volMin;	% compute volume threshold (計算音量門檻值)
index=find(volume>=volumeTh);			% find frames with volume larger than the threshold (找出超過音量門檻值的音框)

% ====== Identify voiced part that's larger than volumeTh
soundSegment=segmentFind(volume>volumeTh);
% ====== Compute ZCR
[minVol, index]=min(volume);
shiftAmount=epdOpt.zcrShiftGain*max(abs(frameMat(:,index)));		% shiftAmount is equal to epdOpt.zcrShiftGain times the max. abs. sample within the frame of min. volume
%shiftAmount=max(shiftAmount, 2);
shiftAmount=max(shiftAmount, max(frameMat(:))/100);
zcr=frame2zcr(frameMat, 1, shiftAmount);
zcrTh=max(zcr)*epdOpt.zcrRatio;
% ====== Expansion 1: Expand end points to volume level1 (lower level)
for i=1:length(soundSegment),
	head = soundSegment(i).begin;
	while (head-1)>=1 & volume(head-1)>=volumeTh,
		head=head-1;
	end
	soundSegment(i).begin = head;
	tail = soundSegment(i).end;
	while (tail+1)<=length(volume) & volume(tail+1)>=volumeTh,
		tail=tail+1;
	end
	soundSegment(i).end = tail;
end
% ====== Expansion 2: Expand end points to include high zcr region
for i=1:length(soundSegment),
	head = soundSegment(i).begin;
	while (head-1)>=1 & zcr(head-1)>zcrTh			% Extend at beginning
		head=head-1;
	end
	soundSegment(i).begin = head;
	tail = soundSegment(i).end;
	while (tail+1)<=length(zcr) & zcr(tail+1)>zcrTh		% Extend at ending
		tail=tail+1;
	end
	soundSegment(i).end = tail;
end
% ====== Delete repeated sound segments
index = [];
for i=1:length(soundSegment)-1,
	if soundSegment(i).begin==soundSegment(i+1).begin & soundSegment(i).end==soundSegment(i+1).end,
		index=[index, i];
	end
end
soundSegment(index) = [];
% ====== Delete short sound clips
index = [];
for i=1:length(soundSegment)
	soundSegment(i).duration=soundSegment(i).end-soundSegment(i).begin+1;	% This is necessary since the duration is changed due to expansion
	if soundSegment(i).duration<=minSegment
		index = [index, i];
	end
end
soundSegment(index) = [];
zeroOneVec=logical(0*volume);
for i=1:length(soundSegment)
	for j=soundSegment(i).begin:soundSegment(i).end
		zeroOneVec(j)=1;
	end
end
if isempty(soundSegment)
	epInSampleIndex=[];
	epInFrameIndex=[];
	fprintf('Warning: No sound segment found in %s.m.\n', mfilename);
else
	epInFrameIndex=[soundSegment(1).begin, soundSegment(end).end];
	epInSampleIndex=frame2sampleIndex(epInFrameIndex, frameSize, overlap);		% conversion from frame index to sample index
	for i=1:length(soundSegment),
		soundSegment(i).beginSample = frame2sampleIndex(soundSegment(i).begin, frameSize, overlap);
		soundSegment(i).endSample   = min(length(wave), frame2sampleIndex(soundSegment(i).end, frameSize, overlap));
		soundSegment(i).beginFrame = soundSegment(i).begin;
		soundSegment(i).endFrame = soundSegment(i).end;
	end
	soundSegment=rmfield(soundSegment, 'begin');
	soundSegment=rmfield(soundSegment, 'end');
%	soundSegment=rmfield(soundSegment, 'duration');
end

% epInFrameIndex=[index(1), index(end)];
% epInSampleIndex=frame2sampleIndex(epInFrameIndex, frameSize, overlap);	% conversion from frame index to sample index (由 frame index 轉成 sample index)

if showPlot,
	subplot(2,1,1);
	time=(1:length(wave))/fs;
	plot(time, wave); axis tight;
	line(time(epInSampleIndex(1))*[1 1], [min(wave), max(wave)], 'color', 'g');
	line(time(epInSampleIndex(end))*[1 1], [min(wave), max(wave)], 'color', 'm');
	ylabel('Amplitude'); title('Waveform');

	subplot(2,1,2);
	frameTime=((1:frameNum)-1)*(frameSize-overlap)+frameSize/2;
	plot(frameTime, volume, '.-'); axis tight;
	line([min(frameTime), max(frameTime)], volumeTh*[1 1], 'color', 'r');
	line(frameTime(index(1))*[1 1], [0, max(volume)], 'color', 'g');
	line(frameTime(index(end))*[1 1], [0, max(volume)], 'color', 'm');
	ylabel('Sum of abs.'); title('Volume');
	
	U.wave=wave; U.fs=fs;
	if ~isempty(epInSampleIndex)
		U.voicedY=U.wave(epInSampleIndex(1):epInSampleIndex(end));
	else
		U.voicedY=[];
	end
	set(gcf, 'userData', U);
	uicontrol('string', 'Play all', 'callback', 'U=get(gcf, ''userData''); sound(U.wave, U.fs);', 'position', [20, 20, 100, 20]);
	uicontrol('string', 'Play detected', 'callback', 'U=get(gcf, ''userData''); sound(U.voicedY, U.fs);', 'position', [150, 20, 100, 20]);
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

function frameMat2 = frameZeroJustify(frameMat, frameSize, polyOrder)
frameMat2 = frameMat;
x = 1:frameSize;
for i = 1:size(frameMat, 2)
    y = frameMat(:, i)';
    p = polyfit(x, y, polyOrder);
    offset = polyval(p, x);
    frameMat2(:, i) = (y - offset)';
end