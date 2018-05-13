function [ phi,theta,psi ] = posture( varargin )
%   [ phi,theta,psi ] = posture( Alpha,Beta,vAlpha,vBeta,phi_0,theta_0,psi_0 )
%   ==============================OUTPUT===================================
%   phi: Row angle, rotate with x axis.
%   theta: Pitch angle, rotate with y axis.
%   psi: Yaw angle, rotate with z axis.
%   ===============================INPUT===================================
%   Alpha: Initial attack angle, up of the body velocity is positive.
%   Beta: Initial sideslip angle, velocity on the right is positive.
%   vAlpha: Angle velocity of Alpha.
%   vBeta: Angle velocity of Beta.
%   phi_0,theta_0,psi_0: Initial of Euler angle.
%   ==============================EXAMPLE==================================
%   [ phi,theta,psi ] =
%   posture(Alpha,Beta,vAlpha,vBeta,phi_0,theta_0,psi_0)
%   It is the second stage.
%   [ phi,theta,psi ] = posture(Alpha,vAlpha,phi_0,theta_0,psi_0)
%   It is the third stage.
%
%   Author:Ma Jiejing
%   By 2018-5-7
%   Alter 2018-5-10

%   ==============================Initial==================================
%   Overloading posture()
    narginchk(5,7);
    if nargin == 5
        Alpha = varargin{1};
        Beta = 0;
        vAlpha = varargin{2};
        vBeta = 0;
        phi = varargin{3};
        theta = varargin{4};
        psi = varargin{5};
        target = 90; %Alpha's target
        
        %Judge angle velocity's plus-minis
        if -90 < Alpha < 90
            vAlpha = abs(vAlpha);   %anticlockwise
        else
            vAlpha = -abs(vAlpha);  %clockwise
        end
        
    elseif nargin == 7
        Alpha = varargin{1};
        Beta = varargin{2};
        vAlpha = varargin{3};
        vBeta = varargin{4};
        phi = varargin{5};
        theta = varargin{6};
        psi = varargin{7};
        target = -90; %Alpha's target

        %Judge angle velocity's plus-minis
        if -90 < Alpha < 90
            vAlpha = abs(vAlpha);   %anticlockwise
        else
            vAlpha = -abs(vAlpha);  %clockwise
        end
        
        if Beta > 0
            vBeta = abs(vBeta);   %anticlockwise
        else
            vBeta = -abs(vBeta);  %clockwise
        end
    else
        error('ERROR:Parameter error! Please help posture.');
    end
    
    sir_W = [0;vAlpha,cBeta];
    step = 0.01;   %10ms
    n = 0;         %step numbers
    T = 0;
    %%%In order to avoid trembling, it'll turn by only one direction;In
    %%%order to avoid diverge, delta >= ²½³¤
    delta = max(abs(vAlpha),abs(vBeta)) * step;
    fp = fopen('posture.txt','wt');
    fprintf(fp,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r',phi,theta,psi,Alpha,Beta,0,0,0);
    
%   ===============Alpha turn to -90 or 90/Beta turn to 0==================
%   Hypothesis the turning of Beta and Alpha is synchronous.
    while abs(Alpha - target) > delta
        Alpha = Alpha + vAlpha * step;  %Integral
        
        %mod
        if Alpha >= 180
            Alpha = Alpha - 360;%second stage mod,clockwise.
        elseif Alpha <= -180
            Alpha = Alpha + 360;%third stage mod,anticlockwise.
        end
        
        if abs(Beta) > delta
            Beta = Beta + vBeta * step;%Beta > 0, vBeta < 0
            %Beta don't need to mod.
        else
            air_W = [0;vAlpha;0];
        end

%       air sys angle velocity turn to body sys.
        body_W = DCM.Lba(deg2rad(Alpha),deg2rad(Beta)) * air_W;
        [p,q,r] = deal(body_W(1),body_W(2),body_W(3));
        [ phi,theta,psi ] = transform(p,q,r,step,phi,theta,psi,false);
        
        fprintf(fp,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r',phi,theta,psi,Alpha,Beta,p,q,r);
        n = n + 1;
        T = T + step;
    end
    
    %Alhpa has done,but Beta has not, then continue turn Beta all alone.
    air_W = [0;0;vBeta];
    while abs(Beta) > delta
        Beta = Beta + vBeta * step;%Beta > 0, vBeta < 0
        body_W = DCM.Lba(deg2rad(Alpha),deg2rad(Beta)) * air_W;
        [p,q,r] = deal(body_W(1),body_W(2),body_W(3));
        [ phi,theta,psi ] = transform(p,q,r,step,phi,theta,psi,false);
        
        fprintf(fp,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r',phi,theta,psi,Alpha,Beta,p,q,r);
        n = n + 1;
        T = T + step;
    end
    
    fclose(fp);
%   Draw the change of Euler angle with time
    posture_angle = load('posture.txt');
    t = 0:0.01:roundn(T,-2);
    plot(t,posture_angle(:,1),'-r');
    hold on;
    plot(t,posture_angle(:,2),'--g');
    plot(t,posture_angle(:,3),'-.b');
    plot(t,posture_angle(:,4),'.y');
    plot(t,posture_angle(:,5),'.');
    legend('\phi','\theta','\psi','\alpha','\beta');
    hold off;
end

