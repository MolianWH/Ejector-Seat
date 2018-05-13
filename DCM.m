classdef DCM
    %DCM: the cosine matrix
    methods(Static)
        
        %body 2 ground coordinate system
        function L = Lgb(phi,theta,psi)
            L(1,1) = cos(theta)*cos(psi);
            L(1,2) = sin(theta)*sin(phi)*cos(psi)-cos(phi)*sin(psi);
            L(1,3) = sin(theta)*cos(phi)*cos(psi)+sin(phi)*sin(psi);
            L(2,1) = cos(theta)*sin(psi);
            L(2,2) = sin(theta)*sin(phi)*sin(psi)+cos(phi)*cos(psi);
            L(2,3) = sin(theta)*cos(phi)*sin(psi)-sin(phi)*cos(psi);
            L(3,1) = -sin(theta);
            L(3,2) = sin(phi)*cos(theta);
            L(3,3) = cos(phi)*cos(theta);
        end
        
        %ground 2 body coordinate system
        function L = Lbg(phi,theta,psi)
            L = DCM.Lgb(phi,theta,psi);
            L = L';
        end
        
        %ground 2 air
        function L = Lga(phi,theta,psi)
            L = DCM.Lgb(phi,theta,psi);
        end
        
        %air 2 ground
        function L = Lag(phi,theta,psi)
            L = DCM.Lgb(phi,theta,psi);
            L = L';
        end
        
        %air 2 body
        function L = Lba(alpha,beta)
            L(1,1) = cos(alpha)*cos(beta);
            L(1,2) = -cos(alpha)*sin(beta);
            L(1,3) = -sin(alpha);
            L(2,1) = sin(beta);
            L(2,2) = cos(beta);
            L(2,3) = 0;
            L(3,1) = sin(alpha)*cos(beta);
            L(3,2) = -sin(alpha)*sin(beta);
            L(3,3) = cos(alpha);
        end %func Lba
        
        function L = Lab(alpha,beta)
            L = DCM.Lba(alpha,beta);
            L = L';
        end
    end %methods
end

