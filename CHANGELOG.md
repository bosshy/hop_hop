## Changelog
### 0.6.2
    * reraise connection errors
### 0.6.1
    * fixing poor man's reconnect (forgot to reset the connection)
### 0.6.0
    * poor man's reconnect
    * added codeqa and ran rubocop
### 0.5.0
    * passing :heartbeat, :automatically_recover, :user, :password to Bunny
### 0.4.0
    * suspendable consumers
### 0.3.0
    * upgrading bunny from 1.1.7 to 1.3.1
### 0.2.0
    * adding wait_spinup config
### 0.1.2
    * now the identifier is also matched when looking for processes
    * code cleanups
### 0.1.1
    * fixing strange syntax errors after rubyocop run
### 0.1.0 
    * consumer server
### 0.0.9
    * inheriting binding and queue names
    * hop_hop binary (running consumers)
### 0.0.8
    * return state os consume documented and changed (true for exit_loop, false for exceptional exit)
