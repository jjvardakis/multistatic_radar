function meas=assoc_meas(valid_meas,track,mode)
% 1. for NN 2. for SN 3. ...
meas=[];
distance=100000;
if(mode==1)  %  NN 
    for i=1:size(valid_meas)
        v=valid_meas(i,1:2)-[track.kalman_state.x(1) track.kalman_state.x(3)];
        dist=v/(track.kalman_state.S)*v.';
        if(dist<distance)
            meas=valid_meas(i,:);
        end
    end
    
else % SN
    for i=1:size(valid_meas)
        [~,I]=max(valid_meas(:,3));
        meas=valid_meas(I,:);
    end
    
end