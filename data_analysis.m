%% Statistical anal
close all
clear all
avg_dm1 = 0;
avg_dm2 = 0;
avg_dm3 = 0;

curr_dir = cd;
% Cutting the first and last 10%, as they are only measurement rubbish!!
st_point_proc = 0.1;
end_point_proc = 0.9;


cd all_meas_data\
getFile = dir('*.mat');

dm1_arr = zeros(1,length(getFile)/3);
dm2_arr = zeros(1,length(getFile)/3);
dm3_arr = zeros(1,length(getFile)/3);


for i = 1:length(getFile)
    name = getFile(i).name;
    load(name);
    traj_num = 1 + floor((i-1)/3);
    c_str = strsplit(name,{'_','.'});
    scen_num = str2num(c_str{end-1});
    ep = floor(length(mat_data.Zeitstempel) * end_point_proc);
    st = floor(length(mat_data.Zeitstempel) * st_point_proc);
    data = mat_data.d_M(st:ep);

    switch scen_num
        case 1
            dm1_arr(traj_num) = mean(abs(data));
            avg_dm1 = avg_dm1 + mean(abs(data));

        case 2
            dm2_arr(traj_num) = mean(abs(data));
            avg_dm2 = avg_dm2 + mean(abs(data));
            if isnan(dm2_arr(traj_num))
                disp('Huston, Problem with the measurements...')
            end

        case 3
            dm3_arr(traj_num) = mean(abs(data));
            avg_dm3 = avg_dm3 + mean(abs(data));

    end


end

cd(curr_dir)

dm1_arr = dm1_arr(dm1_arr~=0);
dm2_arr = dm2_arr(dm2_arr~=0);
dm3_arr = dm3_arr(dm3_arr~=0);



avg_dm1 = mean(dm1_arr);
std_dm1 = std(dm1_arr);
avg_dm2 = mean(dm2_arr);
std_dm2 = std(dm2_arr);
avg_dm3 = mean(dm3_arr);
std_dm3 = std(dm3_arr);
disp("---------------------------")
[~,p_21] = ttest2(dm2_arr,dm1_arr,'Vartype','unequal','Tail','right')
[~,p_23] = ttest2(dm2_arr,dm3_arr,'Vartype','unequal','Tail','right')
[~,p_13] = ttest2(dm1_arr,dm3_arr,'Vartype','unequal','Tail','right')


%% Plotting boxplots
both_means = [mean(dm1_arr), mean(dm2_arr), mean(dm3_arr)];
figure()
boxchart([dm1_arr', dm2_arr', dm3_arr'])
hold on
set(gca,'XTickLabel',{'LISC','NC','FISC'})
set(gca,'TickLabelInterpreter','latex')
hold on
ylabel('$|d|_\mathrm{m}$ in m','Interpreter','latex')

hold on
plot(both_means,'o','Color','red')

grid on

%% Plotting trajectories
% Compare LISC and NC

name_li = 'all_meas_data\2021_Apr_26_14-28-19M5ControllerNr_1.mat';
load(name_li);
%Plot steps for tikz,
steps_pl = 5;

figure("Name","Comparing NC LISC")
hold on
title(strcat("v = ",num2str(mat_data.v_desired)));
legend show
grid on


% 0.01 chaming from cm --> m
% steps are necessary for the
pref_1 = plot(-0.01*mat_data.y_ref_M(1:steps_pl:end), 0.01*mat_data.x_ref_M(1:steps_pl:end),'-',...
    'LineWidth',3,'DisplayName','Ref','Color',[0 0.4470 0.7410]);
pref_1.Color(4) = 0.3;

pref_1 = plot(-0.01*mat_data.Y_ref(1:steps_pl:end), 0.01*mat_data.X_ref(1:steps_pl:end),'-',...
    'LineWidth',3,'DisplayName','Ref','Color',[0.8500 0.3250 0.0980]);
pref_1.Color(4) = 0.3;

plot(-0.01*mat_data.y_ist_M(1:steps_pl:end), 0.01*mat_data.x_ist_M(1:steps_pl:end),'-.','DisplayName','Lim Inf',...
    'LineWidth',1.5,'Color',[0.9290 0.6940 0.1250])
plot(-0.01*mat_data.Y_ist(1:steps_pl:end), 0.01*mat_data.X_ist(1:steps_pl:end),'-.','DisplayName','Lim Inf',...
    'LineWidth',1.5,'Color',[0.4940 0.1840 0.5560])

% load non-cooperative controller
name_nc = 'all_meas_data\2021_Apr_26_14-29-49M5ControllerNr_2.mat';
load(name_nc);
%The first 20% and the last 3 % of the times are ommited,
star_p = floor(length(mat_data.Zeitstempel) * 0.2);
last_p = floor(length(mat_data.Zeitstempel) * 0.97);
steps_pl = 5;

plot_leg = 'Non-coop';
plot(-0.01*mat_data.y_ist_M(1:steps_pl:end), 0.01*mat_data.x_ist_M(1:steps_pl:end),'DisplayName',plot_leg,...
    'LineWidth',1.5, 'Color',[0.4660 0.6740 0.1880])
plot(-0.01*mat_data.Y_ist(1:steps_pl:end), 0.01*mat_data.X_ist(1:steps_pl:end),'DisplayName',plot_leg,...
    'LineWidth',1.5, 'Color', [0.3010 0.7450 0.9330])

xlim([20,110])
ylim([3.25,8.2])
xlabel('x distance in m')
ylabel('y distance in m')
box on;

title('')
legend('Location','southwest','NumColumns',3)

%% Plotting trajectories
% Compare LISC and FISC

name_li = 'all_meas_data\2021_May_12_11-49-01M4ControllerNr_1.mat';
load(name_li);



figure("Name","Comparing FISC LISC")
hold on
title(strcat("v = ",num2str(mat_data.v_desired)));
legend show
grid on


% 0.01 chaming from cm --> m
% steps are necessary for the
pref_1 = plot(-0.01*mat_data.y_ref_M(1:steps_pl:end), 0.01*mat_data.x_ref_M(1:steps_pl:end),'-',...
    'LineWidth',3,'DisplayName','Ref','Color',[0 0.4470 0.7410]);
pref_1.Color(4) = 0.3;

pref_1 = plot(-0.01*mat_data.Y_ref(1:steps_pl:end), 0.01*mat_data.X_ref(1:steps_pl:end),'-',...
    'LineWidth',3,'DisplayName','Ref','Color',[0.8500 0.3250 0.0980]);
pref_1.Color(4) = 0.3;

plot(-0.01*mat_data.y_ist_M(1:steps_pl:end), 0.01*mat_data.x_ist_M(1:steps_pl:end),'-.','DisplayName','Lim Inf',...
    'LineWidth',1.5,'Color',[0.9290 0.6940 0.1250])
plot(-0.01*mat_data.Y_ist(1:steps_pl:end), 0.01*mat_data.X_ist(1:steps_pl:end),'-.','DisplayName','Lim Inf',...
    'LineWidth',1.5,'Color',[0.4940 0.1840 0.5560])

% load non-cooperative controller
name_fi = 'all_meas_data\2021_May_12_11-46-16M4ControllerNr_3.mat';
load(name_fi);
%The first 20% and the last 3 % of the times are ommited,
star_p = floor(length(mat_data.Zeitstempel) * 0.2);
last_p = floor(length(mat_data.Zeitstempel) * 0.97);
steps_pl = 5;

plot_leg = 'FISC';
plot(-0.01*mat_data.y_ist_M(1:steps_pl:end), 0.01*mat_data.x_ist_M(1:steps_pl:end),'DisplayName',plot_leg,...
    'LineWidth',1.5, 'Color',[0.4660 0.6740 0.1880])
plot(-0.01*mat_data.Y_ist(1:steps_pl:end), 0.01*mat_data.X_ist(1:steps_pl:end),'DisplayName',plot_leg,...
    'LineWidth',1.5, 'Color', [0.3010 0.7450 0.9330])

xlim([20,110])
ylim([1.95,8.6])
xlabel('x distance in m')
ylabel('y distance in m')
box on;
title('')
legend('Location','southwest','NumColumns',3)
