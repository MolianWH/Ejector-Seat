function third(object)
%third(object):
%     It shows the rhird stage of the chair-person system. In thhis stage,
%   it includes three parts: Person's posture angle, Chair's moving
%   route,Person's moving route. In this func,it shows the last tow part,
%   The first parts please see the func posture()
%   ===============================Example=================================
%   third('chair') or third('person')
%   ================================INPUT==================================
%   phi: Row angle, rotate with x axis.
%   theta: Pitch angle, rotate with y axis.
%   psi: Yaw angle, rotate with z axis.
%   Alpha: Initial attack angle, up of the body velocity is positive.
%   Beta: Initial sideslip angle, velocity on the right is positive.
%   m_chair: Chair's quality.
%   m_person: Person's quality.
%   h0: Initial hight of chair.
%   v_chair_air: Velocity value of chair in air system.
%   A: Aerodynamic force. It includes three forces D/C/L.
%   area_chair: Area of Chair system.
%   area_person: Area of person and parachute system.
%   g: Factor of Gravity.
%   k: Factor of Aerodynamic forces.
%   rho: Density of air.
%   ==============================OUTPUT===================================
%   t: Time
%   s: Route vetocr.
%
%   Author: Ma Jiejing
%   By 2018-5-10
%   Alter 2018-5-11

%   ==============================Initial==================================

    phi = deg2rad(0);
    theta = deg2rad(0);
    psi = deg2rad(0);
    Alpha = deg2rad(0);
    Beta = deg2rad(0);
    
    v_chair_air = 20;%m/s
    v_person_air = 10;
    m_chair = 100;
    m_person = 75;
    h0 = 5000;
    g = 9.8;
    k = 0.45;
    rho = 1.29;
    area_chair = 1;
    area_person = 42;
    
    s = [0;0;0];
    
    step = 0.01;
    t = 0;
    delta = 1.0e-3;
    
    %air velocity to body
    v_chair_body = DCM.Lba(Alpha,Beta) * [v_chair_air;0;0];
    v_person_body = DCM.Lba(ALpha,Beta) * [v_person_air;0;0];
    if strcmp(object,'chair')
        v_body = v_chair_body;
        area = area_chair;
        m = m_chair;
        fp = fopen('chair_route.txt','wt');
    elseif strcmp(object,'person')
        v_body = v_person_body;
        area = area_person;
        m = m_person;
        fp = fopen('person_route.txt','wt');
    else
        error('ERROR:See help third');
    end
    
    Ab = -0.5 * rho * v_body.^2 * k * area;
    Ab(2) = -Ab(2);
    G = m * DCM.Lbg(phi,theta,psi) * [0;0;g];
    F = G + Ab;
    dV_b = F./m;
    if strcmp(object,'chair')
        target = (h0 - s(3))>delta;
    elseif strcmp(object,'person')
        target = (norm(dV_b)>delta)&&((h0 - s(3))>delta);
    end
    
    fprintf(fp,'%f\t%f\t%f\t%f\t%f\r',0.0,s(1),s(2),s(3),norm(v_body));
%   ======================Differential & Integral==========================
    while target
        %Differential body velocity
        dV_b = F./m;
        %Integral to get vb
        v_body = v_body + dV_b * step;
        
        %Convert veloctiy in body coordinate system to ground system
        Vg = DCM.Lgb(phi,theta,psi) * v_body;
        
        %Integral to get position
        s = s + Vg * step;
        t = t + step;
        
        %Analysis force in body system
        Ab = -0.5 * rho * v_body.^2 * k * area;
        Ab(2) = -Ab(2);
        F = G + Ab;
        if strcmp(object,'chair')
            target = (h0 - s(3))>delta;
        elseif strcmp(object,'person')
            target = (norm(dV_b)>delta)&&((h0 - s(3))>delta);
        end
        fprintf(fp,'%f\t%f\t%f\t%f\t%f\r',t,s(1),s(2),s(3),norm(v_body));
    end
    
    fclose(fp);
    if strcmp(object,'chair')
        position = load('chair_route.txt');
    elseif strcmp(object,'person')
        position = load('person_route.txt');
    end
    
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

