blueprint_files = [
  'ui/main_window.blp',
  'ui/preferences_dialog.blp',
  'ui/shortcuts_dialog.blp',
  'ui/button.blp',
  'ui/popover_menu_item.blp',
  'ui/display.blp',
  'ui/history_display.blp',
  'ui/scientific_display.blp',
  'ui/scientific_view.blp'
]

blueprint_compiler = find_program('blueprint-compiler')

blueprints_ui = []
bfs = []
foreach b : blueprint_files
	blueprints_ui += b.replace('.blp', '.ui')
    bfs += meson.current_source_dir() / b
endforeach

r = run_command('blueprint-compiler', 'batch-compile', meson.project_build_root() / 'data/ui', meson.current_source_dir() / 'ui', bfs, check: true)
r.returncode()

blueprints = custom_target('blueprints',
    input: files(blueprint_files),
   output: '.',
  command: [blueprint_compiler, 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

sassc = find_program('sassc')

sassc_opts = [ '-a', '-M', '-t', 'compact' ]

stylesheet_deps = custom_target(
    'style.scss',
    input: 'style.scss',
    output: 'style.css',
    command: [
        sassc,
        sassc_opts,
        '@INPUT@',
        '@OUTPUT@',
    ],
    install: true,
    install_dir: get_option('datadir') / meson.project_name()
)

gresource_bundle = gnome.compile_resources(
    meson.project_name(),
    meson.project_name() + '.gresource.xml',
    source_dir: [
        meson.current_build_dir(),
        meson.current_source_dir(),
    ],
    dependencies: [
        blueprints,
        stylesheet_deps
    ],
    gresource_bundle: true,
    install: true,
    install_dir: pkgdatadir,
    c_name: meson.project_name(),
)

install_data (
    join_paths ('fonts', 'DotGothic16', 'DotGothic16-Regular.ttf'),
    install_dir: join_paths (get_option ('datadir'), 'fonts', 'truetype', 'DotGothic16')
)

# Install icons
icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data (
        join_paths ('icons', i, meson.project_name () + '.svg'),
        install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data (
        join_paths ('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths (get_option ('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

install_data(
  join_paths('icons', 'symbolic', meson.project_name() + '.svg'),
  install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'symbolic', 'apps')
)

# Translate and install our .desktop file so the Applications Menu will see it
i18n.merge_file (
    input: meson.project_name () + '.desktop.in',
    output: meson.project_name () + '.desktop',
    po_dir: join_paths (meson.current_source_dir(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'applications')
)

# Install Settings schema
schemas_conf = configuration_data()
schemas_conf.set('SCHEMA_ID', application_id)
schemas_conf.set('SCHEMA_PATH', schema_id)
schemas_conf.set('GETTEXT_PACKAGE', application_id)

configure_file(
    input: application_id + '.gschema.xml.in',
    output: application_id + '.gschema.xml',
    configuration: schemas_conf,
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)
