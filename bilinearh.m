function interp = bilinearh(fx,fy,array, qx,qy )
% We suppose that fx and fy are linear vectors
ind(:,2)=(qx(:)-fx(1))/(fx(2)-fx(1))+1;
ind(:,1)=(qy(:)-fy(1))/(fy(2)-fy(1))+1;

    ind_0  = floor(ind);                          % top    - left
    ind_x  = ind_0;  ind_x(:,1) = ind_x(:,1) +1;  % top    - right
    ind_y  = ind_0;  ind_y(:,2) = ind_y(:,2) +1;  % bottom - left
    ind_xy = ind_0;  ind_xy     = ind_xy     +1;  % bottom - right

    alpha  = ind - ind_0;
    beta   = 1 - alpha;
    
    % check if still in array
    [sx,sy] = size(array);

    % clamp indices
    ind_0 (ind_0 <1) = 1; ind_0 (ind_0 (:,1)>sx,1)=sx; ind_0 (ind_0 (:,2)>sy,2)=sy; 
    ind_x (ind_x <1) = 1; ind_x (ind_x (:,1)>sx,1)=sx; ind_x (ind_x (:,2)>sy,2)=sy; 
    ind_y (ind_y <1) = 1; ind_y (ind_y (:,1)>sx,1)=sx; ind_y (ind_y (:,2)>sy,2)=sy; 
    ind_xy(ind_xy<1) = 1; ind_xy(ind_xy(:,1)>sx,1)=sx; ind_xy(ind_xy(:,2)>sy,2)=sy; 
    
    % convert to 1D indices (same as sub2ind but quicker)
    ind_0 (:,1) = (ind_0 (:,2)-1)*sx + ind_0 (:,1);
    ind_x (:,1) = (ind_x (:,2)-1)*sx + ind_x (:,1);
    ind_y (:,1) = (ind_y (:,2)-1)*sx + ind_y (:,1);
    ind_xy(:,1) = (ind_xy(:,2)-1)*sx + ind_xy(:,1);
    
    % compute the sum of the bilinear interpolation
    % interp = zeros(size(alpha,1),1);

        interp =          beta (:,1).*beta (:,2).*array(ind_0 (:,1));
        interp = interp + alpha(:,1).*beta (:,2).*array(ind_x (:,1));
        interp = interp + beta (:,1).*alpha(:,2).*array(ind_y (:,1));
        interp = interp + alpha(:,1).*alpha(:,2).*array(ind_xy(:,1));
y=reshape(interp,size(qx));