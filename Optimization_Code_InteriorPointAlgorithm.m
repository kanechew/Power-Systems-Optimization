% ---------------------------------------------------------------------- %
% Title:        ECE 69500 Homework #7                                    %
% Question:     Problem 8.1                                              %
% Description:  Interior Point Algorithm                                 %
%               Constrained Non-Linear Optimization                                  %
% ---------------------------------------------------------------------- %
% Author:       Yun Zhi Chew (PURDUE UNIVERSITY)                         %
% ---------------------------------------------------------------------- %

% Format Output
% ---------------------------------------------------------------------- %
clear all;
clc;
format short;

% Problem Statement (Page 399)
% ---------------------------------------------------------------------- %
% Solve the following optimization problem using the interior point
% algorithm
% min f(x1,x2)  = 0.25*x1^2 + x2^2
% h(x1,x2)      = x2 - 0.05*x1^2 - 0.5*x1 + 2 <= 0

% initial values
t1  = 1;  % initial t value for central path
u   = 10;   %
m   = 1;    % 
x   = [5;1]; % Initial Value of x

% Initialize Functions

% Original Function to minimize
fun         = @(x) 0.25*x(1)^2 + x(2)^2;     % Function to Minimize
fun_grad    = @(x) [0.5*x(1); 2*x(2)];       % 1st Derivative of Function <fun>
fun_hess    = @(x) [0.5 0;0 2];              % 2nd Derivative of Function <fun>

% Constraint
h           = @(x) x(2) - 0.05*(x(1)^2) - 0.5*x(1) + 2;
h_grad      = @(x) [(-0.1*x(1)-0.5); 1 ];   
h_hess      = @(x) [ -0.1 0; 0 0];

% Barrier Function
phi         = @(x) - log( -(h(x)));
phi_grad    = @(x) (1/(-h(x))) * [(-0.1*x(1)-0.5); 1 ];
phi_hess    = @(x) ( (1/(h(x))^2) * h_grad(x) * transpose(h_grad(x)) )  - ( (1/(h(x))) * h_hess(x));


% ---------------------------------------------------------------------- %
% Loop 1 
% Barrier Function
% ---------------------------------------------------------------------- %

i = 1; % Iteration Counter for Barrier Method

while ( m / t1 > 0.01)   % Stopping Criteria for Barrier Method
    
    fprintf('This is Barrier Iteration: %d \n', i);
    x
    if i > 1
        t1 = u * t1  % Increment t1 by a constant of u
    end
    
    % Minimize this function for central path
    g1           = @(x) t1*fun(x) + phi(x);
    g1_grad      = @(x) t1*fun_grad(x) + phi_grad(x);
    
    
    % ---------------------------------------------------------------------- %
    % Loop 2 
    % Newton Method
    % ---------------------------------------------------------------------- %
    
    % Check Initial Value
    checkvalue = g1_grad(x)
    j = 1; % Iteration Counter for Newton's Method
    
    % Stopping Criteria for Newton's Method
     while ( abs(checkvalue(1)) > (0.01) || abs(checkvalue(2))  > (0.01) )  

            fprintf('This is Newton Iteration: %d \n', j);
            %Ax = b
            A           = @(x)    t1*fun_hess(x) + phi_hess(x);
            b           = @(x) - (t1*fun_grad(x) + phi_grad(x));

            x_delta = A(x) \ b(x)

                % ------------------------------------------------------------------- %
                % Loop 3
                % Backtracking Method
                % ------------------------------------------------------------------- %
                    t2      = 1;   % variable, start from 1   
                    alpha   = 0.1; % constant
                    beta    = 0.9; % constant


                    condition_a = g1(x + t2*x_delta);
                    condition_b = g1(x) + (alpha * t2 * transpose(g1_grad(x))* x_delta);
                    
                    % Stopping Criteria for Backtracking Method
                    while (   ((condition_a > condition_b) || ( h(x) > 0 )))
                        t2 = beta*t2

                        condition_a = g1(x + t2*x_delta);
                        condition_b = g1(x) + (alpha * t2 * transpose(g1_grad(x))* x_delta);
         
                    end  % End of Loop 3

            disp('new value of');
            x = x + (t2 * x_delta)
            
            %calculate 

            j = j + 1; % increment newton counter

            checkvalue = g1_grad(x);
     end % End of Loop 2
 
     i = i + 1;
end % End of Loop 1
 
 
% Print Solution
% ---------------------------------------------------------------------- %
disp(' ');
disp('Display Solution');
disp(' ');
disp('The final values of x1 and x2:');
x
disp(' ');
disp('The minimum value of the function:');
disp(' ');
fun(x)

% Plot Graph
% ---------------------------------------------------------------------- %
% y1 = [linspace
% y2 = [linspace
% [y1 y2] = 







