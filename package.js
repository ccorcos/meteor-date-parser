Package.describe({
  name: 'ccorcos:date-parser',
  summary: 'Semantic date parser for Meteor',
  version: '0.0.3',
  git: 'https://github.com/ccorcos/meteor-date-parser'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.use([
    'coffeescript',
    'ramda:ramda@0.17.0',
    'momentjs:moment@2.10.6'
  ]);
  api.addFiles('parser.coffee');
  api.export('parseDate');
});


Package.onTest(function (api) {
  api.use(["tinytest", "coffeescript"]);
  api.add_files("test.coffee", ["client", "server"]);
});