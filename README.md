
## Step 1. Run `bash setup-prerequisites.sh`

```bash
govind@thinkpad:~/projects/local-aws-kit$ bash setup-prerequisites.sh 
🔍 Detecting Host Operating System...
💻 System Identified: linux (amd64)
⚙️ Downloading and installing KinD binary...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    86  100    86    0     0    105      0 --:--:-- --:--:-- --:--:--   105
100 10.0M  100 10.0M    0     0  2416k      0  0:00:04  0:00:04 --:--:-- 3039k
[sudo] password for govind: 
⚙️ Downloading and installing kubectl binary...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 56.8M  100 56.8M    0     0  4104k      0  0:00:14  0:00:14 --:--:-- 4175k
🐳 Note: Ensure Docker Engine is installed and your user is part of the 'docker' group.
🚀 Validating Tool Installations...
✅ KinD Version: kind v0.33.0-alpha+0d477639ed54df go1.26.7 linux/amd64
✅ Kubectl Version:   gitVersion: v1.36.4
🎉 Prerequisites successfully configured! You can now execute ./setup.sh safely.

```