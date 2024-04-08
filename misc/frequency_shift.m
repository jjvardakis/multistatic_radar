function x_shifted=frequency_shift(x,fc,Fs)
nn=(1:length(x));
x_shifted=x.*exp(1i*2*pi*fc*nn/Fs);  
end