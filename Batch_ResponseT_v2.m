%% Processing all files in the folder


% path  = 'P:\Teadmill decision making\Data\sample';
path = cd;
files = dir([path '/*.mat']);
data_all = {};
for file_i = 1:length(files)
    temp = load(files(file_i).name);
%     data_all{file_i} = temp.data_set;
    data_all{file_i} = temp;
end

%% Find distribution of response time

v_low = 5;
v_mid =20;

mean_STOP_RT = [];
mean_LOW_RT = [];
mean_HIGH_RT = [];
for file_i = 1:length(files)
    
    data_set = data_all{file_i}.data_set;
    Response_time = [];
    for  i =1 : length(data_set)
        time = data_set(i).time;
        hit = data_set(i).Hit; fa = data_set(i).FA;
        
        target = fa;
        
        if target
        %8/19 수정
            sound_on  = find(data_set(i).sound == 1,1);
            lick = find(data_set(i).lick(sound_on:end) == 1, 1 , 'first');


            lickT = time(sound_on + lick-1) - time(sound_on);
            %----------
            lickT = lickT/1000;

            Response_time = [Response_time; lickT];
        end

    end


%     figure;
% 
%     h = histfit(Response_time, 20, 'kernel');
%     h(1).FaceColor = [.5 .5 .5];
%     h(1).FaceAlpha = 0.2;
%     h(1).EdgeAlpha = 0;
%     h(2).Color = [.2 .2 .2];
%     title('Response time distribution');
%     xlabel('Response time(s)');
%     yt = get(gca, 'YTick');
%     set(gca, 'YTick', yt, 'YTickLabel', yt/length(Response_time));

    % Count number of trials with in range of low(<20) or high speed(>20)

    STOP = [];
    LOW = []; % _hit_miss_cr_fa
    HIGH= []; %_hit_miss_cr_fa

    for  i =1 : length(data_set)
        time = data_set(i).time;
        hit = data_set(i).Hit; fa = data_set(i).FA;
        
        target = fa;
        
        if target
            %8/19 수정
            sound_on  = find(data_set(i).sound == 1,1);
            lick = find(data_set(i).lick(sound_on:end) == 1, 1 , 'first');


            lickT = time(sound_on + lick-1) - time(sound_on);
            %----------
            lickT = lickT/1000;

            led_off = find(data_set(i).LED == 1, 1, 'last');


            avg_speed = mean(data_set(i).speed(led_off: sound_on));
            if (avg_speed <= v_low)
                STOP = [STOP; lickT];
            elseif (avg_speed <= v_mid) && (avg_speed > v_low)
                LOW = [LOW; lickT];
            elseif (avg_speed > v_mid)
                HIGH = [HIGH; lickT];
            end
        end

    end
    mean_STOP_RT = [mean_STOP_RT; mean(STOP)];
    mean_LOW_RT = [mean_LOW_RT; mean(LOW)];
    mean_HIGH_RT = [mean_HIGH_RT; mean(HIGH)];
end


%%
% figure;
% 
% h = histfit(LOW, 20, 'kernel');
% h(1).FaceColor = [85 160 251]./255;
% h(1).FaceAlpha = 0.8;
% h(1).EdgeAlpha = 0;
% h(2).Color = [.2 .2 .2];
% title('Response time distribution: LOW');
% xlabel('Response time(s)');
% 
% yt = get(gca, 'YTick');
% set(gca, 'YTick', yt, 'YTickLabel', yt/length(LOW));

%%
% figure;
% 
% h = histfit(HIGH, 20, 'kernel');
% h(1).FaceColor = [255 160 64]./255;
% h(1).FaceAlpha = 0.8;
% h(1).EdgeAlpha = 0;
% h(2).Color = [.2 .2 .2];
% title('Response time distribution: HIGH');
% xlabel('Response time(s)');
% yt = get(gca, 'YTick');
% set(gca, 'YTick', yt, 'YTickLabel', yt/length(LOW));
% 
% 
% 
% % title('Response time distribution');
% 
% yt = get(gca, 'YTick');
% set(gca, 'YTick', yt, 'YTickLabel', yt/length(HIGH));

%%
% figure;
% h1 = histogram(LOW, 15,'Normalization', 'probability');
% hold on;
% h2 = histogram(HIGH, 15,'Normalization', 'probability');

%%

% h1_data = h1.Values;
% h2_data = h2.Values;
% 
% % h1_kernel = fitdist(h1_data, 'Kernel','Kernel','epanechnikov');
% % h2_kernel = fitdist(h2_data, 'Kernel','Kernel','epanechnikov');
% h1_kernel = fitdist(LOW, 'Kernel','Kernel','epanechnikov');
% h2_kernel = fitdist(HIGH, 'Kernel','Kernel','epanechnikov');
% 
% x = -5:1:20;
% y1 = pdf(h1_kernel, x);
% y2 = pdf(h2_kernel, x);
% 
% plot(x, y1, 'k');
% plot(x, y2, 'k');
% 
% xlabel('Response time(s)');