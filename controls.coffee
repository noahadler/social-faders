ControlValues = @ControlValues

Meteor.startup ->
  Meteor.subscribe 'userProfiles'

  Template.vertical_fader.rendered = Template.horizontal_fader.rendered = ->
    console.log '======= Template rendered: ======='
    console.log @
    rendered = @

    if rendered.data.color
      $(@find '.draghandle').css 'background-color', rendered.data.color
      $(@find '.fader').css 'border-color', rendered.data.color


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

  Template.toggle_button.events
    'click .toggle-inset': (e,tpl) ->
      console.log 'CLICK'
      inset = $(tpl.find '.toggle-inset')
      console.log @
      console.log tpl

      channel = @hash.channel

      value_cursor = ControlValues.findOne { channel: channel }
      console.log Meteor
      if !(value_cursor?)
        data_id = ControlValues.insert { value: 0.0, channel: channel, user_id: Meteor.userId() }
        value_cursor = ControlValues.findOne { _id: data_id }

      console.log 'updating control value'
      ControlValues.update {_id: value_cursor._id},
        $set:
          value: if inset.hasClass('on') then 0 else 1
          user_id: Meteor.userId()

  Template.toggle_button.helpers
    activeClasses: ->
      console.log 'activeClasses', @, arguments
      #return new Spacebars.SafeString 'toggle-inset'
      v = ControlValues.findOne { channel: @hash.channel }
      active = if v? and v.value > 0 then 'toggle-inset on' else 'toggle-inset'
      return new Spacebars.SafeString active
    style: ->
      v = ControlValues.findOne { channel: @hash.channel }
      if v? and v.value > 0 and v.user_id? and window.UserProfiles?
        u = window.UserProfiles.findOne v.user_id
        return new Spacebars.SafeString('background-image: url("' + u.picture + '"); background-size: 48px 48px;')

  Template.toggle_button.rendered = ->
    console.log 'toggle_button.rendered', @, arguments
    if not ControlValues.findOne { channel: @data.hash.channel }
      ControlValues.insert { value: 0.0, channel: @data.hash.channel, user_id: Meteor.userId() }

  Template.toggle_grid.helpers
    x: ->
      {y: @y, x: x, grid: @grid} for x in [1..@grid.width]
    y: ->
      {y: y, grid: @} for y in [1..@height]
    h: ->
      hash = _.extend {}, @grid
      delete hash.width
      delete hash.height
      hash.channel += '-' + @x + '-' + @y
      button_context = {hash: hash}
      return button_context
    d: ->
      d = _.extend {}, @grid
      delete d.width
      delete d.height
      d.channel += '-' + @x + '-' + @y
      return d

