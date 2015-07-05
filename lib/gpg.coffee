spawn = require('child_process').spawn

exports.testMode = false

callGPG = (text, password, params, cb) =>
  result = ""
  errors = ""

  if password is '' or password is null or password is undefined
    cb('No password provided', null)
    return

  if exports.testMode
    params.push('--no-default-keyring')
    params.push('--keyring=' + __dirname + '/../spec/keyring/test.gpg')
    console.log("GPG params: " + params.join(' '))

  pgp = spawn('gpg', params)

  pgp.stdout.on 'data', (data) ->
    result += data.toString()

  pgp.stderr.on 'data', (data) ->
    console.error("PGP: " + data.toString())
    errors += data.toString()

  pgp.stdin.write(password + '\n')
  pgp.stdin.end(text)

  pgp.on 'close', (code, sig) ->
    if code is 0
      cb(null, result)
    else
      cb(errors, null)


exports.encrypt = (text, password, cb) ->
  params = ['--armor', '--symmetric', '--passphrase-fd', '0']
  callGPG(text, password, params, cb)

exports.decrypt = (text, password, cb) ->
  params = ['--decrypt', '--passphrase-fd', '0']
  callGPG(text + '\n', password, params, cb)
