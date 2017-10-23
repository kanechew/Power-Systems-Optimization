% ---------------------------------------------------------------------- %
% Title:        ECE 69500 Homework #7                                    %
% Question:     Example 8D (Page 388)                                    %
% Problem:      Security Constrained Optimal Power Flow                  %
%               DC Power Flow and Quadratic Programming                  %
% Data:         Appendix 8B (Page 393)                                   %
% ---------------------------------------------------------------------- %
% Author:       Yun Zhi Chew (PURDUE UNIVERSITY)                         %
% ---------------------------------------------------------------------- %

% Format Output
% ---------------------------------------------------------------------- %
clear all;
clc;
format short;

% Methodology / Algorithm
% ---------------------------------------------------------------------- %

% Algorithm:    Quadratic Programming
% Syntax:       x = quadprog (H,f,Ae,be,Aeq,beq,lb,ub)
%
% Description:  min 1/2 x' * H * x + f' * x
% Subject to:   Ae  * x <= be   (Inequality)
%               Aeq * x  = beq  (Equality)
%               lb <= x <= ub   (Upper and Lower Bounds)

% Problem Initialization
% ---------------------------------------------------------------------- %

% Unknown Variable Matrix x (1 by 18)
% ---------------------------------------------------------------------- %
% x     = [P1  P2  P3  P4  P5  P6  T1 T2 T3 T4 T5 T6 T7 T8 T9 T10 T11 T12]

% Upper & Lower Bound (From Generator Data)
% ---------------------------------------------------------------------- %
% Assume no constraints for phase angle
ub      = [200 150 180 200 150 180 0  inf inf inf inf  inf inf inf inf inf inf inf ];
lb      = [50  37.5 45 50  37.5 45 0 -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf ];

% Minimization Function (From Generator Cost Functions)
% ---------------------------------------------------------------------- %

% Coefficient a 
a = [319.65, 300, 360, 213.1, 200, 240];

% Coefficient b 
f = [17.5035, 15.4995, 16.2495, 11.669, 10.333, 10.833 ...
     0 0 0 0 0 0 0 0 0 0 0 0 ]' % twelve zeros

% Coefficient c
H = zeros (18);
H(1,1) = 2 * 0.007995;
H(2,2) = 2 * 0.013335;
H(3,3) = 2 * 0.011115;
H(4,4) = 2 * 0.00533;
H(5,5) = 2 * 0.00889;
H(6,6) = 2 * 0.00741;

H

% Equality Constraints
% ---------------------------------------------------------------------- %
% Aeq * x = beq 

% beq Matrix (From Bus Data)
beq     = [0 0 0 110 110 110  0  0  0  50  50  50]' % 12 by 1

% Matrix Aeq  = |Ax Bx| 

% Ax Matrix (From Generator Data)
Ax      = zeros(12,6);
Ax(1,1) = 1;
Ax(2,2) = 1;
Ax(3,3) = 1;
Ax(7,4) = 1;
Ax(8,5) = 1;
Ax(9,6) = 1;
    
% Bx Matrix
%   Pinj = Bx * theta = Pg - Pd
%   Bx * theta - Pg = - Pd

% A Matrix (Incidence Matrix) (From Line Data)
A = zeros(25,12);
A(1,1) = 1;  A(1,2) = -1; 
A(2,1) = 1;  A(2,4) = -1; 
A(3,1) = 1;  A(3,5) = -1; 
A(4,2) = 1;  A(4,3) = -1;
A(5,2) = 1;  A(5,4) = -1;
A(6,2) = 1;  A(6,5) = -1;
A(7,2) = 1;  A(7,6) = -1;
A(8,3) = 1;  A(8,5) = -1; 
A(9,3) = 1;  A(9,6) = -1; 
A(10,4) = 1;  A(10,5) = -1; 
A(11,5) = 1;  A(11,6) = -1;
A(12,7) = 1;  A(12,8) = -1;
A(13,7) = 1;  A(13,10) = -1;
A(14,7) = 1;  A(14,11) = -1;
A(15,8) = 1;  A(15,9) = -1; 
A(16,8) = 1;  A(16,10) = -1; 
A(17,8) = 1;  A(17,11) = -1; 
A(18,8) = 1;  A(18,12) = -1;
A(19,9) = 1;  A(19,11) = -1;
A(20,9) = 1;  A(20,12) = -1;
A(21,10) = 1;  A(21,11) = -1;
A(22,11) = 1;  A(22,12) = -1;
A(23,3) = 1;  A(23,9) = -1;    
A(24,5) = 1;  A(24,8) = -1; 
A(25,4) = 1;  A(25,10) = -1;

X = 1./[0.2 0.2 0.3 0.25 0.1 0.3 0.2 0.26 0.1 0.4 0.3 0.2 0.2 ...
    0.3 0.25 0.1 0.3 0.2 0.26 0.1 0.4 0.3 0.8 0.8 0.8];
D = diag(X);

Bx = - 100* A'*D*A; % 12 by 12 Matrix

Aeq = horzcat(Ax,Bx)

% Check Matrix Dimensions 
size(Aeq) ;
size(beq) ;

% Inequality Constraints
% ---------------------------------------------------------------------- %
% Ae*x <= be
% Matrix  Ae         = | Aex_top    |
%                      | Aex_bottom |
% Matrix  Aex_top    = | F_zero 100*F_pos |
%         Aex_bottom = | F_zero 100*F_neg |

% be Matrix
% Rate A (From Bus Data)
be = 100*[100 100 100 60 120 60 60 60 120 60 60 100 100 100 60 60 60 60 60 120 60 60 80 80 80 ...
      100 100 100 60 120 60 60 60 120 60 60 100 100 100 60 60 60 60 60 120 60 60 80 80 80]

% Flow Matrices (From Line Data)
F_pos = zeros(25,12);
F_neg = zeros(25,12);

F_zero = zeros(25,6);

F_pos(1,1) = X(1);  F_pos(1,2) = -X(1); 
F_pos(2,1) = X(2);  F_pos(2,4) = -X(2); 
F_pos(3,1) = X(3);  F_pos(3,5) = -X(3); 
F_pos(4,2) = X(4);  F_pos(4,3) = -X(4);
F_pos(5,2) = X(5);  F_pos(5,4) = -X(5);
F_pos(6,2) = X(6);  F_pos(6,5) = -X(6);
F_pos(7,2) = X(7);  F_pos(7,6) = -X(7);
F_pos(8,3) = X(8);  F_pos(8,5) = -X(8); 
F_pos(9,3) = X(9);  F_pos(9,6) = -X(9); 
F_pos(10,4) = X(10);  F_pos(10,5) = -X(10); 
F_pos(11,5) = X(11);  F_pos(11,6) = -X(11);
F_pos(12,7) = X(12);  F_pos(12,8) = -X(12);
F_pos(13,7) = X(13);  F_pos(13,10) = -X(13);
F_pos(14,7) = X(14);  F_pos(14,11) = -X(14);
F_pos(15,8) = X(15);  F_pos(15,9) = -X(15); 
F_pos(16,8) = X(16);  F_pos(16,10) = -X(16); 
F_pos(17,8) = X(17);  F_pos(17,11) = -X(17); 
F_pos(18,8) = X(18);  F_pos(18,12) = -X(18);
F_pos(19,9) = X(19);  F_pos(19,11) = -X(19);
F_pos(20,9) = X(20);  F_pos(20,12) = -X(20);
F_pos(21,10) = X(21);  F_pos(21,11) = -X(21);
F_pos(22,11) = X(22);  F_pos(22,12) = -X(22);
F_pos(23,3) = X(23);  F_pos(23,9) = -X(23);    
F_pos(24,5) = X(24);  F_pos(24,8) = -X(24); 
F_pos(25,4) = X(25);  F_pos(25,10) = -X(25);

F_neg = - F_pos;

Aex_top    = horzcat(F_zero,100*F_pos);
Aex_bottom = horzcat(F_zero,100*F_neg);

Ae = vertcat(Aex_top, Aex_bottom)


% Convert Bx Matrix (12 by 12) to make it invertible

Bx(12,:)    = 0;
Bx(:,12)    = 0;
Bx(12,12)   = 1;
Bx

Xx = inv(-Bx/100)

%Calculate/Compute PTDF Table
% Monitored line: row l (i to j)
%                     1 (1 to 2)
%                     2 (1 to 4)
%                     3 (1 to 5)
% Affected Line: column n (s to r)
%                       1 (1 to 2)
%                       2 (1 to 4)
%                       3 (1 to 5)

% PTDF (l,n) = X(l)*[ ((Xx(i,s) - Xx(i,r)) - (Xx(j,s) - Xx(j,r)) ]
% PTDF (1,2) = X(1)*[ ((Xx(1,1) - Xx(1,4)) - (Xx(2,1) - Xx(2,4)) ]

index = zeros(25,2);
index(1,1) = 1; index(1,2) = 2;
index(2,1) = 1; index(2,2) = 4;
index(3,1) = 1; index(3,2) = 5;
index(4,1) = 2; index(4,2) = 3;
index(5,1) = 2; index(5,2) = 4;
index(6,1) = 2; index(6,2) = 5;
index(7,1) = 2; index(7,2) = 6;
index(8,1) = 3; index(8,2) = 5;
index(9,1) = 3; index(9,2) = 6;
index(10,1) = 4; index(10,2) = 5;
index(11,1) = 5; index(11,2) = 6;
index(12,1) = 7; index(12,2) = 8;
index(13,1) = 7; index(13,2) = 10;
index(14,1) = 7; index(14,2) = 11;
index(15,1) = 8; index(15,2) = 9;
index(16,1) = 8; index(16,2) = 10;
index(17,1) = 8; index(17,2) = 11;
index(18,1) = 8; index(18,2) = 12;
index(19,1) = 9; index(19,2) = 11;
index(20,1) = 9; index(20,2) = 12;
index(21,1) = 10; index(21,2) = 11;
index(22,1) = 11; index(22,2) = 12;
index(23,1) = 3; index(23,2) = 9;
index(24,1) = 5; index(24,2) = 8;
index(25,1) = 4; index(25,2) = 10;


PTDF = zeros(25);
for l = 1:25
    for n = 1:25
       % PTDF (l,n) =  X(l)*[ ((Xx(i,s) - Xx(i,r)) - (Xx(j,s) - Xx(j,r)) ]
     PTDF (l,n) =  X(l)*[ ( ( Xx(index(l,1),index(n,1)) - Xx(index(l,1),index(n,2))) - (Xx(index(l,2),index(n,1)) - Xx(index(l,2),index(n,2)))) ]; 
    end
    end 


%Calculate/Compute LODF Table
% Monitored line: row (l) 
%                      1 
%                      2
%                      3 
% Affected Line: column (k)
%                        1 
%                        2 
%                        3

LODF = zeros(25);


for l = 1:25
    for k = 1:25
        LODF (l,k) = PTDF(l,k) / (1 - PTDF(k,k)); 
        
    end
end

 for l = 1:25
        LODF (l,l) = 0;
 end

% Display Solutions
% ---------------------------------------------------------------------- %
disp('Display Solution') 
disp(' ----------------------------------------------------------------- ')

disp('Part 1 - DC OPF') 
disp(' ----------------------------------------------------------------- ')

    x = quadprog(H,f,Ae,be,Aeq,beq, lb, ub)

disp('Part 2 - Line Flow Matrix') 
disp(' ----------------------------------------------------------------- ')

    theta = x(7:18,:)
    LF = F_pos * theta * 100

disp('Part 3 - Contingency') 
disp(' ----------------------------------------------------------------- ')

    disp('Show PTDF Table');
    PTDF
    
    disp('Show LODF Table');
    LODF

