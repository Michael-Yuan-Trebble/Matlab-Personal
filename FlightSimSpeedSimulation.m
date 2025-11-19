maxSpeed = 2000;
accel = 100;
dt = 0.1;
tEnd = 30;
time = 0:dt:tEnd;

usePitch = input("Use pitch effects? yes(1) no(0): ");

throttles = [0.0,0.5,1.0];
pitches = [10,20,30,40,50,60,70,80,90];

if ~usePitch
    figure;hold on;
    for th = throttles
    speed = zeros(size(time));
    currentSpeed = 100;
    speed(1) = currentSpeed;
        for i =2:length(time)
            drag = ApplyDrag(accel,th,currentSpeed);
            trueAccel = accel*dt - drag*dt;
            currentSpeed = currentSpeed + trueAccel;
            currentSpeed = min(max(currentSpeed,0),maxSpeed);
            speed(i) = currentSpeed;
        end
    plot(time,speed,'DisplayName',sprintf("Throttle %.1f",th));
    end
    xlabel('Time (s)');
    ylabel('Speed (m/s)');
    title('Aircraft Speed vs Time at Different Throttles');
    legend;
    grid on;
else
    figure; hold on;
    answer = inputdlg('Enter starting speed:', 'Start Speed', 1, {'100'});
    if isempty(answer); return; end
    speed = str2double(answer{1});

    for pitch = pitches
        speedRange = zeros(size(time));
        currentSpeed = speed;

        speedRange(1) = currentSpeed;

        for i = 2:length(time)
            drag = ApplyPitch(pitch);
            currentSpeed = currentSpeed - drag * dt;   % include dt!
            currentSpeed = min(max(currentSpeed,0), maxSpeed);
            speedRange(i) = currentSpeed;
        end

        plot(time, speedRange, 'DisplayName', sprintf("Pitch %.1f°", pitch));
    end
    xlabel('Time (s)');
    ylabel('Speed (m/s)');
    title('Aircraft Speed vs Time at Different Pitches');
    legend;
    grid on;
end

function Drag = ApplyDrag(accel,throttle,speed)
    throttleStage = getThrottle(throttle);
    switch throttleStage
        case ThrottleStages.Slow
            targetSpeed = 0;
        case ThrottleStages.Medium
            targetSpeed = 1000;
        case ThrottleStages.Fast
            targetSpeed = 2000;
    end
    if targetSpeed == 0
        Drag = accel * 2;
        return;
    end

    totalFlightPercent = speed / targetSpeed;
    Drag = 0;
    if totalFlightPercent >= 0.8 && totalFlightPercent <= 1.05
        Drag = accel / (1.05 + power(2,-0.01 * (speed - targetSpeed)));
    elseif totalFlightPercent > 1.05
        Drag = (accel * 4) / (1 + power(2,-0.01 * (speed - targetSpeed)));
    end
end

function stage = getThrottle(inThrottle)
    inThrottle = inThrottle * 100;
    if inThrottle <= 40
        stage = ThrottleStages.Slow;
    elseif inThrottle <= 80
        stage = ThrottleStages.Medium;
    else
        stage = ThrottleStages.Fast;
    end
end

function PitchDrag = ApplyPitch(pitchAngle)
    pitchAngle = power(pitchAngle,5);
    PitchDrag = pitchAngle / 50;
end