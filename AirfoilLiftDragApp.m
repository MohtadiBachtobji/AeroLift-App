function AirfoilLiftDragApp
    % AIRFOILLIFTDRAGAPP v1.0 - Professional airfoil lift & drag analysis
    % By Mohtadi Bach Tobji 

    %%  Main Figure 
    f = uifigure('Name','AeroLift: Airfoil Analysis v1.0','Position',[100 100 1550 800]);

    %  Cozy Bold Title 
    titleLabel = uilabel(f, ...
        'Text', 'AeroLift: Airfoil Analysis v1.0', ...
        'FontSize', 22, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'Position', [0 740 f.Position(3) 40]);  % full width, top of figure
    authorLabel = uilabel(f, ...
        'Text', '© 2025 Mohtadi Bach Tobji', ...
        'FontSize', 12, ...
        'FontWeight', 'normal', ...
        'HorizontalAlignment', 'center', ...
        'Position', [0 720 f.Position(3) 20]);  % slightly below main title
    %%  LEFT CONTROL PANEL 
    controlPanel = uipanel(f,'Title','Simulation Controls','FontWeight','bold','FontSize',12,...
        'Position',[20 150 260 500]);

    % Input Fields
    uilabel(controlPanel,'Text','Air Density (kg/m³)','Position',[20 420 200 20]);
    rhoField = uieditfield(controlPanel,'numeric','Value',1.225,'Position',[20 400 100 22]);

    uilabel(controlPanel,'Text','Velocity (m/s)','Position',[20 360 200 20]);
    vField = uieditfield(controlPanel,'numeric','Value',50,'Position',[20 340 100 22]);

    uilabel(controlPanel,'Text','Wing Area (m²)','Position',[20 300 200 20]);
    sField = uieditfield(controlPanel,'numeric','Value',1.5,'Position',[20 280 100 22]);

    uilabel(controlPanel,'Text','CD₀ (Zero-lift drag)','Position',[20 240 200 20]);
    cd0Field = uieditfield(controlPanel,'numeric','Value',0.02,'Position',[20 220 100 22]);

    uilabel(controlPanel,'Text','k (Induced drag factor)','Position',[20 180 200 20]);
    kField = uieditfield(controlPanel,'numeric','Value',0.04,'Position',[20 160 100 22]);

    uilabel(controlPanel,'Text','Angle of Attack Range','Position',[20 120 200 20]);
    alphaMin = uieditfield(controlPanel,'numeric','Value',-5,'Position',[20 100 50 22]);
    uilabel(controlPanel,'Text','to','Position',[75 100 20 22]);
    alphaMax = uieditfield(controlPanel,'numeric','Value',15,'Position',[95 100 50 22]);
    uilabel(controlPanel,'Text','Step','Position',[150 100 40 22]);
    alphaStep = uieditfield(controlPanel,'numeric','Value',1,'Position',[190 100 50 22]);

    % Buttons
    runBtn     = uibutton(controlPanel,'Text','Run Simulation','BackgroundColor',[0.2 0.7 0.3],...
        'FontWeight','bold','Position',[20 50 220 35],'ButtonPushedFcn',@(btn,event)runSimulation());
    clearBtn   = uibutton(controlPanel,'Text','Clear','BackgroundColor',[0.85 0.33 0.1],...
        'FontWeight','bold','Position',[20 10 100 35],'ButtonPushedFcn',@(btn,event)clearPlots());
    exportBtn  = uibutton(controlPanel,'Text','Export CSV','BackgroundColor',[0.3 0.45 0.85],...
        'FontWeight','bold','Position',[140 10 100 35],'ButtonPushedFcn',@(btn,event)exportCSV());
    defaultBtn = uibutton(controlPanel,'Text','Defaults','BackgroundColor',[0.9 0.8 0.2],...
        'FontWeight','bold','Position',[75 -40 100 35],'ButtonPushedFcn',@(btn,event)setDefaults());

    %%  CENTER PANEL (PLOTS) 
    plotPanel = uipanel(f,'Title','Simulation Results','FontWeight','bold','FontSize',12,...
        'Position',[290 100 800 580]);

    ax1 = uiaxes(plotPanel,'Position',[30 380 340 180]);
    title(ax1,'C_L and C_D vs Angle of Attack'); xlabel(ax1,'Angle (°)'); ylabel(ax1,'Coefficient'); grid(ax1,'on');

    ax2 = uiaxes(plotPanel,'Position',[430 380 340 180]);
    title(ax2,'Lift vs Drag Curve'); xlabel(ax2,'Drag (N)'); ylabel(ax2,'Lift (N)'); grid(ax2,'on');

    ax3 = uiaxes(plotPanel,'Position',[180 60 440 320]); % airfoil plot
    title(ax3,'Airfoil Profile'); grid(ax3,'on'); axis(ax3,'equal');

    %%  RIGHT PANEL (TABLE + MAX L/D) 
    resultPanel = uipanel(f,'Title','Numerical Results','FontWeight','bold','FontSize',12,...
        'Position',[1120 150 380 580]);

    resultTable = uitable(resultPanel,'Position',[20 80 340 470]);
    resultTable.ColumnName = {'α (°)','C_L','C_D','L (N)','D (N)','L/D'};
    resultTable.RowName = {};

    maxLDLabel = uilabel(resultPanel,'Text','Max L/D: -','FontWeight','bold',...
        'Position',[20 30 340 25],'FontSize',12,'HorizontalAlignment','center','BackgroundColor',[0.95 0.95 0.95]);

    %% SIMULATION FUNCTION 
    function runSimulation()
        % Inputs
        rho = rhoField.Value; V = vField.Value; S = sField.Value; CD0 = cd0Field.Value; k = kField.Value;
        alpha_deg = alphaMin.Value:alphaStep.Value:alphaMax.Value;
        alpha_rad = deg2rad(alpha_deg);

        % Aerodynamics
        CL = 2*pi*alpha_rad; CD = CD0 + k*CL.^2; L = 0.5*rho*V^2*S.*CL; D = 0.5*rho*V^2*S.*CD;
        LD = L./D;

        %% Update plots 
        cla(ax1); cla(ax2);

        % Plot CL and CD once
        h1 = plot(ax1,alpha_deg,CL,'b-','LineWidth',2); hold(ax1,'on');
        h2 = plot(ax1,alpha_deg,CD,'r-','LineWidth',2); hold(ax1,'off');
        if isempty(ax1.Legend)
            legend(ax1,[h1 h2],{'C_L','C_D'},'Location','best');
        end

        cla(ax2); plot(ax2,D,L,'m-','LineWidth',2); grid(ax2,'on');

        %% Airfoil animation
        x = linspace(0,1,200);
        m = 0.02; p = 0.4; t = 0.12;
        yt = 5*t*(0.2969*sqrt(x)-0.1260*x-0.3516*x.^2+0.2843*x.^3-0.1015*x.^4);
        yc = zeros(size(x)); dyc_dx = zeros(size(x));
        for i = 1:length(x)
            if x(i) < p
                yc(i) = m/p^2*(2*p*x(i)-x(i)^2);
                dyc_dx(i) = 2*m/p^2*(p-x(i));
            else
                yc(i) = m/(1-p)^2*((1-2*p)+2*p*x(i)-x(i)^2);
                dyc_dx(i) = 2*m/(1-p)^2*(p-x(i));
            end
        end
        theta = atan(dyc_dx);
        xu = x - yt.*sin(theta); yu = yc + yt.*cos(theta);
        xl = x + yt.*sin(theta); yl = yc - yt.*cos(theta);

        scaleFactor = 1.5; % scale airfoil
        lim = scaleFactor * 1.5; % axis limits

        for i = 1:length(alpha_deg)
            cla(ax3);
            alpha = alpha_deg(i);
            R = [cosd(alpha) -sind(alpha); sind(alpha) cosd(alpha)];
            coords = scaleFactor * R * [ [xu fliplr(xl)]; [yu fliplr(yl)] ]; % apply scaling
            fill(ax3, coords(1,:), coords(2,:), [0.7 0.9 1], 'EdgeColor', [0 0.2 0.5], 'LineWidth', 1.5);
            title(ax3, sprintf('Airfoil at α = %.1f°', alpha));
            xlabel(ax3,'Chord (x/c)'); ylabel(ax3,'Thickness (y/c)');
            axis(ax3,'equal'); xlim(ax3, [-lim lim]); ylim(ax3, [-lim lim]);
            grid(ax3,'on');
            pause(0.05);
        end

        %% Update table & max L/D
        data = [alpha_deg' CL' CD' L' D' LD'];
        resultTable.Data = data;
        [maxLD, idx] = max(LD);
        maxLDLabel.Text = sprintf('Max L/D = %.2f at α = %.1f°', maxLD, alpha_deg(idx));
    end

    %% BUTTON FUNCTIONS
    function clearPlots()
        cla(ax1); cla(ax2); cla(ax3);
        resultTable.Data = {};
        maxLDLabel.Text = 'Max L/D: -';
    end

    function setDefaults()
        rhoField.Value = 1.225; vField.Value = 50; sField.Value = 1.5; cd0Field.Value = 0.02; kField.Value = 0.04;
        alphaMin.Value = -5; alphaMax.Value = 15; alphaStep.Value = 1;
    end

    function exportCSV()
        if isempty(resultTable.Data)
            uialert(f,'No data to export. Run the simulation first.','Export Error'); return;
        end
        [file,path] = uiputfile('AirfoilResults.csv','Save Results As');
        if isequal(file,0), return; end
        writematrix(resultTable.Data,fullfile(path,file));
        uialert(f,'CSV exported successfully!','Export Complete');
    end
end
