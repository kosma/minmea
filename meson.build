project(
    'minmea',
    'c',
    default_options: ['c_std=c99', 'buildtype=debug'],
)

add_project_arguments(
    '-Wall', '-Wextra', '-Werror',
    '-D_POSIX_C_SOURCE=199309L', '-D_BSD_SOURCE', '-D_DEFAULT_SOURCE',
    '-D_DARWIN_C_SOURCE',
    language: 'c',
)

if host_machine.system() == 'windows'
    add_project_arguments('DMINMEA_INCLUDE_COMPAT')
endif

c_args = []

if get_option('buildtype') == 'debug'
    c_args += '-ggdb'
endif

minmea_includes = include_directories('.')

minmea_sources = ['minmea/minmea.c']

minmea_dependencies = []

minmea_lib = library(
    'minmea',
    minmea_sources,
    include_directories: minmea_includes,
    dependencies: minmea_dependencies,
    c_args: c_args,
)

minmea_dep = declare_dependency(
    include_directories: minmea_includes,
    dependencies: minmea_dependencies,
    link_with: minmea_lib,
)

if get_option('example')
    minmea_example_sources = [
        'minmea/example.c',
    ]

    minmea_example_dependencies = [
        minmea_dep,
    ]

    minmea_example = executable(
        'example',
        minmea_example_sources,
        dependencies: minmea_example_dependencies,
    )
endif

if get_option('tests')
    check = dependency('check')

    minmea_test_sources = [
        'minmea/tests.c',
    ]

    minmea_test_dependencies = [
        check,
        minmea_dep,
    ]

    minmea_test = executable(
        'tests',
        minmea_test_sources,
        dependencies: minmea_test_dependencies,
    )

    test('tests', minmea_test)
endif
