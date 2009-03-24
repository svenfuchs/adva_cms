Menu.instance(:'admin.top.left', :class => 'left') do 
  item :newsletters, :url => admin_newsletters_path(@site), :after => :assets
end
