Menu.instance(:'admin.main.left', :class => 'left') do 
  item :newsletters, :url => admin_newsletters_path(@site), :after => :assets
end