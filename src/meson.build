executable(
    meson.project_name(),
    asresources,
    'Application.vala',
    'Settings.vala',
    'MainWindow.vala',
    'StyledButton.vala',
    'views/CalculusView.vala',
    'views/ProgrammerView.vala',
    'views/ScientificView.vala',
    'views/DateView.vala',
    'views/CommonKeyPadConverter.vala',
    'views/ConvLengthView.vala',
    'views/ConvAreaView.vala',
    'views/ConvVolumeView.vala',
    'views/displays/ScientificDisplay.vala',
    'test/TestUtil.vala',
    'core/ScientificCalculator.vala',
    'core/Utils.vala',
    dependencies: [
        core_deps,
        dependency('gtk+-3.0'),
        dependency('granite')
    ],
    install : true
)
