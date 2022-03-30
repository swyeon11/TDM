glm_feature = 8;

path = cd;
files = dir([path '/*.mat']);
beta_all = zeros(length(files),glm_feature);

temp = zeros(length(files),glm_feature);
beta_bin = {temp,temp,temp,temp};

tr2 = ["m29", "m24", "m22"]; % opposite cue: group2
opp_cue = 0; %0: group1, 1: group2

v_div = [15, 20, 25]; % speed bin criteria
%%


for i = 1:length(files)
    
    load(files(i).name);
    % find mice with opposite cue association with reward
    if contains(files(i).name, tr2)
        opp_cue = 1;
    else
        opp_cue = 0;
    end
    
    hit = arrayfun(@(x) x.Hit, data_set);
    miss = arrayfun(@(x) x.Miss, data_set);
    cr = arrayfun(@(x) x.CR, data_set);
    fa = arrayfun(@(x) x.FA, data_set);

    trial = 1:length(data_set);

    sound_on = arrayfun(@(x) find(x.sound, 1, 'first'), data_set);
    speed = arrayfun(@(data,ind) mean(data.speed(ind-100+1:ind)) , data_set, sound_on);
    temp_speed = speed;
    speed = (speed-min(speed))/(max(speed)-min(speed));
    
    %%%%%%%%%%%%%% speed separation %%%%%%%%%%%%%%%%%%
    speed_bin = {[],[],[],[]};
    
    speed_bin{1} = temp_speed < v_div(1);
    speed_bin{2} = temp_speed < v_div(2);
    speed_bin{3} = temp_speed < v_div(3);
    speed_bin{4} = temp_speed >= v_div(3);
    
        
    %------------------------------------------------%

    accer = arrayfun(@(data) gradient(data.speed)/0.01, data_set,'UniformOutput',false);
    max_acc = cellfun(@(acc, ind) max(acc(ind-100+1:ind)), accer, num2cell(sound_on));   max_acc = (max_acc-min(max_acc))/(max(max_acc)-min(max_acc));
    
    % cue = arrayfun(@(x) x.frequency>16000, data_set);
    cue = arrayfun(@(x) x.frequency, data_set); 
%     cue = (cue-min(cue))/(max(cue)-min(cue));

    if opp_cue == 0 
        cue(cue == 8000) = 0.0; cue(cue == 11300) = 0.5; cue(cue == 13000) = 0.7; cue(cue == 14900) = 0.9;
        cue(cue == 17100) = 1.1; cue(cue == 19700) = 1.3; cue(cue == 22600) = 1.5; cue(cue == 32000) = 2.0;
    elseif opp_cue == 1
        cue(cue == 8000) = 2.0; cue(cue == 11300) = 1.5; cue(cue == 13000) = 1.3; cue(cue == 14900) = 1.1;
        cue(cue == 17100) = 0.9; cue(cue == 19700) = 0.7; cue(cue == 22600) = 0.5; cue(cue == 32000) = 0.0;
    end
    
    cue = cue./max(cue);

    answer = hit+fa;

    % previous ~
    prev_cue = [0 cue(1:end-1)];
    prev_answer = [0 answer(1:end-1)];
    prev_reward = [0 hit(1:end-1)];
    prev_punish = [0 fa(1:end-1)];
    
    win = hit+cr;
    lose = miss+fa;
    
    win_stay_lose_switch = [0 hit(1:end-1)] + [0 miss(1:end-1)];
    
    cumul_reward = cumsum(hit)./sum(hit);
    cumul_punish = cumsum(fa)./sum(fa);

    % normalize (>1)
    trial = trial / length(trial);


%     design_mat = [trial; speed; cue; max_acc; cumul_reward; cumul_punish];
    design_mat = [cue; speed; max_acc; prev_reward; prev_punish; win_stay_lose_switch; cumul_reward; cumul_punish];


    % design matrix
%     figure;
%     imagesc(design_mat')
%     colormap gray
%     axis off
%     caxis([0 1])

    target = cr+fa;

    % GLM
    beta = glmfit(design_mat', target);
    beta_all(i,:) = beta(2:end);
    
    
    
    % GLM for speed bin
    for v_i = 1:length(beta_bin)
        beta = glmfit( design_mat(:,find(speed_bin{v_i}))', target( find(speed_bin{v_i}) ) ) ;
        beta_bin{v_i}(i,:) = beta(2:end);
    end
    
end

'finish'