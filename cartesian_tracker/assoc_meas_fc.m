function meas=assoc_meas_fc(valid_meas,track,rx_index)
meas=[];
for i=1:size(valid_meas,1) % for each measurement
    minim=1000000000;
    for j=1:size(valid_meas(i),2) % 
        innov=valid_meas(j,7+2*(rx_index-1):7+2*(rx_index-1)+1).'-track.bistatic_values(:,rx_index);
        innov(1)=innov(1)/1e3;
        temp=innov.'*track.kalman_state.S((rx_index-1)*2+1:(rx_index-1)*2+2,(rx_index-1)*2+1:(rx_index-1)*2+2)*innov;
        if(temp<minim)
            minim=temp;
            meas=valid_meas(i,:);
        end
    end
end    
