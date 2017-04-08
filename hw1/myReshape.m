function B = myReshape(A)
pixel = size(A,1)*size(A,2);
B=reshape(A(:,:,1), 1, pixel);
B=[B; reshape(A(:,:,2), 1, pixel)];
B=[B; reshape(A(:,:,3), 1, pixel)];
end