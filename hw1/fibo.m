function answer = fibo(n)
s5 = sqrt(5) / 2;
answer = power(0.5 + s5, n - 1) - power(0.5 - s5, n - 1);
answer = answer / s5 * 0.5;
end