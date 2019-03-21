%Clear all variables in window and close any plots.
clc;clear;close;

%Assign initial global variables
maxEpisodes = 100;
index = 0;
trial = 0;
maxTrials = 100000;
episode = 0;
rcap = 0;
fail_flag = 0;

num_states = 162;
ALPHA = 1000;
BETA = 0.5;
GAMMA = 0.95;
DELTA = 0.9;
LAMBDA = 0.8;

%Assign all vectors to zero.
w = zeros(162, 1);      %Weights for ASE
v = zeros(162, 1);      %Weights for ACE
xbar = zeros(162, 1);   %Decay vector for ACE
e = zeros(162, 1);      %Decay vector for ASE

%Initialise states to zero.
x = 0;
x_dot = 0;
theta = 0;
theta_dot = 0;

%Get the index of the state vector from the decoder.
index = decoder(x, x_dot, theta, theta_dot);

%Initially, increment the episode to 1.
while (trial < maxTrials && episode < maxEpisodes)
    %Generate noise and use sigmoid activation function, and then generate
    %the signum function value for y i.e the action y = [0,1].  
    noise = rand() * 10e-4;
    y = (noise < sigmoid(w(index + 1)));
  
    %Apply the force to the system and capture its new states.
    [x, x_dot, theta, theta_dot] = dynamics(y, x, x_dot, theta, theta_dot);
    
    %increment index as matlab indexing is from 1.
    e(index+1) = e(index+1) + (1-DELTA) * (y - 0.5);    %Update traces from 't-1' to 't'
    xbar(index + 1) = xbar(index + 1) + (1-LAMBDA);
    
    %Store the 't-1' value of v vector to compute the prediction equation.
    p_t_1 = v(index + 1);
    
    %{
    disp("==========================");
    fprintf("x = %d x_dot = %d theta = %d theta_dot = %d \n", x, x_dot, theta, theta_dot);
    %}
    
    %After applying force, get the state vector from the decoder.
    index = decoder(x, x_dot, theta, theta_dot);
    
    %Check if pole has fallen.
    if(index < 0)
        %Pole has fallen.
        fail_flag = 1;              %Turn on the fail flag so that we can reset the states to [0 0 0 0]'
        episode = episode + 1;      %Increment the number of episodes
        fprintf("Episode %d occured with %d trials.\n", episode, trial);
        trial = 0;                  %Reset the trial to zero.
        
        %Reset all the state variables.
        x = 0;
        x_dot = 0;
        theta = 0;
        theta_dot = 0;
        
        %Read the new index after resetting.
        index = decoder(x, x_dot, theta, theta_dot);
        
        %Make the reward -1, and reset the prediction to zero.
        r = -1;
        p = 0;
    else
        %Pole has not yet fallen. keep fail flag nonzero so that
        %unnecessary reset doesnt occur. reward is set to zero and the
        %prediction value is updated.
        fail_flag = 0;
        r = 0;
        p = v(index + 1);
    end
    
    %Compute the reward for the ASE.
    rcap = r + GAMMA * p - p_t_1;
    
    %Update the weights for ASE and ACE. Weights for ACE are constrained to
    %be greater than -1, so that the equations converge.
    w = w + ALPHA * rcap * e;
    v = v + BETA * rcap * xbar;
    for j = 1:num_states
        if(v(j) < -1)
            v(j) = v(j);
        end
    end
    
    %If fail flag is zero, reset the decay functions.
    if(fail_flag)
        e = zeros(162, 1);
        xbar = zeros(162, 1);
    else
        %Update the decay functions from 't-1' to current 't'
        e = e * DELTA;
        xbar = xbar * LAMBDA;
    end
    %Increment the trials.
    trial = trial + 1;
end

if(episode == maxEpisodes)
    fprintf("Failed. \n");
else
    fprintf("Balanced! \n");
end


function[x_, x_dot_, theta_, theta_dot_] = dynamics(action, x, x_dot, theta, theta_dot)
    g = 9.81;
    M = 1.0;
    m = 0.1;
    Mm = m + M;
    l = 0.5;
    ml = m * l;
    t = 0.02;
    
    if action > 0
        f = 10;
    else
        f = -10;
    end
    
    costheta = cos(theta);
    sintheta = sin(theta);
    
    numerator_2 = (f + ml * theta_dot * theta_dot * sintheta)/Mm;
    thetaacc = (g * sintheta - costheta*numerator_2)/(l * ((4/3) - m * costheta * costheta / Mm));
    xacc = numerator_2 - ml * thetaacc * costheta / Mm;
    
    x_ = x + t * x_dot;
    x_dot_ = x_dot + t * xacc;
    theta_ = theta + t * theta_dot;
    theta_dot_ = theta_dot + t * thetaacc;
    
end

function s_ = sigmoid(s)
    s_ = 1/(1 + exp(-max(-50, min(s, 50))));
end


function index = decoder(x, x_dot, theta, theta_dot)
    %fprintf("x = %d x_dot = %d theta = %d theta_dot = %d \n", x, x_dot, theta, theta_dot);
    %disp("==========================");
    index = 0;
    theta = (180/pi)*theta;
    theta_dot = (180/pi)*theta_dot;
    if(x < -2.4 || x > 2.4|| theta < -12 || theta > 12)
        index = -1;
        return;
    end
    
    if(x < -0.8)    
        index = 0;
    elseif(x < 0.8)     
        index = 1;
    else
        index = 2;
    end
    
    if(x_dot < -0.5)
        %do nothing
    elseif(x_dot < 0.5)     
        index = index + 3;
    else
        index = index + 6;
    end
    
    if (theta < -6) 	
        %do nothing
    elseif (theta < -1) 
        index = index + 9;
    elseif (theta < 0)  
        index = index + 18;
    elseif (theta < 1)  
        index = index + 27;
    elseif (theta < 6)  
        index = index + 36;
    else
        index = index + 45;
    end
    
    if (theta_dot < -50) 	 
        %do nothing
    elseif (theta_dot < 50)  
        index = index + 54;
    else
        index = index + 108;
    end
end