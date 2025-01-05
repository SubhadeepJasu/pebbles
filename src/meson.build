# SPDX-License-Identifier: GPL-3.0-or-later
configure_file(
          input: 'pebbles.in',
         output: meson.project_name(),
  configuration: conf,
        install: true,
   install_mode: 'rwxr-xr-x',
    install_dir: bindir,
)

python.install_sources(
  files(
    'application.py'
  ),
  subdir: 'pebbles',
)

python.install_sources(
  files(
    'shell/__init__.py',
    'shell/main_window.py',
  ),
  subdir: 'pebbles/shell',
)

python.install_sources(
  files(
    'core/__init__.py',
    'core/utils.py',
    'core/tokenizer.py',
    'core/memory.py',
    'core/scientific_calculator.py',
  ),
  subdir: 'pebbles/core',
)

configure_file(
         output: 'config.h',
  configuration: vala_conf
)
config_dep = valac.find_library('config',
  dirs: meson.project_source_root () / 'src'
)

pebbles_lib = shared_library('pebbles',
  gresource_bundle,
  files(
    'Common.vala',
    'Application.vala',
    'Settings.vala',
    'shell/MainWindow.vala',
    'shell/widgets/StyledButton.vala',
    'shell/widgets/PopoverMenuItem.vala',
    'shell/widgets/Display.vala',
    'shell/widgets/ScientificDisplay.vala',
    'shell/views/ScientificView.vala'
  ),
             vala_gir: 'Pebbles-3.gir',
         dependencies: dependencies + config_dep,
  include_directories: include_directories('.'),
            link_args: ['-lm',],
              install: true,
          install_dir: [true],
          vala_args: [
            '--gresourcesdir=' + meson.project_build_root() + '/data/'
          ]
)

custom_target('pebbles typelib',
      command: [find_program('g-ir-compiler'), '--shared-library', 'libpebbles.so', '--output', '@OUTPUT@', meson.current_build_dir() / 'Pebbles-3.gir'],
       output: 'Pebbles-3.typelib',
      depends: pebbles_lib,
      install: true,
  install_dir: get_option('libdir') / 'girepository-1.0',
)
