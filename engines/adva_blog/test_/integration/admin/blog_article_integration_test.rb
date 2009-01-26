# # An empty site.
# 
# click on 'new'
# fill in and submit article form
# assert admin/article/edit
# fill in (change) and submit article form
# assert admin/article/edit
#
# click on 'preview'
# assert blog/show
# assert page not cached
# 
# go to admin/articles/index
# assert article listed
# click on 'delete'
# 
# assert admin/articles/index
# assert list is empty