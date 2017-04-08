function outputSignal = mySine(duration, freq)
fs=16000;
time=(0:duration*fs-1)/fs;
outputSignal=sin(2*pi*(0.5*((freq(2)-freq(1))/time(end))*time.^2+freq(1).*time));
end