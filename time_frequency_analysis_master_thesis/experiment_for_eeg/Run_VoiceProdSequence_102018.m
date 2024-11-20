  function Run_VoiceProdSequence_102018(subID)
%% PTB experiment for VOCALIZE study
% 10/2018 // Leonardo Ceravolo
% Task duration: 7.88min
clear all; clc;

Screen('Preference', 'SkipSyncTests', 1);

x=audiodevinfo;
Names={x.output.Name}; 



% Attention : bien mettre Blaster sur IDvibreur 
IDson=x.output(contains(Names,'Haut-parleurs')).ID;


% Get subID & Run number
prompt = {'subID', 'Run','age', 'genre (F=1, H=2)'};
defaults = {'',  '', '', ''};
answer = inputdlg(prompt, 'Experimental Setup Information', 1, defaults);

subID=str2num(answer{1});
Run=str2num(answer{2});
age=str2double(answer{3});
genre=str2double(answer{4});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Master-volume reset: il faudra installer nircmd.exr sur l'ordi de l'eeg
system('nircmd.exe setsysvolume 0'); % for 0% volume; Reset at experiment start.
% system('nircmd.exe setsysvolume 32500'); % for 50% volume
% system('nircmd.exe setsysvolume 65535'); % for 100% volume

%Record from mic: Check//Modify at the BBL
micro=audiodevinfo; micro=micro.input; ID=micro(2).ID; recorder = audiorecorder(44100,16,1,ID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
settingsImageSequence; % Load all the settings from the file
rand('state', sum(100*clock)); % Initialize the random number generator: Necessary?!

%create an instance of the io64 object
ioObj = io64;
%% initialize the interface to the inpoutx64 system driver
status = io64(ioObj);
address = hex2dec('D050');
io64(ioObj,address,0); %reset LPT Port

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('5%'),KbName('ESCAPE')];
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end

% Allow only keyboard keys mentioned in KbCheckList: '5' and 'escape'
RestrictKeysForKbCheck(KbCheckList);

% Screen setup
clear screen
whichScreen = max(Screen('Screens'));
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2); % greyish background
slack = Screen('GetFlipInterval', window1)/2;
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);
Screen('Flip', window1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define emotion according to current Run (1-6)
if Run==1
    emotion='Pour ce bloc, exprimez de la Colere';
    emo='Colere';
    randomizedConditions=[1 2 3 4];
elseif Run==2
    emotion='Pour ce bloc, Exprimez de la Joie';
    emo='Joie';
    randomizedConditions=[2 1 3 4];
elseif Run==3
    emotion='Pour ce bloc, n''exprimez aucune emotion (neutre)';
    emo='Neutre';
    randomizedConditions=[1 2 3 4];
elseif Run==4
    emotion='Pour ce bloc, exprimez de la Colere';
    emo='Colere';
    randomizedConditions=[2 1 3 4];
elseif Run==5
    emotion='Pour ce bloc, exprimez de la Joie';
    emo='Joie';
    randomizedConditions=[1 2 3 4];
elseif Run==6
    emotion='Pour ce bloc, n''exprimez aucune emotion (neutre)';
    emo='Neutre';
    randomizedConditions=[2 1 3 4];
end

% Load the text file with the pseudowords
textItems = importdata(textFile);

% Set up the output file/ logfile
resultsFolder = 'results';
outputfile = fopen([resultsFolder '/Resultfile_Run' num2str(Run) '_VoiceProdSequence_' num2str(subID) '.txt'],'a');
fprintf(outputfile, 'subID\t genre\t age\t Run\t ConditionName\t textItem\t StimTime\t startTime\t OnsetTime\r\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start screen
Screen('TextSize',window1,32)
DrawFormattedText(window1, 'La tâche va commencer...', 'center', 'center', textColor)
Screen('Flip',window1);

% Wait for scanner to trigger start of the Run (equivalent to a '5' keypress)
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('5%'))==1
        break
    end
end

% Master start: reference time-point for all stims onsets
startTime = GetSecs;

io64(ioObj,address,128); %write parallel port
WaitSecs(0.2);
io64(ioObj,address,0);

% Draw instructions about Emotion factor on the screen
Screen('TextSize',window1,32)
% Screen('DrawText',window1, emotion, (W/2-200), (H/2), textColor);
DrawFormattedText(window1, emotion, 'center', 'center', textColor)
Screen('Flip',window1);
% Display instruction longer to get gyroscope noise baseline (5+5sec)
WaitSecs(10);

%Fixation cross 1
 Screen('TextSize',window1,32)
 DrawFormattedText(window1, '+', 'center', 'center', textColor)
    Screen('Flip',window1);
 WaitSecs(1);


% Production Type factor loop//N=4
for j = randomizedConditions
    
    % Manage conditions: Normal vs Aphonic vs Articulate vs Imagine
    if j==1
        ConditionInstruction='Prononcez le pseudomot';
        Pronounce='Normal';
        nTrials=9; % Correct number=9
        %         trigg=1;
    elseif j==2
        ConditionInstruction='Chuchotez le pseudomot';
        Pronounce='Aphonic';
        nTrials=9; % Correct number=9
        %         trigg=3;
    elseif j==3
        ConditionInstruction='Articulez le pseudomot';
        Pronounce='Articulate';
        nTrials=5; % Correct number=5or4
        %         trigg=5;
    elseif j==4
        ConditionInstruction='Imaginez que vous prononcez le pseudomot';
        Pronounce='Imagine';
        nTrials=4; % Correct number=4or5
        %         trigg=7;
    end
    
    % Condition instruction
    ConditionInstruction=num2str(ConditionInstruction);
    
    % Display Production Type (Condition) instruction for each of the 6 blocks
    Screen('TextSize',window1,32)
    %     Screen('DrawText',window1, ConditionInstruction, (W/2-200), (H/2), textColor);
    DrawFormattedText(window1, ConditionInstruction, 'center', 'center', textColor)
    Screen('Flip',window1);
    WaitSecs(5);
    
    %Fixation cross 2
    Screen('TextSize',window1,32)
    DrawFormattedText(window1, '+', 'center', 'center', textColor)
    Screen('Flip',window1);
    WaitSecs(2.5);
    
    % Randomize feedback accross and between conditions/ 'i' loop
    randomizedFeedback = randperm(2);
    % Manage Auditory feedback; Auditory Feedback factor//N=2
    for i = randomizedFeedback
        
        % Screen priority: maybe not necessary... or set to '1' instead of '2'
        Priority(MaxPriority(window1));
        Priority(2);
        
        % Randomize the trial list (order)/ 't' loop
        randomizedTrials = randperm(nTrials);
        
        % Run experimental trials; Pseudoword loop//N=18
        for t = randomizedTrials
            
            % Manage the participant's Auditory Feedback by setting volume before each trial/block
            if i==1 % Auditory feedback
                system('nircmd.exe setsysvolume 65535');
                FeedBack='Feedback';
            elseif i==2 % No Auditory feedback
                system('nircmd.exe setsysvolume 0');
                FeedBack='noFeedback';
            end
            
            % Manage Auditory feedback for neverFeedback conditions
            if j==3 % No Auditory feedback for Articulate
                system('nircmd.exe setsysvolume 0');
                FeedBack='neverFeedback';
            elseif j==4 % No Auditory feedback for Imagine
                system('nircmd.exe setsysvolume 0');
                FeedBack='neverFeedback';
            end
            
            if Run==1 && j==1 && i==1
                trigg=1;
            elseif Run==1 && j==1 && i==2
                trigg=4;           
            elseif Run==1 && j==2 && i==1
                trigg=7;
            elseif Run==1 && j==2 && i==2
                trigg=10;     
            elseif Run==1 && j==3
                trigg=13;
            elseif Run==1 && j==4
                trigg=16;
                
            elseif Run==2 && j==1 && i==1
                trigg=19;
            elseif Run==2 && j==1 && i==2
                trigg=22;           
            elseif Run==2 && j==2 && i==1
                trigg=25;
            elseif Run==2 && j==2 && i==2
                trigg=28;     
            elseif Run==2 && j==3
                trigg=31;
            elseif Run==2 && j==4
                trigg=34;
                 
            elseif Run==3 && j==1 && i==1
                trigg=37;
            elseif Run==3 && j==1 && i==2
                trigg=40;           
            elseif Run==3 && j==2 && i==1
                trigg=43;
            elseif Run==3 && j==2 && i==2
                trigg=46;     
            elseif Run==3 && j==3
                trigg=49;
            elseif Run==3 && j==4
                trigg=52;
                
            elseif Run==4 && j==1 && i==1
                trigg=55;
            elseif Run==4 && j==1 && i==2
                trigg=58;           
            elseif Run==4 && j==2 && i==1
                trigg=61;
            elseif Run==4 && j==2 && i==2
                trigg=64;     
            elseif Run==4 && j==3
                trigg=67;
            elseif Run==4 && j==4
                trigg=70;
                
            elseif Run==5 && j==1 && i==1
                trigg=73;
            elseif Run==5 && j==1 && i==2
                trigg=76;           
            elseif Run==5 && j==2 && i==1
                trigg=79;
            elseif Run==5 && j==2 && i==2
                trigg=82;     
            elseif Run==5 && j==3
                trigg=85;
            elseif Run==5 && j==4
                trigg=88;
                
            elseif Run==6 && j==1 && i==1
                trigg=91;
            elseif Run==6 && j==1 && i==2
                trigg=94;           
            elseif Run==6 && j==2 && i==1
                trigg=97;
            elseif Run==6 && j==2 && i==2
                trigg=100;     
            elseif Run==6 && j==3
                trigg=103;
            elseif Run==6 && j==4
                trigg=106;
            end
            
            %trigger début de parole
            io64(ioObj,address,trigg); %write parallel port
            WaitSecs(0.2);
            io64(ioObj,address,0);
            
            % Display text on screen
            textString = textItems{t};
            Screen('TextSize',window1,32)
            %             Screen('DrawText', window1, textString, (W/2-80), (H/2), textColor);
            DrawFormattedText(window1, textString, 'center', 'center', textColor)
            StimTime=Screen('Flip', window1);
            %             WaitSecs(3);
            
            % Calculate stimulus onset-time, no 'value*e10' format
            Onset=StimTime-startTime;
            OnsetTime=sprintf('%0.5f',Onset);
            
            % Record from microphone for 3 seconds and save recording in .wav format
            recordblocking(recorder, 3);
            
            SaveRecordedData=getaudiodata(recorder);
            filename=['Produced_sounds' filesep emo '_Run' num2str(Run) '_' num2str(t) '_' textString '_' Pronounce '_' FeedBack '_S' num2str(subID) '.wav'];
            Fs=44100;
            audiowrite(filename,SaveRecordedData,Fs); %Uncomment to save .wav file
            clear SaveRecordedData Fs filename % to avoid memory/timing problems
            
            % Again, cut volume to avoid subjects from hearing the scanner restarting
            system('nircmd.exe setsysvolume 0');
            
            % Generate Condition name for logfile
            ConditionName=[emo '_' Pronounce '_' FeedBack];
            
            if Run==1 && j==1 && i==1
                trigg2=3;
            elseif Run==1 && j==1 && i==2
                trigg2=6;           
            elseif Run==1 && j==2 && i==1
                trigg2=9;
            elseif Run==1 && j==2 && i==2
                trigg2=12;     
            elseif Run==1 && j==3
                trigg2=15;
            elseif Run==1 && j==4
                trigg2=18;
                
            elseif Run==2 && j==1 && i==1
                trigg2=21;
            elseif Run==2 && j==1 && i==2
                trigg2=24;           
            elseif Run==2 && j==2 && i==1
                trigg2=27;
            elseif Run==2 && j==2 && i==2
                trigg2=30;     
            elseif Run==2 && j==3
                trigg2=33;
            elseif Run==2 && j==4
                trigg2=36;
                 
            elseif Run==3 && j==1 && i==1
                trigg2=39;
            elseif Run==3 && j==1 && i==2
                trigg2=42;           
            elseif Run==3 && j==2 && i==1
                trigg2=45;
            elseif Run==3 && j==2 && i==2
                trigg2=48;     
            elseif Run==3 && j==3
                trigg2=51;
            elseif Run==3 && j==4
                trigg2=54;
                
            elseif Run==4 && j==1 && i==1
                trigg2=57;
            elseif Run==4 && j==1 && i==2
                trigg2=60;           
            elseif Run==4 && j==2 && i==1
                trigg2=63;
            elseif Run==4 && j==2 && i==2
                trigg2=66;     
            elseif Run==4 && j==3
                trigg2=69;
            elseif Run==4 && j==4
                trigg2=72;
                
            elseif Run==5 && j==1 && i==1
                trigg2=75;
            elseif Run==5 && j==1 && i==2
                trigg2=78;           
            elseif Run==5 && j==2 && i==1
                trigg2=81;
            elseif Run==5 && j==2 && i==2
                trigg2=84;     
            elseif Run==5 && j==3
                trigg2=87;
            elseif Run==5 && j==4
                trigg2=90;
                
            elseif Run==6 && j==1 && i==1
                trigg2=93;
            elseif Run==6 && j==1 && i==2
                trigg2=96;           
            elseif Run==6 && j==2 && i==1
                trigg2=99;
            elseif Run==6 && j==2 && i==2
                trigg2=102;     
            elseif Run==6 && j==3
                trigg2=105;
            elseif Run==6 && j==4
                trigg2=108;
            end
            
            
            %trigger fin de parole
            io64(ioObj,address,trigg2); %write parallel port
            WaitSecs(0.2);
            io64(ioObj,address,0);
            
            
            %Fixation cross 3
            Screen('TextSize',window1,32)
            DrawFormattedText(window1, '+', 'center', 'center', textColor)
            Screen('Flip',window1);
            WaitSecs(2.5);
            
%             % Blank screen for 5 seconds after each trial
%             Screen(window1, 'FillRect', backgroundColor);
%             Screen('Flip', window1);
%             WaitSecs(2.5);
            
            
            % Save results to file
            fprintf(outputfile, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n', num2str(subID), num2str(genre), num2str(age), num2str(Run), ConditionName, textString, StimTime, startTime, OnsetTime);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get time of experiment end
ExperimentEnd=GetSecs; Experiment_duration=(ExperimentEnd-startTime)/60

% Display screen telling participant that the experiment is ending
Screen('TextSize',window1,32)
DrawFormattedText(window1, 'Merci de votre participation!', 'center', 'center', textColor)
Screen('Flip',window1);
WaitSecs(3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
fclose(outputfile);
Screen(window1,'Close');
close all
sca;
return

end
