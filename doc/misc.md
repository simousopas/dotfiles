# Miscellaneous notes

## Homebrew

## Mise

## OBS

## SSH
- Generate new keys
  - RSA: `ssh-keygen -t rsa-sha2-512 -b 8192 -f id_rsa -C <hostname>`
  - ED25519: `ssh-keygen -t ed25519 -f id_ed25519 -C <hostname>`
- Set strict permissions
  - For the keys: `chmod u=r,g=,o= id_*`
  - For the folder where they're stored: `chmod u=rwx,g=,o= <folder>`
- Check the size of a RSA key: `ssh-keygen -l -f id_rsa.pub`

## Other
- Get Apple's CLI Tools version: `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables`.
