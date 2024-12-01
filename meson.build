# SPDX-License-Identifier: GPL-3.0-or-later
project('com.github.subhadeepjasu.pebbles', 'c', 'vala',
        version: '3.0.0',
        meson_version: '>= 1.3.2',
        default_options: [ 'warning_level=2', 'werror=false', ],
)

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gio-2.0'),
  dependency('gtk4'),
  dependency('granite-7'),
  dependency('libadwaita-1', version: '>= 1.5'),
  dependency('gee-0.8'),
]

valac = meson.get_compiler('vala')

application_id = 'com.github.subhadeepjasu.pebbles'
copyright = '2019 - 2024'
homepage_url = 'https://github.com/subhadeepjasu/pebbles'
vcs_url = 'https://github.com/subhadeepjasu/pebbles'
issue_url = vcs_url + '/issues'
help_url = issue_url
author = 'Subhadeep Jasu'

i18n = import('i18n')
gnome = import('gnome')
python = import('python').find_installation('python3')

prefix = get_option('prefix')
datadir = get_option('datadir')
bindir = get_option('bindir')
version = meson.project_version()
pkgdatadir = join_paths(prefix, datadir, meson.project_name())
localedir = join_paths(prefix, get_option('localedir'))
debug = get_option('buildtype') == 'debug'

if debug
  version += '-' + run_command('git', 'rev-parse', '--short', 'HEAD', check: true).stdout().strip()
endif


conf = configuration_data()
conf.set('APPLICATION_ID', application_id)
conf.set('GETTEXT_PACKAGE', meson.project_name())
conf.set('AUTHOR', author)
conf.set('COPYRIGHT', copyright)
conf.set('VCS_URL', vcs_url)
conf.set('ISSUE_URL', issue_url)
conf.set('HELP_URL', help_url)
conf.set('LOCALEDIR', localedir)
conf.set('PKGDATADIR', pkgdatadir)
conf.set('PROJECT_NAME', meson.project_name())
conf.set('HOMEPAGE_URL', homepage_url)
conf.set('DEBUG', debug)

vala_conf = configuration_data()
vala_conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
vala_conf.set_quoted('LOCALEDIR', localedir)
vala_conf.set_quoted('VERSION', version)
vala_conf.set_quoted('AUTHOR', author)
vala_conf.set_quoted('HOMEPAGE_URL', homepage_url)
vala_conf.set_quoted('ISSUE_URL', issue_url)

add_project_arguments (
  '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
  language: 'c'
)

subdir('data')
subdir('src')

gnome.post_install(
     glib_compile_schemas: true,
    gtk_update_icon_cache: true,
#   update_desktop_database: true
)
