function x2=offset_compensation2(x1,x2,ndec)
s1=x1(1:1000);
s2=x2(1:1000);
os=find_channel_offset(s1,s2,ndec)
if(os==0)
    return;
else
    x2=shift(x2,os);
end
end