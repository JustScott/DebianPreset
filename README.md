# DebianPreset
After installing Debian using my other project: [DebianInstaller](https://www.github.com/JustScott/DebianInstaller), the scripts in this repo can be ran to configure the system's software, configurations, security, and more, all in a mostly non-dynamic, static (preset) way.

## Running the scripts
When logged in as the administrator
```bash
git clone https://www.github.com/JustScott/DebianPreset
cd DebianPreset
bash run_as_admin.sh
bash run_as_user.sh # optional as admin
```

When logged in as the user (without sudo privileges)
```bash
git clone https://www.github.com/JustScott/DebianPreset
cd DebianPreset
bash run_as_user.sh
```

Make sure to run as admin first to install things like flatpak, which are
required by the `run_as_user.sh` script
