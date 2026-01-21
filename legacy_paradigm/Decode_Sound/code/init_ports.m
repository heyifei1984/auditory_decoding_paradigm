%% Open parallel ports for passive button + triggers
pkg load instrument-control
global pp
global pp1
pp=parallel("/dev/parport0",0);
pp1=parallel("/dev/parport1",0);

pp_data(pp1, 0)

% Include this if you want the button to fire when starting the script.
% Maybe good to ensure the button is plugged in!

%disp('Executing Button Test')
%pp_data(pp, 255)

%WaitSecs(1)

%pp_data(pp, 0)
%disp('Button Test Complete. Stop the programme if you didn''t hear the button move!')