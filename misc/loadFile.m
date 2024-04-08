function y = loadFile(fid,origin,chunksize)
%  y = loadFile(filename)
%
% reads  complex samples from the rtlsdr file
%
%  fseek(fid,origin,-1);
%  y1 =fread(fid,chunksize,'float32');
y1 =fread(fid,chunksize,'float');
% ftell(fid)
%y = y-127.5;
%y=origin;
if(size(y1(1:2:end))==size(y1(2:2:end)))
    y = complex(double(y1(1:2:end)),double(y1(2:2:end)));
else
    y=complex(zeros(1,10));
end
		
