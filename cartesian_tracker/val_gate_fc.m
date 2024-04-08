function [valid_meas,t]=val_gate_fc(bist_meas,x,track,tx,rx)
gamma=50000;
valid_meas=[];
t=zeros(size(bist_meas,1),size(bist_meas,2)-2);
for i=1:size(bist_meas,1)
%     rx_assoc=track.bistatic_pairs;
    for k=1:size(bist_meas,2)-2
        rx_index=k;
        zb=[bist_meas{k}(1);bist_meas{k}(2)];
        S=track.kalman_state.S((rx_index-1)*2+1:(rx_index-1)*2+2,(rx_index-1)*2+1:(rx_index-1)*2+2);
        trgt_pos=[x(1) x(3) x(5)];
        V=[x(2); x(4); x(6)];
        trgt_tx= norm(tx-trgt_pos);
        trgt_rx= norm(rx(rx_index,:)-trgt_pos);
        tx_trgt_rx=trgt_tx+trgt_rx;
        Vt=(trgt_pos-tx)*V/norm((trgt_pos-tx))+(trgt_pos-rx(rx_index,:))*V/norm((trgt_pos-rx(rx_index,:)));
        v=(zb.'-[tx_trgt_rx Vt]);
        t(i,k)=v/(S)*v.';
%         [t(i,k) rx_index]
    end
    if(mean(t(i,:))<=gamma)
        valid_meas=[valid_meas;bist_meas];
    end
end
valid_meas
t
end

% function meas=assoc_meas_fc(valid_meas,track,rx_index,gamma)
% meas=[];
% for i=1:size(valid_meas,1) % for each measurement
%     for j=1:size(valid_meas(i),2)
%         innov=valid_meas(j,7+2*(rx_index-1):7+2*(rx_index-1)+1).'-track.bistatic_values(:,rx_index);
%         innov(1)=innov(1)/1e3;
%         temp=innov.'*track.kalman_state.S((rx_index-1)*2+1:(rx_index-1)*2+2,(rx_index-1)*2+1:(rx_index-1)*2+2)*innov;
%         if(t<gamma)
%             meas=valid_meas(i,:);
%         end
%     end
% end    