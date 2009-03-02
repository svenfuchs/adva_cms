Menu.instance(:'admin.main.left', :class => 'left') do 
  item :assets, :url => admin_assets_path(@site), :before => :settings
end
