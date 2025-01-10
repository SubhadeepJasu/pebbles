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

blueprint_files = [
  'ui/main_window.blp',
  'ui/button.blp',
  'ui/popover_menu_item.blp',
  'ui/display.blp',
  'ui/scientific_display.blp',
  'ui/scientific_view.blp'
]

blueprints_ui = []
foreach b : blueprint_files
	blueprints_ui += b.replace('.blp', '.ui')
endforeach

blueprints = custom_target('blueprints',
    input: files(blueprint_files),
   output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

gresource_bundle = gnome.compile_resources(
    meson.project_name(),
    meson.project_name() + '.gresource.xml',
    source_dir: [
        meson.current_build_dir(),
        meson.current_source_dir(),
    ],
    dependencies: [
        stylesheet_deps,
        blueprints,
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
