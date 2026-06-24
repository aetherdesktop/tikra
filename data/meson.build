desktop_file = configure_file(
  input: 'org.aether.tikra.desktop.in',
  output: 'org.aether.tikra.desktop',
  copy: true,
  install: true,
  install_dir: get_option('datadir') / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

appstream_file = configure_file(
  input: 'org.aether.tikra.metainfo.xml',
  output: 'org.aether.tikra.metainfo.xml',
  copy: true,
  install: true,
  install_dir: get_option('datadir') / 'metainfo'
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util,
    args: ['validate', appstream_file]
  )
endif

install_data('org.aether.tikra.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0/schemas'
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file', compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()]
  )
endif

gresource_file = files('tikra.gresource.xml')
gresource = gnome.compile_resources('tikra-resources',
  gresource_file,
  c_name: 'tikra'
)

icon_sizes = ['16x16', '22x22', '24x24', '32x32', '48x48', '64x64', '128x128', '256x256', '512x512']
foreach size : icon_sizes
  install_data(
    'icon' / size + '.png',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / size / 'apps',
    rename: 'org.aether.tikra.png'
  )
endforeach

install_data(
  'icon/main.svg',
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps',
  rename: 'org.aether.tikra.svg'
)