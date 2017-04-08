function x = sortInv(x2, index)
x = zeros(1,100);
for i = 1:100
    x(index(i)) = x2(i);
end
end