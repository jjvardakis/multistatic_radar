function  frame=persistence(X, k, hold, decay)
%     Add persistence (digital phosphor) effect to sequence of frames
    
%     Parameters: 
%     X: Input frame stack (NxMxL matrix)
%     k: index of frame to acquire
%     hold: number of samples to persist
%     decay: frame decay rate (should be less than 1)
    
%     Returns:
%     frame: (NxM matrix) frame k of the original stack with persistence added'''
    frame = zeros(size(X,1),size(X,2));
    for i=1:hold
        if (k-i > 0)
            frame = frame + X(:,:,k-i)*decay^i;
        end
    end
end