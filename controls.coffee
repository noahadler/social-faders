ControlValues = @ControlValues

Meteor.startup ->

  Template.vertical_fader.rendered = Template.horizontal_fader.rendered = ->
    console.log '======= Template rendered: ======='
    console.log @
    rendered = @

    if rendered.data.color
      $(@find '.draghandle').css 'background', rendered.data.color
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

      channel = @channel

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
    class: ->
      console.log 'Class for toggle_button on channel ' + @channel
      v = ControlValues.findOne {channel: @channel}
      if v? and v.value == 1
        return 'toggle-inset on'
      else
        return 'toggle-inset'
    on: ->
      v = ControlValues.findOne {channel: @channel}
      return true if v.value == 1
    userProfile: ->
      v = ControlValues.findOne {channel: @channel}
      if v.user_id? and window.UserProfiles?
        return window.UserProfiles.findOne v.user_id
    style: ->
      console.log 'Style for toggle_button on channel ' + @channel
      v = ControlValues.findOne {channel: @channel}
      if not v?
        v =
          value: 0.0
          channel: @channel
          user_id: Meteor.userId()
        v._id = ControlValues.insert v
      if v.user_id? and window.UserProfiles? 
        u = window.UserProfiles.findOne v.user_id
        if u?
          return 'background-image: url(' + u.picture + ')'
      if v.value == 1 then return 'color: orange;' else return 'color: gray';

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

