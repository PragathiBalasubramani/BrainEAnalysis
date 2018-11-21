function fig = erpSourceAnalysis(EEGs, hmfile, Peaklatency, EEGtimes,  taskname, condition, nwname)

hm = headModel.loadFromFile(hmfile);
n = length(Peaklatency);

for k=1:n
    ind = Peaklatency(k)+(-5:5);
    ind(ind>Peaklatency(end)) = [];
    X(:,k) = mean(abs(mean(EEGs(:,ind,:),3)),2);
end


cmap = bipolar(256,0.75);
clim = [0 prctile(X(:),95)];
fig = figure('Tag', taskname, 'UserData',['ERP Source Analysis - task:' taskname ' condition:' condition ' network:' nwname  ' Alignment:' flag_alignment]);
fig.Position(3:4) = [1363 356];
for k=1:n
    ax = subplot(3,n,k);
    patch('vertices',hm.cortex.vertices,'Faces',hm.cortex.faces,'FaceVertexCData',X(:,k),...
        'FaceColor','interp','FaceLighting','phong','LineStyle','none','FaceAlpha',0.3,'SpecularColorReflectance',0,...
        'SpecularExponent',25,'SpecularStrength',0.25,'Parent',ax);
    set(ax,'Clim',clim,'XTick',[],'Ytick',[],'Ztick',[],'XColor',[1 1 1],'YColor',[1 1 1], 'ZColor',[1 1 1]);
    axis(ax, 'vis3d','equal','tight')
    view([-90 90])
    if k==1
        xlabel(ax,'Dorsal');
        title(ax,'L         R','fontweight','normal','fontsize',9);
    end
    if k==n
        cb = colorbar(ax,'position', [0.9219 0.7093 0.0049 0.2157]);
        cb.Ticks = cb.Ticks([1 end]);
        cb.TickLabels = {'0','Max'};
    end
    
    ax = subplot(3,n,k+n);
    patch('vertices',hm.cortex.vertices,'Faces',hm.cortex.faces,'FaceVertexCData',X(:,k),...
        'FaceColor','interp','FaceLighting','phong','LineStyle','none','FaceAlpha',0.3,'SpecularColorReflectance',0,...
        'SpecularExponent',25,'SpecularStrength',0.25,'Parent',ax);
    set(ax,'Clim',clim,'XTick',[],'Ytick',[],'Ztick',[],'XColor',[1 1 1],'YColor',[1 1 1], 'ZColor',[1 1 1]);
    axis(ax, 'vis3d','equal','tight')
    view([0 0])
    if k==1
        zlabel(ax,'Lateral');
        title(ax,'P         A','fontweight','normal','fontsize',9);
    end
    
    ax = subplot(3,n,k+2*n);
    patch('vertices',hm.cortex.vertices,'Faces',hm.cortex.faces,'FaceVertexCData',X(:,k),...
        'FaceColor','interp','FaceLighting','phong','LineStyle','none','FaceAlpha',0.3,'SpecularColorReflectance',0,...
        'SpecularExponent',25,'SpecularStrength',0.25,'Parent',ax);
    set(ax,'Clim',clim,'XTick',[],'Ytick',[],'Ztick',[],'XColor',[1 1 1],'YColor',[1 1 1], 'ZColor',[1 1 1]);
    axis(ax, 'vis3d','equal','tight')
    view(ax,[-90 0]);
    if k==1
        zlabel(ax,'Back');
        title(ax,'L         R','fontweight','normal','fontsize',9);
    end
    ylabel(ax,[num2str(EEGtimes(Peaklatency(k))) ' ms'])
end
colormap(cmap(end/2:end,:));
if n<3
    fig.Position(3:4) = [428 356];
end
end
