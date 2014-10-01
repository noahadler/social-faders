ControlValues = @ControlValues

if Meteor.isClient
  Meteor.startup ->
    navigator.AudioContext = AudioContext || webkitAudioContext
    context = new AudioContext()

    osc1 = context.createOscillator()
    osc2 = context.createOscillator()
    osc3 = context.createOscillator()
    gain1 = context.createGain()
    gain2 = context.createGain()
    gain3 = context.createGain()

    osc1.type = 0
    osc1.frequency.value = 200
    osc1.connect gain1
    osc1.noteOn 0

    osc2.type = 0
    osc2.frequency.value = 330
    osc2.connect gain2
    osc2.noteOn 0

    osc3.type = 0
    osc3.frequency.value = 470
    osc3.connect gain3
    osc3.noteOn 0

    gain1.gain.value = 0.0
    gain1.connect context.destination

    gain2.gain.value = 0.0
    gain2.connect context.destination

    gain3.gain.value = 0.0
    gain3.connect context.destination

    pitchClasses = [0,4,7]
    beat = 0
    beats = 8  # TODO: get width from grid

    step = ->
      beat %= beats
      beat++
      column = new RegExp 'gridTest-'+beat+'-[0-9]+$'
      notes = ControlValues.find({channel: column}).map (doc) ->
        doc.value
      #console.log beat
      #console.log notes

      gain1.gain.value = notes[0]*0.25
      gain2.gain.value = notes[1]*0.25
      gain3.gain.value = notes[2]*0.25


    Meteor.setInterval step, 250

    Deps.autorun ->
      ControlValues.find({channel: 'demo1'}).observeChanges
        changed: (id, fields) ->
          if fields.value?
            osc1.frequency.value = 200 + 200*fields.value

    Deps.autorun ->
      ControlValues.find({channel: 'demo2'}).observeChanges
        changed: (id, f) ->
          if f.value?
            osc2.frequency.value = 330 + 330*f.value

    Deps.autorun ->
      ControlValues.find({channel: 'demo3'}).observeChanges
        changed: (id, f) ->
          if f.value?
            #gain1.gain.value = 0.5*f.value*f.value
            osc3.frequency.value = 470 + 470*f.value

