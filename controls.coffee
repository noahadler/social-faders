ControlValues = @ControlValues

Meteor.startup ->
  Handlebars.registerHelper 'horizontal_fader', (context, options) ->
    new Handlebars.SafeString Template.horizontal_fader context.hash
  Handlebars.registerHelper 'vertical_fader', (context, options) ->
    return new Handlebars.SafeString Template.vertical_fader context.hash

  Template.vertical_fader.rendered = Template.horizontal_fader.rendered = ->
    console.log '======= Template rendered: ======='
    console.log @
    rendered = @
    Meteor.subscribe 'controlValues',
      onReady: ->
        console.log 'COLLECTION ONREADY'

        #data_id = null
        channel = null
        if rendered.data?
          #data_id = @data._id
          channel = rendered.data.channel

        value_cursor = ControlValues.findOne { channel: channel }
        console.log Meteor
        if !(value_cursor?)
          data_id = ControlValues.insert { value: 0.0, channel: channel, user_id: Meteor.userId() }
          console.log 'created ' + data_id + ' for channel ' + channel
          value_cursor = ControlValues.findOne { _id: data_id }

        console.log 'value cursor:'
        console.log value_cursor

        draghandle = rendered.find '.draghandle'
        container = rendered.find '.fader .draghandle-container'
        draggie = new Draggabilly draghandle,
          containment: container
        draggie.on 'dragMove', (e) ->
          console.log e.position
          console.log 'updating value_cursor:'
          console.log value_cursor
          v = e.position.x
          if v < e.position.y then v = e.position.y
          ControlValues.update value_cursor._id,
            $set:
              value: v / 80.0
              user_id: Meteor.userId()
     
        UpdateDraghandle = (id, fields) ->
          dh = rendered.find '.draghandle'
          dh = $(dh)
          
          # Update fader with picture of user who moved it
          console.log fields
          if fields.user_id? and window.UserProfiles?
            u = window.UserProfiles.findOne fields.user_id
            dh.css('background-image', 'url(' + u.picture + ')')

          # Update fader location when changed remotely
          dh = dh.not('.is-dragging')
          if rendered.find '.vertical'
            dh.css({top: parseInt(fields.value*80) })
          else
            dh.css({left: parseInt(fields.value*80) })

        console.log 'observing changes in ControlValues channel: ' + channel + ' (' + value_cursor._id + ')'
        console.log ControlValues.find(value_cursor._id).observeChanges
          added: (id, fields) ->
            console.log 'added ' + id
            UpdateDraghandle id, fields
          changed: (id, fields) ->
            console.log 'changed ' + id
            UpdateDraghandle id, fields
          removed: (id) ->
            console.log 'removed'
