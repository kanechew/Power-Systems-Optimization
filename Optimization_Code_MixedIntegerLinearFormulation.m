% ---------------------------------------------------------------------- %
% Title:        ECE 69500 Homework #4                                    %
% Description:  Mixed-Integer Linear Formulation for                     %
%               Thermal Unit Commitment Problem                          %
% ---------------------------------------------------------------------- %
% Author:       Yun Zhi Chew (PURDUE UNIVERSITY)                         %
% ---------------------------------------------------------------------- %

% Format Output
clear all;
clc;

% ---------------------------------------------------------------------- % 
%               Initialization of Objective Function f                   %
% ---------------------------------------------------------------------- %

f           = [];          % 

% ---------------------------------------------------------------------- % 
%                       Initialization of Matrix A                       %
% ---------------------------------------------------------------------- % 
% Description:  Matrix A contains the cofficients of inequality equations
% Notation:
%           "row": An array to store the row number of each non-zero entry 
%           "col": An array to store the column number of each non-zero entry
%           "val": An array to store the value of each non-zero entry
%
% Representation:
%           # of rows in A    = # of equations = # of rows in Vector B
%           # of columns in A = # of variables = # of rows in Vector X
%           Each entry in A represents one coefficient of one variable
 
 row        = [];          % 
 col        = [];          % 
 val        = [];          % 
 
% ---------------------------------------------------------------------- % 
%                       Initialization of Matrix Aeq                     %
% ---------------------------------------------------------------------- % 
% Description:  Matrix Aeq contains the cofficients of equality equations
% Notation:
%           "row_eq": An array to store the row number of each non-zero entry 
%           "col_eq": An array to store the column number of each non-zero entry
%           "val_eq": An array to store the value of each non-zero entry
%
% Representation:
%           # of rows in Aeq    = # of equations = # of rows in Vector B
%           # of columns in Aeq = # of variables = # of rows in Vector X
%           Each entry in Aeq represents one coefficient of one variable
 
 row_eq     = [];          % 
 col_eq     = [];          % 
 val_eq     = [];          % 

% ---------------------------------------------------------------------- %  
%                       Initialization of Vector B                       %
% ---------------------------------------------------------------------- % 
% Each entry in Vector B is equal to each row in Matrix A

 B          = [];          % Equivalent to # of equations
 
% ---------------------------------------------------------------------- %  
%                       Initialization of Vector Beq                     %
% ---------------------------------------------------------------------- % 
% Each entry in Vector Beq is equal to each row in Matrix Aeq

 Beq        = [];          % Equivalent to # of equations 

% ---------------------------------------------------------------------- % 
%                       Initialization of Data                           %
% ---------------------------------------------------------------------- % 

% System Data I (From Table A)
% ---------------------------------------------------------------------- % 

% Production Cost
% Production Cost consists of 4 equal segments
% Unit      1      2       3      4      5       6   7   8     9    10 
 Pmin   = [150    150      20     20     25      20  25  10    10    10   ];    % Min Power Output of Unit j
 T1     = [226.25 226.25   47.5   47.5   59.25   35  40  21.25 21.25 21.25];
 T2     = [302.5  302.5    75     75     93.5    50  55  32.5  32.5  32.5 ];
 T3     = [378.75 378.75  102.5  102.5  127.75   65  70  43.75 43.75 43.75];  
 Pmax   = [455    455     130    130    162      80  85  55    55    55   ];    % Max Power Output of Unit j

% Minimum Uptime (UT) & Downtime(DT) 
% Unit      1   2   3   4   5   6   7   8   9   10 
 UT     = [ 8   8   5   5   6   3   3   1   1   1   ];
 DT     = [ 8   8   5   5   6   3   3   1   1   1   ];
 
% System Data II (From Table B)
% ---------------------------------------------------------------------- % 

% Coefficient of piecewise linear production cost function
a     = [ 1000   970   700   680   450   370   480   660   665   670];
b     = [16.19 17.26 16.60 16.50 19.70 22.26 27.74 25.92 27.27 27.79];
c     = [  4.8   3.1    20  21.1  39.8  71.2   7.9  41.3  22.2  17.3]* 1e-4;

hc    = [ 4500  5000   550   560   900   170   260    30    30    30];
cc    = [ 9000 10000  1100  1120  1800   340   520    60    60    60];
tcold = [    5     5     4     4     4     2     2     0     0     0];

% Calculation of Aj, Production cost of unit j in ALL periods
Amin = []; % Production cost at Pmin
A1   = []; % Production cost at T1
A2   = []; % Production cost at T2
A3   = []; % Production cost at T3
Amax = []; % Production cost at Pmax

for j = 1:10
    Amin(j) = a(j) + ( b(j) *  Pmin(j) ) + ( c(j) * Pmin(j) * Pmin(j) );
    A1(j)   = a(j) + ( b(j) *  T1(j)   ) + ( c(j) * T1(j)   * T1(j)   );
    A2(j)   = a(j) + ( b(j) *  T2(j)   ) + ( c(j) * T2(j)   * T2(j)   );
    A3(j)   = a(j) + ( b(j) *  T3(j)   ) + ( c(j) * T3(j)   * T3(j)   );
    Amax(j) = a(j) + ( b(j) *  Pmax(j) ) + ( c(j) * Pmax(j) * Pmax(j) );
end

% Calculation of Ktj, coefficient of stairwise function of unit j in ALL periods
K1  = []; % Coefficient for interval 1
K2  = []; % Coefficient for interval 2
K3  = []; % Coefficient for interval 3
K4  = []; % Coefficient for interval 4
K5  = []; % Coefficient for interval 5
K6  = []; % Coefficient for interval 6
K7  = []; % Coefficient for interval 7
K8  = []; % Coefficient for interval 8
K9  = []; % Coefficient for interval 9
K10 = []; % Coefficient for interval 10
K11 = []; % Coefficient for interval 11
K12 = []; % Coefficient for interval 12
K13 = []; % Coefficient for interval 13
K14 = []; % Coefficient for interval 14
K15 = []; % Coefficient for interval 15

for j = 1:10
    for t  = 1 : 15
        
        if      t == 1 && t < tcold(j) + DT(j)
            K1(j) = hc(j);
        else  
            K1(j) = cc(j);
        end
        
        if  t == 2 && t < tcold(j) + DT(j) +1
            K2(j) = hc(j);
        else  
            K1(j) = cc(j);
        end
        
        if  t == 3 && t < tcold(j) + DT(j) +1
            K3(j) = hc(j);
        else  
            K3(j) = cc(j);
        end
        
        if  t == 4 && t < tcold(j) + DT(j) +1
            K4(j) = hc(j);
        else  
            K4(j) = cc(j);
        end
            
        if  t == 5 && t < tcold(j) + DT(j) +1
            K5(j) = hc(j);
        else  
            K5(j) = cc(j);
        end    
            
        if  t == 6 && t < tcold(j) + DT(j) +1
            K6(j) = hc(j);
        else  
            K6(j) = cc(j);
        end      
            
        if  t == 7 && t < tcold(j) + DT(j) +1
            K7(j) = hc(j);
        else  
            K7(j) = cc(j);
        end    
            
        if  t == 8 && t < tcold(j) + DT(j) +1
            K8(j) = hc(j);
        else  
            K8(j) = cc(j);
        end
        
        if  t == 9 && t < tcold(j) + DT(j) +1
            K9(j) = hc(j); 
        else  
            K9(j) = cc(j);
        end  
        
        if  t == 10 && t < tcold(j) + DT(j) +1
            K10(j) = hc(j);
        else  
            K10(j) = cc(j);
        end    
        
        if  t == 11 && t < tcold(j) + DT(j) +1
            K11(j) = hc(j);
        else  
            K11(j) = cc(j);
        end  
        
        if  t == 12 && t < tcold(j) + DT(j) +1
            K12(j) = hc(j);
        else  
            K12(j) = cc(j);
        end   
        
        if  t == 13 && t < tcold(j) + DT(j) +1
            K13(j) = hc(j);
        else  
            K13(j) = cc(j);
        end
        
        if  t == 14 && t < tcold(j) + DT(j) +1
            K14(j) = hc(j);
        else  
            K14(j) = cc(j);
        end     
        if  t == 15 && t < tcold(j) + DT(j) +1
            K15(j) = hc(j);
        else  
            K15(j) = cc(j);
        end     
     
    end    
end


% Slope of each block/segment  of linear piecewise function
F1  = []; % Slope of segment 1 
F2  = []; % Slope of segment 2 
F3  = []; % Slope of segment 3 
F4  = []; % Slope of segment 4 

% Calculation of Fl, slope of each segment(1-4) of unit j in ALL periods 
for j = 1:10
    F1(j) = ( A1(j)   - Amin(j) ) / ( T1(j)   - Pmin(j) );
    F2(j) = ( A2(j)   - A1(j)   ) / ( T2(j)   - T1(j)   );
    F3(j) = ( A3(j)   - A2(j)   ) / ( T3(j)   - T2(j)   );
    F4(j) = ( Amax(j) - A3(j)   ) / ( Pmax(j) - T3(j)   );

end


% Load Demand (From Table C)
% ---------------------------------------------------------------------- % 
 D      = [  700   750  850  950 1000 1100 1150 1200 1300 1400 1450 1500 ...
            1400  1300 1200 1050 1000 1100 1200 1400 1300 1100  900  800];
 
 
% ---------------------------------------------------------------------- % 
%                 Initialization of User Parameters                      %
% ---------------------------------------------------------------------- %

% User Selected Parameters
 start_time     = 1;                        % in hrs
 end_time       = 24;                       % in hrs
 no_of_sets     = 1;                        % Each set consist of 10 units
 NDj            = 15;                       % Number of Intervals,
                                            % stairwise startup cost               

% ---------------------------------------------------------------------- % 
%                       Initialization of Variables                      %
% ---------------------------------------------------------------------- %

% -------- Declaration of global variables
           
 T                  = end_time - start_time + 1;      % Time Span
 no_of_times        = end_time - start_time + 1;      % k   
 no_of_units        = 10;
 total_no_of_units  = no_of_sets * no_of_units;       % j
 
 
% -------- Order of Variable Index in matrix A / Vector X
% No Variable                    Notation        Starting Index
% 1  Production Cost             cp(j)(k)               1
% 2  StartUp Cost                cu(j)(k)               2
% 3  Power Output                p(j)(k)                3
% 4  Binary Status               v(j)(k)                4
% 5  Power produced in block l   delta1(j,k)            5
% 6  Power produced in block 2   delta2(j,k)            6
% 7  Power produced in block 3   delta3(j,k)            7
% 8  Power produced in block 4   delta4(j,k)            8

% Assignment of Variable Index in Matrix A / Vector X            Notation
starting_index_1  =  0 * total_no_of_units*no_of_times + 1;    %   cp(j)(k)
starting_index_2  =  1 * total_no_of_units*no_of_times + 1;    %   cu(j)(k)
starting_index_3  =  2 * total_no_of_units*no_of_times + 1;    %   p(j)(k)
starting_index_4  =  3 * total_no_of_units*no_of_times + 1;    %   v(j)(k) 
starting_index_5  =  4 * total_no_of_units*no_of_times + 1;    % delta1(j,k)
starting_index_6  =  5 * total_no_of_units*no_of_times + 1;    % delta2(j,k)
starting_index_7  =  6 * total_no_of_units*no_of_times + 1;    % delta3(j,k)
starting_index_8  =  7 * total_no_of_units*no_of_times + 1;    % delta4(j,k)

% Start from time 1, then start from unit 1
% Example
% cp(1)(1), cp(2)(1), ... cp(10)(1), ... cp(1)(24), ... cp(10)(24)
% Exception
% Start from unit 1, then start from time 1
% v(1)(1), v(1)(2), ... v(1)(24), ... v(10)(1), ... v(10)(24)

no_of_variables = 8 * no_of_times * total_no_of_units;

% Declaration of Counter Variables 
% These Values DO NOT RESET
equation_B_counter    = 0;          % Tracks row number in B wrt A
equation_Beq_counter  = 0;          % Tracks row number in B wrt Aeq

A_entry_counter       = 0;          % Tracks # of entries in Matrix A
Aeq_entry_counter     = 0;          % Tracks # of entries in Matrix Aeq
 
G_A_row_counter       = 0;          % Tracks # of rows in Matrix A
G_Aeq_row_counter     = 0;          % Tracks # of rows in Matrix Aeq

% Output - Problem Initialization 
fprintf('Total Number of Periods:                       %d  \n', no_of_times);
fprintf('Total Number of Units(multiple of 10):         %d  \n', total_no_of_units);
fprintf('Total Number of Variables(multiple of 2640):   %d  \n',no_of_variables);
fprintf('Total Number of Columns in Matrix A:           %d  \n',no_of_variables);
fprintf('---------------------------------------------------------\n \n');



% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (1)
% ---------------------------------------------------------------------- %
% Description:  Unit Commitment Problem
% ---------------------------------------------------------------------- %
% Form:         Minimize Double Summation [cp(j)(k) + cu(j)(k)]
%               Summation [cp(1)(1) + ... + cp(10)(1) + cp(1)(24) + ... +
%               cp(10)(24)] + 
%               Summation [cu(1)(1) + ... + cu(10)(1) + cu(1)(24) + ... +
%               cu(10)(24)] 
% # of eqns:    1

for k = start_time:end_time
    
    for j = 1: total_no_of_units 
        
        f(starting_index_1 - 1 + (k-1)*total_no_of_units + j) = 1;
        f(starting_index_2 - 1 + (k-1)*total_no_of_units + j) = 1;
        f(starting_index_3 - 1 + (k-1)*total_no_of_units + j) = 0;
        f(starting_index_4 - 1 + (k-1)*total_no_of_units + j) = 0;
        f(starting_index_5 - 1 + (k-1)*total_no_of_units + j) = 0;
        f(starting_index_6 - 1 + (k-1)*total_no_of_units + j) = 0;
        f(starting_index_7 - 1 + (k-1)*total_no_of_units + j) = 0;
        f(starting_index_8 - 1 + (k-1)*total_no_of_units + j) = 0;
        
    end     % j loop
   
end         % k loop

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (2)
% ---------------------------------------------------------------------- %
% Type:         INEQUALITY - CHANGE SIGN
% Description:  Summation of Power Output >= Load Demand
% ---------------------------------------------------------------------- %
% Form:         Summation [p(j)(k)] >= D(k)
%               1 * p(1)(1) + ... + 1 * p(10)(1) >= D(1)        eqn 1
%               1 * p(1)(2) + ... + 1 * p(10)(2) >= D(2)        eqn 2
%               ...
%               1 * p(1)(24)+ ... + 1 * p(10)(24)= D(24)        eqn 24
% # of eqns:    k (= 24)

equation        = 2;
starting_index  = starting_index_3;    % Variable Index
A_counter       = 0;                   % Variable counter for eqn set
A_row_counter   = 0;                   % Row counter for eqn set

for k = start_time:end_time
    
    A_row_counter = A_row_counter + 1;                  % Increment counter
    equation_B_counter = equation_B_counter + 1;    % Does not reset
    
    % Right Hand Side
    B(equation_B_counter) = - D(k);                 % Convert >= to <=
    
    % Left Hand Side
    for j = 1: total_no_of_units        
        A_counter = A_counter + 1;                      % Increment counter
        A_entry_counter = A_entry_counter + 1;          % Does not reset
        
        row(A_entry_counter)  = equation_B_counter;                                   % Each row represents a particular time
        col(A_entry_counter)  = starting_index - 1 + (k-1)*total_no_of_units + j;     % Each column represents a unit in time 
        val(A_entry_counter)  = - 1;                  % Convert >= to <=
        
    end
    
    % After assignement, print status
    if k == end_time,
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
    
end

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (3)
% ---------------------------------------------------------------------- %
% Type:         INEQUALITY - CHANGE SIGN
% Description:  Summation of Max Available Power >= Load Demand + Reserve
%               Spinning Reserve Requirement: 10% of Load Demand
% ---------------------------------------------------------------------- %
% Form:         Summation [Pmax(j) * v(j)(k)] >= D(k)
%               Pmax(1)*v(1)(1)  + Pmax(2)*v(2)(1)  + ... + Pmax(10)*v(10)(1)
%               Pmax(1)*v(1)(2)  + Pmax(2)*v(2)(2)  + ... + Pmax(10)*v(10)(2)
%               ...
%               Pmax(1)*v(1)(24) + Pmax(2)*v(2)(24) + ... + Pmax(10)*v(10)(24)  
% # of eqns:    k  (= 24)
% Note:         Variable Index is in this format:
%               v(1)(1), v(1)(2), ... v(1)(24), ... v(10)(1), ... v(10)(24)

equation        = 3;
starting_index  = starting_index_4;    % Variable Index
A_counter       = 0;                   % Variable counter for eqn set
G_A_row_counter = G_A_row_counter + A_row_counter; 
A_row_counter   = 0;                   % Row counter for eqn set


for k = start_time:end_time
    
    A_row_counter = A_row_counter + 1;
    equation_B_counter = equation_B_counter + 1;
    
    % Right Hand Side
    B(equation_B_counter) = - ( D(k) + 0.1*D(k) );          % Convert >= to <=
    
    % Left Hand Side
    for j = 1: total_no_of_units        
        A_counter = A_counter + 1;               % Increment counter
        A_entry_counter = A_entry_counter + 1;      
        
        % v(j)(k)        => Starting index 4 
        row(A_entry_counter)  = equation_B_counter;
        col(A_entry_counter)  = starting_index - 1 + (j-1)*T + 1;    % Each column represents one unit at a particular time
        val(A_entry_counter)  = -Pmax(j);                     % Convert >= to <=
        
    end
    
    % After assignement, print status
    if k == end_time,
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (4)
% ---------------------------------------------------------------------- %
               
%                   NOT APPLICABLE FOR THIS SIMULATION                   %

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (5)
% ---------------------------------------------------------------------- %

%                   NOT APPLICABLE FOR THIS SIMULATION                   %

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (6)
% ---------------------------------------------------------------------- %
% Type:         EQUALITY 
% Description:  Production Cost Function
% ---------------------------------------------------------------------- %
% Form:         cp(j)(k) - Aj(j)*v(j)(k) - Summation Fl(j)delta(j,k) = 0
%                
% # of eqns:    j * k = 24 * j
% Note: cp(j)(k)        => Starting index 1
%        v(j)(k)        => Starting index 4    
%       delta1(j,k)     => Starting index 5
%       delta2(j,k)     => Starting index 6
%       delta3(j,k)     => Starting index 7
%       delta4(j,k)     => Starting index 8

equation            = 6;
% Multi Starting Index
Aeq_counter         = 0;                   % reset counter
Aeq_row_counter     = 0;                   % reset counter

for k = start_time:end_time
 
    Aeq_row_counter = Aeq_row_counter + 1;
    equation_Beq_counter = equation_Beq_counter + 1;
    
    % Right Hand Side
    Beq(equation_Beq_counter) = 0;          
    
    for j = 1: total_no_of_units 
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;      
        
        % cp(j)(k)        => Starting index 1
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_1 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = 1;  
        
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;  
        
        % v(j)(k)        => Starting index 4 
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_4 - 1 + (j-1)*T + 1; % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - Amin(j);
            
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;
        
        % delta1(j,k)     => Starting index 5
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_5 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - F1(j);
       
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;
        
        % delta2(j,k)     => Starting index 6
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_6 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - F2(j);
            
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;
        
        % delta3(j,k)     => Starting index 7
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_7 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - F3(j);
            
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;
        
        % delta4(j,k)     => Starting index 8
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_8 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - F4(j);
        
    end % j loop
    
    % After assignement, print status
    if k == end_time,
        ending_index = starting_index - 1 + Aeq_counter;
        printequation2(equation, Aeq_counter, Aeq_row_counter, ending_index, equation_Beq_counter);
    end
end % k loop


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (7)
% ---------------------------------------------------------------------- %
% Type:         EQUALITY 
% Description:  Production Cost Function
% ---------------------------------------------------------------------- %
% Form:         p(j)(k) - Summation Fl(j)delta(j,k) - Pmin(j)*v(j)(k) = 0
%                
% # of eqns:    j * k = 24 * j
% Note:  p(j)(k)        => Starting index 3
%        v(j)(k)        => Starting index 4    
%       delta1(j,k)     => Starting index 5
%       delta2(j,k)     => Starting index 6
%       delta3(j,k)     => Starting index 7
%       delta4(j,k)     => Starting index 8

equation            = 7;
% Multi Starting Index
Aeq_counter         = 0;                     % reset counter
G_Aeq_row_counter   = G_Aeq_row_counter + Aeq_row_counter; 
Aeq_row_counter     = 0;                   % reset counter

for k = start_time:end_time
 
    Aeq_row_counter         = Aeq_row_counter + 1;
    equation_Beq_counter    = equation_Beq_counter + 1;
    
    % Right Hand Side
    Beq(equation_Beq_counter) = 0;          
    
    for j = 1: total_no_of_units 
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;      
        
        % p(j)(k)        => Starting index 3
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_3 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = 1;  
        
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;  
        
        % v(j)(k)        => Starting index 4 
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_4 - 1 + (j-1)*T + 1; % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - Pmin(j);
            
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;
        
        % delta1(j,k)     => Starting index 5
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_5 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - 1;
       
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;
        
        % delta2(j,k)     => Starting index 6
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_6 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - 1;
            
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;
        
        % delta3(j,k)     => Starting index 7
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_7 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - 1;
            
        Aeq_counter = Aeq_counter + 1;               % Increment counter
        Aeq_entry_counter = Aeq_entry_counter + 1;
        
        % delta4(j,k)     => Starting index 8
            row_eq(Aeq_entry_counter)  = equation_Beq_counter;
            col_eq(Aeq_entry_counter)  = starting_index_8 - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val_eq(Aeq_entry_counter)  = - 1;
        
    end % j loop
    
    % After assignement, print status
    if k == end_time,
        ending_index = starting_index - 1 + Aeq_counter;
        printequation2(equation, Aeq_counter, Aeq_row_counter, ending_index, equation_Beq_counter);
    end
end % k loop


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (8)
% ---------------------------------------------------------------------- %
% Description:  Power produced in block 1 < 
%               Upper Limit of Block 1 - Min of unit
% 
% ---------------------------------------------------------------------- %
% Form:         delta_1(1,1) 
%               delta_1(1,2) 
% # of eqns:    j * k = 24 * j

equation        = 8;
starting_index  = starting_index_5;    % 
A_counter       = 0;                   % reset counter
G_A_row_counter = G_A_row_counter + A_row_counter; 
A_row_counter   = 0;                   % reset counter

for k = start_time:end_time
 
    for j = 1: total_no_of_units  
        
        A_row_counter = A_row_counter + 1;
        equation_B_counter = equation_B_counter + 1;
        
        A_counter = A_counter + 1;               % Increment counter
        A_entry_counter = A_entry_counter + 1;  
        
        % Right Hand Side 
        B(equation_B_counter) = T1(j) - Pmin(j); % not dependent on k
       
        % Left Hand Side
        row(A_entry_counter)  = equation_B_counter;
        col(A_entry_counter)  = starting_index - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
        val(A_entry_counter)  = 1;
       
    end
    
    % After assignment, print status
    if k == end_time,
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (9)
% ---------------------------------------------------------------------- %
% Description:  Power produced in block 2 < 
%               Upper Limit of Block 2 - Upper Limit of Block 1
%               Power produced in block 3 < 
%               Upper Limit of Block 3 - Upper Limit of Block 2
% ---------------------------------------------------------------------- %
% Form:         delta_2(j,k) < T2(j) -  T1(j)
%                   => delta_2(1,k) < T2(1) -  T1(1)

%               delta_3(j,k) 
%                   => delta_3(1,k) < T3(1) -  T2(1)
% # of eqns:    j * k * 2 = 48 * j

equation        = 9;
starting_index  = starting_index_6;    % 
A_counter       = 0;                   % reset counter
G_A_row_counter = G_A_row_counter + A_row_counter; 
A_row_counter   = 0;                   % reset counter

for k = start_time:end_time
  
    for j = 1: total_no_of_units  
        
        for delta = 2:3
        
        A_counter = A_counter + 1;               % Increment counter
        A_entry_counter = A_entry_counter + 1;  
        A_row_counter = A_row_counter + 1;
        equation_B_counter = equation_B_counter + 1;
        
            if delta == 2
                % Right Hand Side 
                B(equation_B_counter) = T2(j) - T1(j); % not dependent on k

                % Left Hand Side
                row(A_entry_counter)  = equation_B_counter;
                col(A_entry_counter)  = starting_index -1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
                val(A_entry_counter)  = 1;   

            else
                % Right Hand Side 
                B(equation_B_counter) = T3(j) - T2(j); % not dependent on k

                % Left Hand Side
                row(A_entry_counter)  = equation_B_counter;
                col(A_entry_counter)  = starting_index -1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
                val(A_entry_counter)  = 1;   
            end   
        end  % delta
        
    end % j
    
    % After assignment, print status
    if k == end_time,
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end   % k


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (10)
% ---------------------------------------------------------------------- %
% Description:  Power produced in block 4 < 
%               Capacity of Unit j - Upper Limit of Block 3
% ---------------------------------------------------------------------- %
% Form:         delta_4(j,k) < Pmax(j) - T3(j)
%                   => delta_4(1,k) < Pmax(1)- T3(1)
% # of eqns:    j * k = 24 * j

equation        = 10;
starting_index  = starting_index_8;    % 
A_counter       = 0;                   % reset counter
G_A_row_counter = G_A_row_counter + A_row_counter; 
A_row_counter   = 0;                   % reset counter

for k = start_time:end_time
  
    for j = 1: total_no_of_units  
        
        A_counter = A_counter + 1;               % Increment counter
        A_entry_counter = A_entry_counter + 1;  
        A_row_counter = A_row_counter + 1;
        equation_B_counter = equation_B_counter + 1;
        
        % Right Hand Side 
        B(equation_B_counter) = Pmax(j) - T3(j); % not dependent on k

        % Left Hand Side
        row(A_entry_counter)  = equation_B_counter;
        col(A_entry_counter)  = starting_index -1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
        val(A_entry_counter)  = 1;   

    end % j
    
    % After assignement, print status
    if k == end_time,
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end   % k


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (11)
% ---------------------------------------------------------------------- %
% Description:  All blocks >= 0
% 
% ---------------------------------------------------------------------- %
% Form:         delta_1(j,k) > 0
%               delta_2(j,k) > 0
%               delta_3(j,k) > 0
%               delta_4(j,k) > 0
% # of eqns:    j * k * l = 24 * 4 * j
% Note:         Switch sign

equation        = 11;
starting_index  = starting_index_5;    % 
A_counter       = 0;                   % reset counter
G_A_row_counter = G_A_row_counter + A_row_counter; 
A_row_counter   = 0;                   % reset counter

for k = start_time:end_time
  
    for j = 1: total_no_of_units  
        
        for delta = 1:4
            A_counter = A_counter + 1;               % Increment counter
            A_entry_counter = A_entry_counter + 1;  
            A_row_counter = A_row_counter + 1;
            equation_B_counter = equation_B_counter + 1;

            % Right Hand Side 
            B(equation_B_counter) = 0; % not dependent on k

            % Left Hand Side
            row(A_entry_counter)  = equation_B_counter;
            col(A_entry_counter)  = starting_index - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val(A_entry_counter)  = -1;   
        end % delta    
           
    end % j
    
    % After assignement, print status
    if k == end_time,
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end   % k


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (12)
% ---------------------------------------------------------------------- %
% Type:         INEQUALITY - CHANGE SIGN
% Description:  Start Up Cost
% 
% ---------------------------------------------------------------------- %
% Form:         Kjt[v(j)(k) ] - Kjt {summation [v(j)(k-n)]} - cu(j)(k) <= 0
% # of eqns: 24 * j * NDj 
% Note:     cu(j)(k)     => Starting index 2
%            v(j)(k)     => Starting index 4

equation          = 12;
% multiple starting index
A_counter         = 0;    %reset counter
G_A_row_counter   = G_A_row_counter + A_row_counter; 
A_row_counter     = 0;    %reset counter

for t = 1:NDj
    for k = start_time:end_time
        for j = 1: total_no_of_units  
        
            A_row_counter           = A_row_counter + 1;
            equation_B_counter      = equation_B_counter + 1;

                % Right Hand Side 
                B(equation_B_counter)   = 0; 

            A_counter               = A_counter + 1;               % Increment counter
            A_entry_counter         = A_entry_counter + 1;  
            
                % Left Hand Side
                % cu(j)(k)        => Starting index 2 
                
                % v(j)(k)        => Starting index 4 
                row(A_entry_counter)  = equation_B_counter;
                col(A_entry_counter)  = starting_index_4 - 1 + (j-1)*T + 1;    % Each column represents one unit at a particular time
                val(A_entry_counter)  = K1(j);   
            
            
    
         
            
        
        end % j loop
    end   % k loop
    
    % After assignement, print status
    if t == NDj,
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end % t loop



% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (13)
% ---------------------------------------------------------------------- %
% Type:         INEQUALITY - CHANGE SIGN
% Description:  Start Up Cost of Unit j in period k > 0
% 
% ---------------------------------------------------------------------- %
% Form:         cu(j)(k) > 0
%               cu(1)(1)+ cu(2)(1)+ ... + cu(j)(1)+ ... + cu(1)(24) + ... + cu(j)(24)
% # of eqns:    j * k = 24 * j

equation        = 13;
starting_index  = starting_index_2;    % cu(j)(k)
A_counter         = 0;                   % reset counter
G_A_row_counter  = G_A_row_counter + A_row_counter; 
A_row_counter     = 0;                   % reset counter

for k = start_time:end_time
  
    for j = 1: total_no_of_units  
        
            A_counter = A_counter + 1;               % Increment counter
            A_entry_counter = A_entry_counter + 1;  
            A_row_counter = A_row_counter + 1;
            equation_B_counter = equation_B_counter + 1;

            % Right Hand Side 
            B(equation_B_counter) = 0; % not dependent on k

            % Left Hand Side
            row(A_entry_counter)  = equation_B_counter;
            col(A_entry_counter)  = starting_index - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
            val(A_entry_counter)  = -1;   
       
    end % j loop
    
    % After assignement, print status
    if k == end_time,
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end   % k loop

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (14)
% ---------------------------------------------------------------------- %
% Description:  
% 
% ---------------------------------------------------------------------- %


%                   NOT APPLICABLE FOR THIS SIMULATION                   %

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (15)
% ---------------------------------------------------------------------- %
% Description:  
% 
% ---------------------------------------------------------------------- %


%                   NOT APPLICABLE FOR THIS SIMULATION                   %

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (16)
% ---------------------------------------------------------------------- %
% Description:  
% 
% ---------------------------------------------------------------------- %

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (17)
% ---------------------------------------------------------------------- %
% Description:  
% 
% ---------------------------------------------------------------------- %

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (18)
% ---------------------------------------------------------------------- %
% Description:  
% 
% ---------------------------------------------------------------------- %

%                   NOT APPLICABLE FOR THIS SIMULATION                   %


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (19)
% ---------------------------------------------------------------------- %
% Description:  
% ---------------------------------------------------------------------- %

%                   NOT APPLICABLE FOR THIS SIMULATION                   %


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (20)                                         
% ---------------------------------------------------------------------- %
% Description:  
% ---------------------------------------------------------------------- %

%                   NOT APPLICABLE FOR THIS SIMULATION                   %


% ---------------------------------------------------------------------- %
% Formulation of Equations Set (21)                                       
% ---------------------------------------------------------------------- %
% Description:  
% ---------------------------------------------------------------------- %

%                   NOT APPLICABLE FOR THIS SIMULATION                   %


% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (22)                                         
% ---------------------------------------------------------------------- %
% Type:         INEQUALITY - CHANGE SIGN
% Description:  
% 
% ---------------------------------------------------------------------- %
% Form:         
%               
% # of eqns:    
% Note:         Gj = 0 because all units satisfy minimum uptime constraint
%               Time Span, T = 24
% Need to start from j
% Variable Index in X
% v(1)(1)  + v(2)(1) + ... + v(10)(1) + ... + v(1)(24) + ... + v(10)(24)


% equation        = 22;
% starting_index  = starting_index_4;    % v(j)(k) 
% counter         = 0;                   % reset loop counter
% global_row_counter  = global_row_counter + row_counter; 
% row_counter     = 0;                   % reset loop counter
% 
% for j = 1: total_no_of_units 
%   
%     for k = start_time : T - UT(j) + 1
%         
%         for n = k : k + UT(j) - 1
%         
%             counter = counter + 1;               % Increment loop counter
%             entry_counter = entry_counter + 1;  
%             row_counter = row_counter + 1;
%             equation_B_counter = equation_B_counter + 1;
% 
%             % Right Hand Side 
%             B(equation_B_counter) = - UT(j) * (; 
% 
%             % Left Hand Side
%             row(entry_counter)  = equation_B_counter;
%             col(entry_counter)  = starting_index - 1 + (k-1)*total_no_of_units + j;    % Each column represents one unit at a particular time
%             val(entry_counter)  = -1;   
%             
%         end % n loop
%     
%     end % k loop
%     
%     % After assignement, print status
%     if k == end_time,
%         ending_index = starting_index - 1 + counter;
%         printequation(equation, counter, row_counter, ending_index, equation_B_counter);
%     end
% end   % j loop

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (23)                                         
% ---------------------------------------------------------------------- %
% Type:         INEQUALITY - CHANGE SIGN
% Description:  
% 
% ---------------------------------------------------------------------- %
% Form:       v(j)(n) - [v(j)(k) - v(j)(k-1)] > = 0
%           - v(j)(n) +  v(j)(k) - v(j)(k-1)  < = 0 
%               
% # of eqns:    
% Note: 
% Variable Index in X
% v(j)(k)
% v(1)(1)  + v(1)(2) + ... + v(1)(24) + ... + v(10)(1) + ... + v(10)(24)

equation            = 23;
starting_index      = starting_index_4;    % v(j)(k) 
A_counter           = 0;                   % reset loop counter
G_A_row_counter     = G_A_row_counter + A_row_counter; 
A_row_counter       = 0;                   % reset loop counter

for j = 1: total_no_of_units 
  
    for k = T - UT(j) + 2 : T 
        
        A_row_counter = A_row_counter + 1;
        equation_B_counter = equation_B_counter + 1;
        % Right Hand Side 
        B(equation_B_counter) = 0;
        
        for n = k : T
        
            A_counter             = A_counter + 1;               % Increment loop counter
            A_entry_counter       = A_entry_counter + 1;  
            
            % Left Hand Side (3 terms)
            % v(j)(n)
            row(A_entry_counter)  = equation_B_counter;
            col(A_entry_counter)  = starting_index - 1 + (j-1)*total_no_of_units + n;    % Each column represents one unit at a particular time
            val(A_entry_counter)  = - 1;  
            
            A_counter             = A_counter + 1;               % Increment loop counter
            A_entry_counter       = A_entry_counter + 1;  
            
            % v(j)(k)
            row(A_entry_counter)  = equation_B_counter;
            col(A_entry_counter)  = starting_index - 1 + (j-1)*no_of_times + k;    % Each column represents one unit at a particular time
            val(A_entry_counter)  = 1;  
            
            A_counter             = A_counter + 1;               % Increment loop counter
            A_entry_counter       = A_entry_counter + 1;  
            
            % v(j)(k-1)
            row(A_entry_counter)  = equation_B_counter;
            col(A_entry_counter)  = starting_index - 1 + (j-1)*no_of_times + k - 1;    % Each column represents one unit at a particular time
            val(A_entry_counter)  = - 1;  
            
        end % n loop
    
    end % k loop
    
    % After assignement, print status
    if j == total_no_of_units
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end   % j loop

% ---------------------------------------------------------------------- %
% Formulation of Equations Set (24)                                       
% ---------------------------------------------------------------------- %
% Description:  
% ---------------------------------------------------------------------- %

%                   NOT APPLICABLE FOR THIS SIMULATION                   %

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (25)                                         
% ---------------------------------------------------------------------- %
% Type:         INEQUALITY - CHANGE SIGN
% Description:  Minimum Down Time Constraint 1
%               For k = 1 ... T-DTj + 1
% ---------------------------------------------------------------------- %
% Form:         Summation [1-v(j)(n)] >= DT(j)[v(j)(k-1) - v(j)(k)]
%           0 >= DT(j)[v(j)(k-1) - v(j)(k)] - Summation [1-v(j)(n)]
%               
% # of eqns: 

% ---------------------------------------------------------------------- % 
% Formulation of Equations Set (26)                                         
% ---------------------------------------------------------------------- %
% Type:         INEQUALITY - CHANGE SIGN
% Description:  Minimum Down Time Constraint 2
%               For k = T-DTj + 2 ... T
% ---------------------------------------------------------------------- %
% Form:         Summation [  1 - v(j)(n) - [ v(j)(k-1) - v(j)(k) ] >= 0
%             - Summation [  1 - v(j)(n) -   v(j)(k-1) + v(j)(k) ] =< 0
%               Summation [      v(j)(n) +   v(j)(k-1) - v(j)(k) ] =< Summation [1]
% # of eqns:    j * (DTj-2)

equation            = 26;
starting_index      = starting_index_4;    % v(j)(k) 
A_counter           = 0;                   % reset loop counter
G_A_row_counter     = G_A_row_counter + A_row_counter;
A_row_counter       = 0;                   % reset loop counter

for j = 1: total_no_of_units 
  
    for k = T - DT(j) + 2 : T 
        
        A_row_counter = A_row_counter + 1;
        equation_B_counter = equation_B_counter + 1;
        % Right Hand Side 
        B(equation_B_counter) = T - k + 1;                       % Summation of T - k terms
        
        for n = k : T
        
            A_counter             = A_counter + 1;               % Increment loop counter
            A_entry_counter       = A_entry_counter + 1;  
            
            % Left Hand Side (3 terms)
            % v(j)(n)
            row(A_entry_counter)  = equation_B_counter;
            col(A_entry_counter)  = starting_index - 1 + (j-1)*total_no_of_units + n;    % Each column represents one unit at a particular time
            val(A_entry_counter)  = - 1;  
            
            A_counter             = A_counter + 1;               % Increment loop counter
            A_entry_counter       = A_entry_counter + 1; 
            
            % v(j)(k)
            row(A_entry_counter)  = equation_B_counter;
            col(A_entry_counter)  = starting_index - 1 + (j-1)*no_of_times + k;    % Each column represents one unit at a particular time
            val(A_entry_counter)  = 1;  
            
            A_counter             = A_counter + 1;               % Increment loop counter
            A_entry_counter       = A_entry_counter + 1; 
            
            % v(j)(k-1)
            row(A_entry_counter)  = equation_B_counter;
            col(A_entry_counter)  = starting_index - 1 + (j-1)*no_of_times + k - 1;    % Each column represents one unit at a particular time
            val(A_entry_counter)  = - 1;  
            
        end % n loop
    
    end % k loop
    
    % After assignement, print status
    if j == total_no_of_units
        ending_index = starting_index - 1 + A_counter;
        printequation(equation, A_counter, A_row_counter, ending_index, equation_B_counter);
    end
end   % j loop

% Final Increment
G_A_row_counter     = G_A_row_counter   + A_row_counter;
G_Aeq_row_counter   = G_Aeq_row_counter + Aeq_row_counter;

% Display Input Information
fprintf ('\n                 Sumamry of Assignment \n');
disp    ('-----------------------------------------------------------');
fprintf ('Number of Values assigned in matrix A:       %d \n', length(row));
fprintf ('Number of Equations assigned in matrix A:    %d \n', G_A_row_counter);
disp    ('-----------------------------------------------------------');
fprintf ('Number of Values assigned in matrix Aeq:     %d \n', length(row_eq));
fprintf ('Number of Equations assigned in matrix Aeq:  %d \n', G_Aeq_row_counter);
disp    ('-----------------------------------------------------------');

% Verify # of Equations
fprintf ('Number of rows in equation B wrt Matrix A:   %d \n', equation_B_counter);
fprintf ('Number of rows in equation B wrt Matrix Aeq: %d \n', equation_Beq_counter);

% Display Matrix A Information

A = sparse(row,col,val);
disp    ('-----------------------------------------------------------');
fprintf('No of                                    | Rows  | Columns |\n');
disp    ('-----------------------------------------------------------');
fprintf('Size of Matrix A is:                        %d    %d \n',size(A));

% Display Matrix Aeq Information

Aeq = sparse(row_eq,col_eq,val_eq);
% B = full(A)
disp    ('-----------------------------------------------------------');
fprintf('No of                                    | Rows  | Columns |\n');
disp    ('-----------------------------------------------------------');
fprintf('Size of Matrix A is:                        %d      %d \n',size(Aeq));



