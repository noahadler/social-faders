Package.describe({
  summary: "Social Faders - multitouch, multiuser, realtime controls"
});

Package.on_use(function(api) {
  api.use('coffeescript', ['client','server']);
  api.use('collection2', ['client','server']);
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

