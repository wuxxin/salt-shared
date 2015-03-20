
for piece in template.split('/'):
    if path.sep in piece 
        or (path.altsep and path.altsep in piece) 
        or piece == path.pardir:
        raise IOError(template)
    elif piece:
        pieces.append(piece)


selfpath=path.absname(path.dirname(__file__))


class RelativeFileSystemLoader(FileSystemLoader):
    
    def get_source(self, environment, template):
        abstemplate = path.abspath(template)
        
        if abstemplate != template:
            abstemplate= path.abspath(os.path.join(basepath, template))
            if not abstemplate.beginswith(basepath):
                raise TemplateNotFound(template)
        
        filename = os.path.abspath(template)
        f = open_if_exists(filename)
        if f is None:
            raise TemplateNotFound(template)
        try:
            contents = f.read().decode(self.encoding)
        finally:
            f.close()

        mtime = path.getmtime(filename)
         
        def uptodate():
            try:
                return path.getmtime(filename) == mtime
            except OSError:
                return False
            return contents, filename, uptodate
              

class RelEnvironment(jinja2.Environment):
    """Override join_path() to enable relative template paths."""
    def join_path(self, template, parent):
        if template.startswith('.'+ path.sep) or ('..'+ path.sep):
            t = os.abspath(os.path.join(os.path.dirname(parent), os.path.normpath(template)))
            if t.startswith(os.abspath(os.path.dirname(parent))):
                return t
            elif t.startswith(self.loader.base_path):
                return t
 
        t = os.abspath(os.path.join(self.loader.base_path, os.path.normpath(template)))
        if t.startwith(os.path.dirname(self.loader.base_path)):
            return t
        else:
            return None

  
        