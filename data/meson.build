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
        stylesheet_deps
    ],
    gresource_bundle: true,
    install: true,
    install_dir: pkgdatadir,
    c_name: meson.project_name(),

)
