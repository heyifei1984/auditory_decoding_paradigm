function [initial, age, gender, quit_function] = sub_details

complete = 0;
initial = {};
age = cell(0,1);
gender = {}; 

while complete == 0
    initial = inputdlg({'Participant Num'}, 'Please enter participant initials', 1);
    if ~isempty(initial)
        complete = 1;
    else
        btn1 = questdlg("Please enter an initial to continue", "Error", "OK", "Quit", "OK");
        if btn1(1) == "Q"
            quit_function = 1;
        return
        end
    end
end

complete = 0;

while complete == 0
    age = inputdlg({'Age'}, 'Please enter participant age', 1);
    if ~isempty(age)
        age = str2double(age{1,1});
        complete = 1;
    else
        btn1 = questdlg("Please enter a value to continue", "Error", "OK", "Quit", "OK");
        if btn1(1) == "Q"
            quit_function = 1;
        return
        end
    end
end   

complete = 0;

while complete == 0
    [gender_sel, ok] = listdlg("ListString", {'m', 'w', 'd'}, "SelectionMode", "Single", "Name", "Please Select Gender");    
    if ~isempty(gender_sel)
        if gender_sel == 1
            gender = 'm';
            complete = 1;
        elseif gender_sel == 2
            gender = 'w';
            complete = 1
        elseif gender_sel == 3
            while isempty(gender)
                gender = inputdlg({'Gender'}, 'Please enter your gender', 1);
                if ~isempty(gender)
                    complete = 1;
                else
                    btn1 = questdlg("Please enter a value to continue", "Error", "OK", "Quit", "OK");
                    if btn1(1) == "Q"
                        quit_function = 1;
                        return
                    end
                end
            end
        end
    else
            btn1 = questdlg("Please make selection to continue", "Error", "OK", "Quit", "OK");
            if btn1(1) == "Q"
              quit_function = 1;
              return
            end     
    end
end    

%complete = 0;

%while complete == 0
%    [group_sel, ok] = listdlg("ListString", {'A', 'B'}, "SelectionMode", "Single", "Name", "Counterbalancing?");    
%    if ~isempty(group_sel)
%        if group_sel == 1
%            counterbalance = 'A';
%            complete = 1;
%        else group_sel == 2
%            counterbalance = 'B';
%            complete = 1
%        end  
%    else
%            btn1 = questdlg("Please make selection to continue", "Error", "OK", "Quit", "OK");
%            if btn1(1) == "Q"
%              quit = 1;
%              return
%            end     
%    end
%end       
    



