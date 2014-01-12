Package.describe({
  summary: "Social Faders - multitouch, multiuser, realtime controls"
});

Npm.depends({"coffee-script": "1.5.0"});

Package.on_use(function(api) {
  api.use('templating', 'client');
  api.use('coffeescript', ['client','server']);
  api.use('collection2', ['client','server']);
  api.use('accounts-base', ['client', 'server']);
  //api.use('srp', ['client', 'server']);
  api.use(['underscore', 'templating', 'bootstrap', 'handlebars'], 'client');

  api.add_files('collections.js', ['client', 'server']);
  api.add_files('server.js', 'server');

  api.add_files([
    'controls.html',
    'controls.js',
    'controls.css',
    'lib/draggabilly.pkgd.min.js'],
    ['client']);

});

