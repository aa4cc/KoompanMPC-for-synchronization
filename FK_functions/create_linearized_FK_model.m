function [sys_d, sys_c] = create_linearized_FK_model(fk_params, Ts)
%create_linearized_FK_model: linearization around the system's origin

% INPUTS:
%%% Ts:         Sampling period
%%% fk_params:  Parameters of the FK model

% OUTPUTS:
%%% sys_d: discrete-time system
%%% sys_c: continuous-time system



f_origin = fk_params.f_origin;
N = fk_params.N;

m = fk_params.m; 
l = fk_params.l;                           
gamma = fk_params.gamma;                     
b = fk_params.b;                     
k = fk_params.k;                        
J = fk_params.J;       
g = fk_params.g;       

% NOTES:
%%% The complexity of the code is caused by allowing pendulums with
%%% different weigths but it is not used in these simulations

m = m*ones(N, 1);
J = J*ones(N, 1);


adj_mat = (diag(ones(1,N-1), 1) + diag(ones(1,N-1), -1));
L = (diag(sum(adj_mat)) - adj_mat);
D = zeros(size(L));
D(1,1) = 1;

B = [0;1];
K = [k,b];

if f_origin == 0    % Equilibrium in downward position
    A_c = kron(eye(N), [0, 1; -g*l, -gamma]) ;
else            % Equilibrium in inverse (upward) position
    A_c = kron(eye(N), [0, 1; g*l, -gamma]) ;
end


for ii = 1:N
    A_c(2*ii, 2*ii-1) = A_c(2*ii, 2*ii-1)*m(ii);
end

A_c = A_c - kron(L+D, B*K);

for ii = 1:N 
    A_c(2*ii,:) = A_c(2*ii,:)/J(ii);
end

B_c = [0; 1/J(1); zeros(2*(N-1), 1)];
 
C = eye(2*N);

sys_c = ss(A_c,B_c,C,0);
sys_d = c2d(sys_c, Ts);

end