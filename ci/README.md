# CI notes

### FreeBSD
```

# attach shared to the jail eg to /media

pkg install -y gh
git clone https://github.com/openoms/joininbox
cd joininbox
gh run download

shasum -a256 -c joininbox-amd64-debian-11.5.qcow2.gz.sha256
gzip -dkv joininbox-amd64-debian-11.5.qcow2.gz
shasum -a256 -c joininbox-amd64-debian-11.5.qcow2.sha256

pkg install qemu

qemu-image convert joininbox-amd64-debian-11.5.qcow2 /media/joininbox.img

# In the FreeBSD root
# create a zvol with the exact size of the raw image

dd if=/mnt/cryptic/blitz/images/joininbox.img of=/dev/zvol/cryptic/blitz/jb221210 bs=4M status=progress
```

## Manage the artifacts and workflows with the GitHub CLI
* https://github.com/cli/cli#installation

## Download artifacts in CLI
* https://docs.github.com/en/actions/managing-workflow-runs/downloading-workflow-artifacts

## Delete workflow runs
```
OWNER=
REPO=

# list workflow ids
gh api -X GET /repos/$OWNER/$REPO/actions/workflows | jq '.workflows[] | .name,.id'

WORKFLOW_ID=

# list runs
gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id' | tail -n 10

# delete failed runs
gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | select(.conclusion=="failure") | .id' | tail -n 10 | xargs -I{} gh api -X DELETE /repos/$OWNER/$REPO/actions/runs/{}

# delete cancelled runs
gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | select(.conclusion=="cancelled") | .id' | tail -n 10 | xargs -I{} gh api -X DELETE /repos/$OWNER/$REPO/actions/runs/{}

# delete oldest 10 workflows (won't delete the running one)
gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id' | tail -n 10 | xargs -I{} gh api -X DELETE /repos/$OWNER/$REPO/actions/runs/{}

# delete newest 10 workflows (won't delete the running one)
gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id' | head -n 10 | xargs -I{} gh api -X DELETE /repos/$OWNER/$REPO/actions/runs/{}
```
