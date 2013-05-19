mongoose    = require 'mongoose'
crypto      = require 'crypto'
algorithm   = 'aes256'
key         = 'askldja kldahskdhjks ah'
pw          = ''
_           = require 'lodash'


Schema = mongoose.Schema
ObjectId = Schema.ObjectId


schemaKeys = 
  ObjectId : ObjectId

  fullName:
    type: String
    required: yes

  email:
    type: String
    required: yes
    unique: yes

  password:
    type: String
    required: yes

  description:
    type: String

  role:
    type: String
    default: 'rep'

  mustChangePassword:
    type: Boolean
    default: yes



schemaOptions = 
  toObject:
    virtuals : yes
  toJSON:
    virtuals : yes
    transform: (doc, ret, options)-> 
      delete ret.password
      ret

UserSchema = new Schema schemaKeys, schemaOptions



UserSchema.methods.encrypt = (str)->
  pw = str
  cipher = crypto.createCipher algorithm, key
  encrypted = cipher.update(pw, 'utf8', 'hex') + cipher.final 'hex' 
  console.log 'ENCRYPTED: ' + encrypted
  encrypted


UserSchema.path('password').set (v)->
  @encrypt v 

Users = mongoose.model 'User', UserSchema

module.exports = Users