# Project name, programming language and version
project (
    'com.github.subhadeepjasu.pebbles',
    'vala', 'c',
    version: '2.0.5',
)

# GNOME module
gnome = import ('gnome')

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    '-DHANDY_USE_UNSTABLE_API',
    language: 'c'
)

# Compiling resources
asresources = gnome.compile_resources (
    'as-resources',
    'data/' + meson.project_name () + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# Listing dependencies
dependencies = [
    dependency ('granite', version: '>=6.2.0'),
    dependency ('gtk+-3.0', version: '>= 3.24.1'),
    dependency ('glib-2.0'),
    dependency ('gsl'),
    dependency ('gobject-2.0'),
    dependency ('libsoup-2.4'),
    dependency ('json-glib-1.0'),
    dependency ('libhandy-1', version: '>=1.4.0'),
    meson.get_compiler ('vala').find_library ('posix'),
    meson.get_compiler ('c').find_library ('m', required : false),
    meson.get_compiler ('c').find_library ('X11', required : false)
]

subdir ('src')

# Define executable
executable (
    meson.project_name (),
    asresources,
    sources,
    dependencies: dependencies,
    install : true
)

subdir ('data')
subdir ('po')

meson.add_install_script ('meson/post_install.py')
