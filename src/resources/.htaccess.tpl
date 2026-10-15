# aspx as html
AddType text/html .aspx

# adding index.aspx
DirectoryIndex index.aspx index.html index.php

# custom 403 page, assigned to 404 page
ErrorDocument 403 /404.aspx

# custom 404 page
ErrorDocument 404 /404.aspx

# hide .htaccess from browsers
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

# cache update control
<FilesMatch "^[^.].*">
    Header set Last-Modified "__BUILD_TIME__"
</FilesMatch>