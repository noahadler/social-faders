@ControlValues = new Meteor.Collection 'controlValues'
@ControlValues.attachSchema new SimpleSchema
  channel:
    type: String
    label: 'Channel'
    max: 200
    unique: true
  value:
    type: Number
    label: 'Normalized value of control [0.0,1.0]'
    min: 0
    max: 1
    decimal: true
  user_id:
    type: String
    label: 'Hexadecimal ID of user who last set the control'
    optional: true


@UserProfiles = new Meteor.Collection 'userProfiles'