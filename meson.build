project(
    'com.github.SubhadeepJasu.pebbles', 'vala', 'c',
    meson_version : '>= 0.43',
    version: '0.0.1',
    license : 'GPLv3'
)
gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="com.github.SubhadeepJasu.pebbles"', language:'c')

asresources = gnome.compile_resources(
    'as-resources', 'data/gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

core_deps = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('libsoup-2.4'),
    dependency('json-glib-1.0'),
    meson.get_compiler('vala').find_library('posix'),
    meson.get_compiler('c').find_library('m', required : false)
]

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('src')
