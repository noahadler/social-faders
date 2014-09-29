Package.describe({
  summary: "Social Faders - multitouch, multiuser, realtime controls",
  version: "0.1.0",
  git: "https://github.com/noahadler/social-faders.git"
});

Package.on_use(function(api) {
  api.versionsFrom("METEOR@0.9.0");
  api.use('coffeescript', ['client','server']);
  api.use("aldeed:collection2@0.2.16", ['client','server']);
  api.use('accounts-base', ['client', 'server']);
  //api.use('srp', ['client', 'server']);
  api.use(['underscore', 'templating', 'bootstrap', 'ui', 'spacebars'], 'client');

  api.add_files('collections.coffee', ['client', 'server']);
  api.add_files('server.coffee', 'server');

  api.add_files([
    'controls.html',
    'controls.coffee',
    'controls.css',
    'lib/draggabilly.pkgd.min.js'],
    ['client']);
});

