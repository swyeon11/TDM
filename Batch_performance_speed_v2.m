%% Count number of trials with in range of low(<20) or high speed(>20)
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
%%
v_div = [15, 20, 25];

temp = zeros(length(files), 4);
v_bin_sum = {temp,temp,temp,temp}; % sum of performance counts _hit_miss_cr_fa

total_speed = cell(length(files),1);

session_bf_speed = zeros(length(files), 3);

for i = 1:length(files)
    %%%initialize%%%
    data_set = data_all{i}.data_set;  
    Hit_speed = data_all{i}.Hit_speed; 
    CR_speed = data_all{i}.CR_speed;
    Miss_speed = data_all{i}.Miss_speed;
    FA_speed = data_all{i}.FA_speed;
    
    v_bin_list = {[],[],[],[]};% _hit_miss_cr_fa for each array
    %%%%%%
    
    
    for j = 1:length(data_set)
        %%%initialize%%%
        data  = data_set(j);
        total_speed{i} = zeros(length(data_set),1);
        
        time = data.time - data.time(1);
        Fs = round(1000/(time(11) - time(1)))*10;
        if(Fs ~= 100)
            Fs 
            % to check Fs 
        end
        speed = smooth(data.speed,round(Fs/10));
        sound = data.sound;
        
        % ROI time range
        %-----------------------------------------------------------------------------%
        sound_on = find(sound == 1, 1, 'first');
        sound_on_time = time(sound_on);
        sound_100ms = find(time >= sound_on_time+100, 1, 'first');
        sound_before_100ms = find(time >= sound_on_time-100, 1, 'first');
        
%         roi_start = sound_on;
%         roi_end = sound_100ms;
        roi_start = sound_before_100ms;
        roi_end = sound_on;
        
        avg_speed = mean(speed(roi_start:roi_end));
        total_speed{i}(j) = avg_speed;
        %-----------------------------------------------------------------------------%
        
          
        if (avg_speed <= v_div(1))
            v_bin_list{1} = [v_bin_list{1}; data.Hit, data.Miss, data.CR, data.FA];
        elseif (avg_speed <= v_div(2))
            v_bin_list{2} = [v_bin_list{2}; data.Hit, data.Miss, data.CR, data.FA];
        elseif (avg_speed <= v_div(3))
            v_bin_list{3} = [v_bin_list{3}; data.Hit, data.Miss, data.CR, data.FA];
        else 
            v_bin_list{4} = [v_bin_list{4}; data.Hit, data.Miss, data.CR, data.FA];
        end
        
%         figure(100+i); hold on;
%         x = time(sound_on-Fs:sound_on+Fs)- time(sound_on);
%         y = speed(sound_on-Fs:sound_on+Fs)-mean(speed(sound_on-Fs:sound_on+Fs));
%         plot(x, y); 
%         line([0, 0], [-10, 50], 'Color', 'black');
%         xlim([-1000 1000])
%         hold off;



    end
    
    % Mean for one session
    
    for k = 1:length(v_bin_list)
        if isempty(v_bin_list{k})
            v_bin_sum{k}(i,:) = nan;
        else
            v_bin_sum{k}(i,:) = sum(v_bin_list{k},1)./sum(v_bin_list{k},'all');
        end
    end
    
    fprintf('%d %d %d %d\n', length(v_bin_list{1}), length(v_bin_list{2}), length(v_bin_list{3}), length(v_bin_list{4}));
    
%                 % Average speed comparison
%         %-----------------------------------------------------------------------------%
    
    if isempty(Hit_speed)
        Hit = {};
    else
        Hit =  {Hit_speed.LED_speed}; Hit = Hit(~cellfun('isempty',Hit));
    end
    Hit_bf_temp = cellfun(@(x) x(end-Fs+1:end),Hit, 'UniformOutput', false);
    Hit_speed_bf_avg{i} = cellfun(@mean, Hit_bf_temp);
    if isempty(CR_speed)
        CR = {};
    else
        CR =  {CR_speed.LED_speed}; CR = CR(~cellfun('isempty',CR));  
    end
    CR_bf_temp = cellfun(@(x) x(end-Fs+1:end), CR, 'UniformOutput', false);
    CR_speed_bf_avg{i} = cellfun(@mean, CR_bf_temp);
    if isempty(FA_speed)
        FA = {};
    else
        FA =  {FA_speed.LED_speed}; FA = FA(~cellfun('isempty',FA));
    end
    FA_bf_temp = cellfun(@(x) x(end-Fs+1:end), FA, 'UniformOutput', false);
    FA_speed_bf_avg{i} = cellfun(@mean, FA_bf_temp);
          
%     figure(500+i); hold on;
% %     
% % %     figure(200); hold on;
%     subplot(3,1,1);
%     plot(total_speed{i});
%     title('total trials');
%     ylabel('speed(cm/s)');
%     ylim([0 40]);
    
%     x = 1:1:length(total_speed{i});
%     p = polyfit(x, total_speed{i},1)
%     figure(201); hold on;
%     plot(Hit_speed_bf_avg{i});
%     title('Hit')
%     figure(202); hold on;
%     plot(CR_speed_bf_avg{i});
%     title('CR')
%     figure(203); hold on;
%     plot(FA_speed_bf_avg{i});
%     title('FA')
%     hold off;
    
    temp = 1:length(data_set);
    Hits = {data_set.Hit}; Hits = cellfun(@(x) x(1), Hits);
    Hits_prob = cumsum(Hits)./temp;
    
    temp = 1:length(data_set);
    CRs = {data_set.CR}; CRs = cellfun(@(x) x(1), CRs);
    CRs_prob = cumsum(CRs)./temp;
    
% % %     figure(204); hold on;
%     subplot(3,1,2);
%     plot(Hits_prob);
%     title('Hit probability');
%     ylim([0 1]);
% % %     figure(205); hold on;
%     subplot(3,1,3);
%     plot(CRs_prob);
%     ylim([0 0.5]);
%     title('CR probability');
%     xlabel('trials')
%     hold off;
    
    
    
    session_bf_speed(i,:) = [mean(Hit_speed_bf_avg{i}), mean(CR_speed_bf_avg{i}), mean(FA_speed_bf_avg{i}) ];


end
%%

%----------------------------Bar graph-------------------------------------------------%
n_bin = length(v_bin_sum);
graph_avg = zeros(4, n_bin);
graph_sem = zeros(4, n_bin);

for i = 1:length(v_bin_sum)
    temp = v_bin_sum{i};
    graph_avg(:,i) = mean(temp, 1, 'omitnan');
    graph_sem(:,i) = std(temp, 1,'omitnan')./sqrt(size(temp(~isnan(temp)),1));
end

ticks = {'Hit', 'Miss', 'CR', 'FA'};
figure;
bar(graph_avg, 'grouped');
set(gca,'XTickLabel', ticks);
hold on;

% add error bar
[ngroups, nbars] = size(graph_avg);
groupwidth = min(0.8, nbars/(nbars+1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, graph_avg(:,i), graph_sem(:,i), 'k', 'linestyle', 'none');
end
%%
%-------------------------Pvalue----------------------------------------------------%
n_bin = length(v_bin_sum);
target = v_bin_sum;
target{n_bin+1} = target{1};

ps = zeros(n_bin+1,4);
for v_i = 1:n_bin
    for i = 1:4
        [h, p] = ttest(target{v_i}(:,i), target{v_i+1}(:,i));
%         [h, p] = ranksum(temp{v_i}(:,i), temp{v_i+1}(:,i));
        ps(v_i,i) = p;
    end
end

ps
%-----------------------------------------------------------------------------%
%% 
%