function [ phi,theta,psi ] = transform(p,q,r,Time,phi_0,theta_0,psi_0,mDraw)
% transform input the body rate,output the Euler angle
% phi: Row angle,rotate with x axis.
% theta: Pitch angle, rotate with y axis.
% psi: Yaw angle , rotate with z axis.
%
% p: body rate of X axis component.
% q: body rate of Y axis component.
% r: body rate of Z axis component.
% Time: seconds
%
% Author: Ma Jiejing
% By 2018-4-17
% alter:2018-5-9

%=====================angle turn to radian=================================

    p = deg2rad(p);
    q = deg2rad(q);
    r = deg2rad(r);

%=====================initialize quaternions===============================

    if nargin > 4
        phi_0 = deg2rad(phi_0);
        theta_0 = deg2rad(theta_0);
        psi_0 = deg2rad(psi_0);
    elseif nargin == 4
        [phi_0,theta_0,psi_0] = deal(0);
    end
    e = angle2quat(psi_0,theta_0,phi_0,'ZYX');
    
%=====================angle turn to radian=================================
    fp = fopen('Euler.txt','wt');
    
    step = 0.01;
    n = fix(Time / step);
    
    while n > 0
        %compute rate of quaternoins
        de(1) = -0.5 * (e(2)*p+e(3)*q+e(4)*r);
        de(2) = 0.5 * (e(1)*p+e(3)*r-e(4)*1);
        de(3) = 0.5 * (e(1)*q+e(4)*p-e(2)*r);
        de(4) = 0.5 * (e(1)*r+e(2)*q-e(3)*p);
        
        %integrate
        e = e + de * step;
        %normalaze
        e = e / norm(e);
        
        n = n - 1;
        %quaternoins turn to Euler angle
        [psi,theta,phi] = quat2angle(e,'ZYX');
        
        %radian turn to angle
        psi = rad2deg(psi);
        theta = rad2deg(theta);
        phi = rad2deg(phi);
        
        fprintf(fp,'%f\t%f\t%f\r',phi,theta,psi);
    end
    
    fclose(fp);
    
    if mDraw
        %Draw the change of Euler angle with time
        Euler = load('Euler.txt');
        t = 0.01:0.01:fix(Time/step)*0.01;
        plot(t,Euler(:,1),'-r');
        hold on;
        plot(t,Euler(:,2),'.y');
        plot(t,Euler(:,3),'b');
        legend('\phi','\theta','\psi');
        hold off;
    end
end

end

