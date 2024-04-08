function x2=shift(x1,n)
if(n==0)
    x2=x1;
elseif(n>0)
    x2=complex(zeros(size(x1)));
    x2(1:n)=0;
    x2(n+1:end)=x1(1:end-n);
else
    x2=complex(zeros(size(x1)));
    x2=[x1(1:end-abs(n)) complex(zeros(1,length(x1(end-abs(n)+1:end))))];
end
end