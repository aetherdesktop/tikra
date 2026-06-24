tikra_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'ClockPage.vala',
  'StopwatchPage.vala',
  'TimerPage.vala',
  'WorldClockPage.vala',
  'AddCityDialog.vala',
]

tikra_deps = [
  glib_dep,
  gobject_dep,
  gio_dep,
  gtk_dep,
  libadwaita_dep,
]

executable('tikra',
  tikra_sources,
  dependencies: tikra_deps,
  install: true,
)