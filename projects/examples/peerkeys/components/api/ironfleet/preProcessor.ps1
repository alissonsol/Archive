# Automating steps from https://github.com/GLaDOS-Michigan/IronFleet.git
# One letter folder "t" (tmp) used to keep paths short
Remove-Item -Path t -Force -Recurse -ErrorAction "SilentlyContinue"
git clone https://github.com/GLaDOS-Michigan/IronFleet.git t
