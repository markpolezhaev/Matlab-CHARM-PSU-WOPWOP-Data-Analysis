%{ 
% ZvA_streamlined.m
% This file will read in .txt files from CHARM and store the data into a
% table 
% 
% gets oaspldBA data from charm in .txt file
% gets spl_spectrum data from charm in .txt file
% *maybe* usb stick to get .txt files to matlab
% import both .txt files to matlab
% create master table
% graphs frequency vs total dBA from spl_spectrum
% matlab averages the total dBA from each .txt file
% matlab outputs the averaged number into the correct cell of the matrix
%
%}

clear all
clc

% file reader
% NOTE: files must be named in a specific way: testbase11, testbase12, testbase13, etc
% testbasexy, x stands for row and y stands for column
master = zeros(6, 13);
 for o = 1:width(master) %i shows the column position
    for z = 1:height(master) %j shows the rows position
        fileprefix = 'testbase';
        filesuffix = '_oaspldBA';
        fn = sprintf('%s%d%d%s.dat', fileprefix, z, o, filesuffix);
        if isfile(fn)
            xtemp = readmatrix(fn);
            x = xtemp(:, 7);
            a = mean(x);
            master(z,o) = a;
        else
            master(z, o) = 0;
        end
    end
 end
disp(master);
writematrix(master, 'AvsZa.xlsx');

%{
fignumb = 1;
splall = "spl_all";
splindiv = "spl_indiv";
splavgd = "splavgd";

for o = 1:width(master)
    for z = 1:height(master)
        %open files sequentially
        fileprefix = 'testbase';
        filesuffix = '_spl_spectrum';
        fn = sprintf('%s%d%d%s.dat', fileprefix, z, o, filesuffix);
        %read in data
        if isfile(fn)

            temp = readtable(fn);
            temp = temp(:, [1 end-1 end]);
    
            %SPL graph: all observers overlayed on top of one another
            %find where observer changes to find number of data points per observer
            tempobs = temp(:, 3);
            tempobs = table2array(tempobs);
            nodp = 1; %number of data points per observer
            pos = tempobs(nodp);
    
            while (pos == 1)
                nodp = nodp + 1;
                pos = tempobs(nodp);
            end
            nodp = nodp - 1;
    
            %isolate frequency and total_dBA
            frequency = table2array(temp(:, 1));
            totdBA = table2array(temp(:, 2));
    
            fnsplall = sprintf('%s%d%d%s.png', fileprefix, z, o, splall);
            fnsplindiv = sprintf('%s%d%d%s.png', fileprefix, z, o, splindiv);
            fnsplavgd = sprintf('%s%d%d%s.png', fileprefix, z, o, splavgd);
    
    
    
            %get all of the frequency and totdBA data from observer 1
            a = 1;
            b = nodp;
            x = frequency(a:b);
            y = totdBA(a:b);
            figure(fignumb);
            plot(x, y);
            hold on
    
            while b<=height(frequency) - nodp
                a = a + nodp;
                b = b + nodp;
                x = frequency(a:b);
                y = totdBA(a:b);
                plot(x, y);
            end 
            fig = gcf;
            exportgraphics(gcf, fnsplall);
            close;
            
            
            
            %SPL graph: Graph for each individual observer
            %reset variables
            a = 1;
            b = nodp;
            c=1;
            x = frequency(a:b);
            y = totdBA(a:b);
            figure(fignumb + 1);
            p = tiledlayout(5, 5);
            title(p, "Total dBA (y-axis) vs Frequency (x-axis) per Observer")
            nexttile;
            plot(x, y);
            xlabel("Frequency (Hz)"), ylabel("Total dBA");
            while b<=height(frequency) - nodp
                a = a + nodp;
                b = b + nodp;
                nexttile;
                x = frequency(a:b);
                y = totdBA(a:b);
                plot(x, y);
            end 
            fig = gcf;
            exportgraphics(gcf, fnsplindiv);
            close;
            
            
            
            %SPL grapher: Averaged total dBA for all observers vs frequency
            %store averaged data in new data table
            freqavgd = zeros(nodp, 1);
            
            for freqpos = 1:nodp
                tempsum = 0;
                i = freqpos; %i = 1
                for cycfreq = 1:25 %cycle through code 25 times for 25 observers
                    tempsum = tempsum + totdBA(i);
                    i = i + nodp;
                end
                tempavg = tempsum / 25;
                freqavgd(freqpos) = tempavg;
            end
            
            %get all of the frequency and totdBA data from observer 1
            a = 1;
            x = frequency(a:nodp);
            y = freqavgd;
            figure(fignumb + 2);
            plot(x, y);
            xlabel("Frequency (Hz)"), ylabel("Total dBA")
            title("Observer-averaged total dBA vs Frequency")
            fig = gcf;
            exportgraphics(gcf, fnsplavgd);
            close;
    
            fignumb = fignumb + 3;
        end
    end
end
%}