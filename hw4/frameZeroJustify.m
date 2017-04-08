function frameMat2 = frameZeroJustify(frameMat, frameSize, polyOrder)
frameMat2 = frameMat;
x = 1:frameSize;
for i = 1:size(frameMat, 2)
    y = frameMat(:, i)';
    p = polyfit(x, y, polyOrder);
    offset = polyval(p, x);
    frameMat2(:, i) = (y - offset)';
end
end