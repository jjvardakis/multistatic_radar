function [valid_meas,volume]=val_gate(meas_matrix,track,gamma)
valid_meas=[];
for k=1:size(meas_matrix,1)
    v=meas_matrix(k,1:2)-[track.kalman_state.x(1) track.kalman_state.x(3)];
    v(1)=v(1)/1000;
    g=v/(track.kalman_state.S)*v.'
    if(g<=gamma)
        valid_meas=[valid_meas;meas_matrix(k,:)];
    end
end
volume=pi*gamma*det(track.kalman_state.S)^(1/2);


