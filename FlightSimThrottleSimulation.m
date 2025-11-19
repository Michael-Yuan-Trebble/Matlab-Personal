dt = 0.1;
T = 60;
time = 0:dt:T;

throttleLevels = [0.0,0.1,0.2 0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
listedThrust = 10;
speeds = zeros(length(throttleLevels),length(time));
speedsClimb = zeros(length(throttleLevels),length(time));
thrust = 0;
for t = 1:length(throttleLevels)
    throttle = throttleLevels(t);
    speed = zeros(1,length(time));
    speedClimb = zeros(1,length(time));
    height = 0;
    for i = 2:length(time)
        if throttle >= 0.9
            thrust = listedThrust * throttle * 5;
        elseif (throttle >= 0.8)
            thrust = listedThrust * throttle * 2;
        elseif (throttle >= 0.4)
            thrust = listedThrust * throttle;
        elseif (throttle >= 0.1)
            thrust = -(listedThrust * (1 - throttle) * 2);
        else
            thrust = -(listedThrust * (1 - throttle) * 5);
        end
        height = height + 100;
        drag = applySpeedDrag(speed(i-1));
        accel = thrust - drag;
        accelClimb = thrust - (applyClimbDrag(height) + applySpeedDrag(speed(i-1)));
        speed(i) = speed(i-1) + accel*dt;
        speedClimb(i) = speedClimb(i-1) + accelClimb*dt;
    end
    speeds(t, :) = speed;
    speedsClimb(t, :) = speedClimb;
end

figure;

subplot(3,1,1);
hold on;
colors = lines(length(throttleLevels));
for t = 1:length(throttleLevels)
    plot(time, speeds(t,:), 'Color',colors(t,:),'LineWidth',2, ...
        'DisplayName', sprintf('Throttle %.0f%%', throttleLevels(t)*100));
end
xlabel('Time (s)');
ylabel('Speed');
title('Speed vs Time at Different Throttle Levels');
legend;
grid on;

subplot(3,1,2);
hold on;
for t = 1:length(throttleLevels)
    plot(time, speedsClimb(t,:), 'Color',colors(t,:),'LineWidth',2, ...
        'DisplayName', sprintf('Throttle %.0f%%', throttleLevels(t)*100));
end
xlabel('Time (s)');
ylabel('Speed in a Climb');
title('Speed in a Climb vs Time at Different Throttle Levels');
legend;
grid on;

aoaSpeed = 1000;
aoaAngles = [0.087,0.175,0.262,0.349];
speeds = zeros(length(aoaAngles),length(time));
for t = 1:length(aoaAngles)
    angle = aoaAngles(t);
    speed = zeros(1, length(time));
    speed(1) = aoaSpeed;
    drag = applyAOADrag(angle);
    aoaSpeed = 1000;
    for i = 2:length(time)
        speed(i) = speed(i-1) - drag*dt;
    end
    speeds(t, :) = speed;
end

subplot(3,1,3);
hold on;
for t = 1:length(aoaAngles)
    plot(time, speeds(t,:), 'Color',colors(t,:),'LineWidth',2, ...
        'DisplayName', sprintf('Turning Alpha %.3f', aoaAngles(t)));
end
xlabel('Time (s)');
ylabel('Speed During Turn');
title('Speed Bleed vs Time at Different Alphas');
legend;
grid on;

function out = applySpeedDrag(speed)
    out = 15 / (1 + 2.^(-0.1 *(speed - 650)));
end

function out = applyClimbDrag(height)
    out = 0.00001 * height^1.3;
end

function out = applyAOADrag(angleOfAttack)
    out = 0.75 * angleOfAttack^2;
end