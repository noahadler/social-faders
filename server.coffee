ControlValues = @ControlValues

Meteor.publish 'userProfiles', ->
  console.log 'Publishing userProfiles'
  console.log 'for user ' + @userId
  cursor = Meteor.users.find {}
  cursor.forEach (doc) ->
    console.log doc
  self = @
  handle = cursor.observe
    added: (doc) ->
      if doc.services.hasOwnProperty 'google'
        self.added 'userProfiles', doc._id,
          name: doc.services.google.name
          picture: doc.services.google.picture
      else if doc.services.hasOwnProperty 'twitter'
        self.added 'userProfiles', doc._id,
          name: doc.services.twitter.screenName
          picture: doc.services.twitter.profile_image_url
      else if doc.services.hasOwnProperty 'facebook'
        self.added 'userProfiles', doc._id,
          name: doc.services.facebook.name
          picture: 'http://graph.facebook.com/' + doc.services.facebook.id + '/picture/?type=small'
    removed: (oldDoc) ->
      self.removed 'userProfiles', doc._id
  self.ready()

# Access control
ControlValues.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fieldNames, modifier) -> true
  remove: (userId, doc) -> true

# Publish
Meteor.publish 'controlValues', ->
  handle = ControlValues.find {}, {fields: { channel: 1, value: 1, user_id: 1} }
  p = @
  handle.observeChanges
    added: (id, obj) ->
      p.added 'controlValues', id, obj
    changed: (id, fields) ->
      p.changed 'controlValues', id, fields
    removed: (id) ->
      console.log 'removed ' + id
      p.removed 'controlValues', id

  p.ready()

  #p.onStop ->
  #  handle.stop()

Meteor.startup ->
  ControlValues.remove {}



