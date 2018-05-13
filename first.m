function [ Sg,Vg,Vb ] = first()
%first: [ Sg,Vg,Vb ] = first()
%     It is the first stage of the ejector seat's moving.
%     This pro/func will get the track of the chair and plot its' three
%   sections.Test data is saved in the document named 'µ¯Éä×ùÒÎ'.
%   ==============================OUTPUT===================================
%   sg: Position vector in ground coordinate system.
%   vg: Velocity vector in ground coordinate system.
%   vb: Velocity vector in body coordinate system.
%   ==============================INPUT====================================
%   phi: Row angle, rotate with x axis.
%   theta: Pitch angle, rotate with y axis.
%   psi: Yaw angle, rotate with z axis.
%   fix_angle: Also named established angle of rocket.
%   vp: Initial velocity with plane direction.
%   vf: Initial velocity with rocket force direction.
%   alpha: angle of incidence.
%   beta: angle of sideslip.
%   f: Force of rocket.
%   m: Quality of person and chair system.
%   step: Integral step.
%   mTIME: Integral time.
%
%   Author:Ma Jiejing.
%   By 2018-4-28
%   Aoter 2018-5-7

%   =============================Initilizate===============================
    %alpha = 0;
    %beta = 0;
    phi = deg2rad(30);
    theta = deg2rad(30);
    psi = deg2rad(30);
    fix_angle = deg2rad(10);
    u0 = 222; %m/s
    v0 = 0;
    w0 = 0;
    Vf = 17;  %m/s
    f = 15925;%N
    m = 100;  %kg
    g = DCM.Lbg(phi,theta,psi) * [0;0;9.8];
    
    Vb(1) = u0 - Vf * sin(fix_angle);
    Vb(2) = v0;
    Vb(3) = w0 - Vf * cos(fix_angle);
    
    F(1) = -f * sin(fix_angle) + m * g(1);
    F(2) = m * g(2);
    F(3) = -f * cos(fix_angle) + m * g(3);
    
    %diffrential of vb
    dVb = F'/m;
    
    fp = fopen('position.txt','wt');
    step = 0.01;
    mTIME = 0.4;
    N = mTIME/step;
    M = N;
    Sg = [0;0;0];
    Vb = Vb';
    fprintf(fp,'%f\t%f\t%f\t%f\r',0.0,Sg(1),Sg(2),Sg(3));
    
    while N>0
        %Integral to get vb
        Vb = Vb + dVb * step;
        N = N - 1;
        
        %Convert velocity in body coordinate system to ground system
        Vg = DCM.Lgb(phi,theta,psi) * Vb;
        
        %Integral to get position
        Sg = Sg + Vg * step;
        
        fprintf(fp,'%f\t%f\t%f\t%f\r',step*(M-N),Sg(1),Sg(2),Sg(3));
    end
    
    fclose(fp);
    position = load('position.txt');
    x = position(:,2);
    y = position(:,3);
    z = position(:,4);
    h = -z;
    subplot(1,3,1),plot(x,y);
    xlabel('x'),ylabel('y');
    subplot(1,3,2),plot(y,h);
    xlabel('y'),ylabel('h');
    subplot(1,3,3),plot(x,h);
    xlabel('x'),ylabel('h');
 
end

