outdir='./newheader/demo/'
idldoc,root=getenv('OMINAS_DIR')+'/demo',output=outdir,title='OMINAS Documentation',$
 /embed,/statistics,format_style='ominas',overview='./overview.idldoc',comment_style='html',template_location='./templates_newheader/',/nosource,/user
replaceoverview,outdir+'overview.html','./overview_demo.html',outdir+'overview.old'
file_copy,'./headerbar.html',outdir,/verbose,/overwrite