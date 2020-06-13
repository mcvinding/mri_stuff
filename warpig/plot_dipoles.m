




%% Load template
ftpath   = '/home/mikkel/fieldtrip/fieldtrip'; % this is the path to fieldtrip at Donders
load(fullfile(ftpath, 'template/sourcemodel/standard_sourcemodel3d6mm'));
template_grid = sourcemodel;
template_grid = ft_convert_units(template_grid,'mm');
clear sourcemodel;

%% Find dipol pos in template
%Load...
find(sourcemodel_lin.pos==dip_mag_early_lin.dip.pos)

find(ismember(sourcemodel_spm12.pos, dip_mag_early_spm12.dip.pos))

        
figure; hold on
ft_plot_dipole(dip_mag_early_orig.dip.pos, dip_mag_early_orig.dip.mom(:,1), 'color', 'b');
ft_plot_dipole(dip_mag_early_spm12.dip.pos, dip_mag_early_spm12.dip.mom(:,1), 'color', 'r');



