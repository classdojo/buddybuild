# ClassDojo Custom Buddy Build Script

This script provides a series of convenient calls you can make via buddybuild's [custom script system](http://docs.buddybuild.com/docs/custom-prebuild-and-postbuild-steps). 

## To Use:

Open up `buddybuild_utils.rb` and replace the `ACCESS_TOKEN` with your access token provided by buddybuild.

In your `buddybuild_prebuild.sh` or `buddybuild_postbuild.sh` file, include the following:

#### Sample buddybuild_postbuild.sh

```bash
#!/bin/bash

ruby ./myCustomScript.rb
```
#### Sample myCustomScript.rb

```ruby
#!/usr/bin/ruby -w

require_relative 'buddybuild_utils.rb'

APP_ID = "BUDDY_BUILD_APP_ID"

# Triggers a build on a given buddybuild app and branch
BuddyBuild.trigger_build(APP_ID, "master")

#Add whatever other logic you want

```
